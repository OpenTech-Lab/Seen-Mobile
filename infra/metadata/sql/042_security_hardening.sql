-- Security hardening for identity binding, post ownership, event ownership,
-- and network endpoint visibility. Keep authorization anchored to auth.uid();
-- legacy Nostr identifiers are presentation/linking metadata only.

do $$
begin
  if exists (
    select 1
    from public.profiles
    where legacy_pubkey is not null and btrim(legacy_pubkey) <> ''
    group by lower(btrim(legacy_pubkey))
    having count(*) > 1
  ) then
    raise exception 'duplicate legacy_pubkey bindings must be resolved before security migration';
  end if;
end;
$$;

create unique index if not exists profiles_legacy_pubkey_unique_idx
  on public.profiles (lower(btrim(legacy_pubkey)))
  where legacy_pubkey is not null and btrim(legacy_pubkey) <> '';

create table if not exists public.profile_private (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  device_id text,
  updated_at timestamp with time zone not null default timezone('utc', now())
);

insert into public.profile_private (user_id, device_id)
select id, device_id
from public.profiles
where device_id is not null and btrim(device_id) <> ''
on conflict (user_id) do update
set device_id = excluded.device_id,
    updated_at = timezone('utc', now());

update public.profiles set device_id = null where device_id is not null;

alter table public.profile_private enable row level security;
grant select, insert, update, delete on public.profile_private to authenticated;

drop policy if exists profile_private_owner_access on public.profile_private;
create policy profile_private_owner_access
on public.profile_private
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create or replace function public.protect_profile_identity()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.legacy_pubkey is not null
     and btrim(old.legacy_pubkey) <> ''
     and new.legacy_pubkey is distinct from old.legacy_pubkey then
    raise exception 'legacy identity binding is immutable';
  end if;

  if new.legacy_pubkey is not null
     and new.legacy_pubkey !~ '^[0-9a-f]{64}$' then
    raise exception 'legacy public key must be canonical lowercase hex';
  end if;

  return new;
end;
$$;

drop trigger if exists profiles_protect_identity on public.profiles;
create trigger profiles_protect_identity
before update on public.profiles
for each row
execute function public.protect_profile_identity();

create or replace function public.soft_delete_post(
  p_requested_post_id text default null,
  p_content_hash text default null
)
returns public.posts
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_target public.posts%rowtype;
begin
  if v_user_id is null then
    raise exception 'authenticated user required';
  end if;

  if p_requested_post_id is not null and btrim(p_requested_post_id) <> '' then
    select p.*
      into v_target
    from public.posts as p
    where p.deleted_at is null
      and p.user_id = v_user_id
      and p.id::text = btrim(p_requested_post_id)
    limit 1;
  end if;

  if not found and p_content_hash is not null and btrim(p_content_hash) <> '' then
    select p.*
      into v_target
    from public.posts as p
    where p.deleted_at is null
      and p.user_id = v_user_id
      and btrim(p_content_hash) = any (p.content_hashes)
    order by p.created_at desc
    limit 1;
  end if;

  if not found then
    raise exception 'post not found for deletion';
  end if;

  update public.posts
  set deleted_at = timezone('utc', now())
  where id = v_target.id
    and user_id = v_user_id
  returning * into v_target;

  return v_target;
end;
$$;

revoke all on function public.soft_delete_post(text, text) from public, anon;
grant execute on function public.soft_delete_post(text, text) to authenticated;

create or replace function public.ensure_event_exists(
  p_hashtag text,
  p_title text default null,
  p_description text default null,
  p_latitude double precision default null,
  p_longitude double precision default null
)
returns public.events
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_event public.events%rowtype;
  v_hashtag text := nullif(lower(btrim(p_hashtag)), '');
begin
  if v_user_id is null then
    raise exception 'authenticated user required';
  end if;
  if v_hashtag is null then
    raise exception 'hashtag is required';
  end if;

  insert into public.events (
    hashtag, title, description, creator_id, latitude, longitude
  ) values (
    v_hashtag, p_title, p_description, v_user_id, p_latitude, p_longitude
  )
  on conflict (hashtag) do nothing
  returning * into v_event;

  if v_event.id is null then
    select e.* into strict v_event
    from public.events as e
    where e.hashtag = v_hashtag;
  end if;

  return v_event;
end;
$$;

revoke all on function public.ensure_event_exists(
  text, text, text, double precision, double precision
) from public, anon;
grant execute on function public.ensure_event_exists(
  text, text, text, double precision, double precision
) to authenticated;

drop policy if exists events_authenticated_insert on public.events;
create policy events_authenticated_insert
on public.events
for insert
to authenticated
with check ((select auth.uid()) = creator_id);

drop policy if exists events_creator_update on public.events;
create policy events_creator_update
on public.events
for update
to authenticated
using ((select auth.uid()) = creator_id)
with check ((select auth.uid()) = creator_id);

-- Unauthenticated API callers do not need stable identity, location, or
-- network-coordinate tables. Signed-in clients remain governed by RLS.
revoke select on public.profiles from anon;
revoke select on public.posts from anon;
revoke select on public.witness_signals from anon;
revoke select on public.peer_endpoints from anon;

drop policy if exists profiles_public_read on public.profiles;
drop policy if exists profiles_authenticated_read on public.profiles;
create policy profiles_authenticated_read
on public.profiles
for select
to authenticated
using (true);

drop policy if exists posts_public_read on public.posts;
drop policy if exists posts_authenticated_read on public.posts;
create policy posts_authenticated_read
on public.posts
for select
to authenticated
using (deleted_at is null);

drop policy if exists witness_signals_public_read on public.witness_signals;
drop policy if exists witness_signals_authenticated_read on public.witness_signals;
create policy witness_signals_authenticated_read
on public.witness_signals
for select
to authenticated
using (true);

drop policy if exists peer_endpoints_public_read on public.peer_endpoints;
drop policy if exists peer_endpoints_relationship_read on public.peer_endpoints;
create policy peer_endpoints_relationship_read
on public.peer_endpoints
for select
to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1
    from public.follows as f
    where f.follower_id = (select auth.uid())
      and f.followed_profile_id = peer_endpoints.user_id
  )
);

-- Sanitized feed tables preserve realtime subscriptions without exposing the
-- raw location rows. Coordinates are copied only for profiles that explicitly
-- opted into a public footprint map.
create table if not exists public.post_feed
  (like public.posts including defaults);
create table if not exists public.witness_feed
  (like public.witness_signals including defaults);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.post_feed'::regclass and contype = 'p'
  ) then
    alter table public.post_feed add primary key (id);
  end if;
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.witness_feed'::regclass and contype = 'p'
  ) then
    alter table public.witness_feed add primary key (id);
  end if;
end;
$$;

create or replace function public.sync_post_feed_row()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_public boolean;
begin
  if tg_op = 'DELETE' then
    delete from public.post_feed where id = old.id;
    return old;
  end if;

  select p.footprint_map_public into v_public
  from public.profiles as p
  where p.id = new.user_id;

  insert into public.post_feed select (new).*
  on conflict (id) do update set
    event_hashtag = excluded.event_hashtag,
    event_tags = excluded.event_tags,
    user_id = excluded.user_id,
    content_hashes = excluded.content_hashes,
    media_type = excluded.media_type,
    caption = excluded.caption,
    latitude = excluded.latitude,
    longitude = excluded.longitude,
    gps = excluded.gps,
    view_count = excluded.view_count,
    reply_count = excluded.reply_count,
    like_count = excluded.like_count,
    preview_base64 = excluded.preview_base64,
    preview_mime_type = excluded.preview_mime_type,
    source_type = excluded.source_type,
    is_danger_mode = excluded.is_danger_mode,
    is_virtual = excluded.is_virtual,
    is_ai_generated = excluded.is_ai_generated,
    is_text_only = excluded.is_text_only,
    reply_to_id = excluded.reply_to_id,
    spot_name = excluded.spot_name,
    tags = excluded.tags,
    deleted_at = excluded.deleted_at,
    created_at = excluded.created_at,
    updated_at = excluded.updated_at;

  if not coalesce(v_public, false) then
    update public.post_feed
    set latitude = null, longitude = null, gps = null
    where id = new.id;
  end if;
  return new;
end;
$$;

create or replace function public.sync_witness_feed_row()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_public boolean;
begin
  if tg_op = 'DELETE' then
    delete from public.witness_feed where id = old.id;
    return old;
  end if;

  select p.footprint_map_public into v_public
  from public.profiles as p
  where p.id = new.user_id;

  insert into public.witness_feed select (new).*
  on conflict (id) do update set
    event_hashtag = excluded.event_hashtag,
    user_id = excluded.user_id,
    witness_type = excluded.witness_type,
    latitude = excluded.latitude,
    longitude = excluded.longitude,
    gps = excluded.gps,
    created_at = excluded.created_at,
    updated_at = excluded.updated_at;

  if not coalesce(v_public, false) then
    update public.witness_feed
    set latitude = null, longitude = null, gps = null
    where id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists posts_sync_public_feed on public.posts;
create trigger posts_sync_public_feed
after insert or update or delete on public.posts
for each row execute function public.sync_post_feed_row();

drop trigger if exists witnesses_sync_public_feed on public.witness_signals;
create trigger witnesses_sync_public_feed
after insert or update or delete on public.witness_signals
for each row execute function public.sync_witness_feed_row();

truncate table public.post_feed;
insert into public.post_feed select p.* from public.posts as p;
update public.post_feed as feed
set latitude = null, longitude = null, gps = null
from public.profiles as owner
where owner.id = feed.user_id and not owner.footprint_map_public;

truncate table public.witness_feed;
insert into public.witness_feed select w.* from public.witness_signals as w;
update public.witness_feed as feed
set latitude = null, longitude = null, gps = null
from public.profiles as owner
where owner.id = feed.user_id and not owner.footprint_map_public;

create or replace function public.resync_profile_feed_privacy()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.footprint_map_public is distinct from old.footprint_map_public then
    update public.post_feed as feed
    set latitude = case when new.footprint_map_public then source.latitude else null end,
        longitude = case when new.footprint_map_public then source.longitude else null end,
        gps = case when new.footprint_map_public then source.gps else null end
    from public.posts as source
    where source.id = feed.id and source.user_id = new.id;

    update public.witness_feed as feed
    set latitude = case when new.footprint_map_public then source.latitude else null end,
        longitude = case when new.footprint_map_public then source.longitude else null end,
        gps = case when new.footprint_map_public then source.gps else null end
    from public.witness_signals as source
    where source.id = feed.id and source.user_id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_resync_feed_privacy on public.profiles;
create trigger profiles_resync_feed_privacy
after update of footprint_map_public on public.profiles
for each row execute function public.resync_profile_feed_privacy();

alter table public.post_feed enable row level security;
alter table public.witness_feed enable row level security;
grant select on public.post_feed, public.witness_feed to authenticated;

drop policy if exists post_feed_authenticated_read on public.post_feed;
create policy post_feed_authenticated_read
on public.post_feed for select to authenticated
using (deleted_at is null);
drop policy if exists witness_feed_authenticated_read on public.witness_feed;
create policy witness_feed_authenticated_read
on public.witness_feed for select to authenticated
using (true);

drop policy if exists posts_authenticated_read on public.posts;
drop policy if exists posts_owner_read on public.posts;
create policy posts_owner_read
on public.posts for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists witness_signals_authenticated_read on public.witness_signals;
drop policy if exists witness_signals_owner_read on public.witness_signals;
create policy witness_signals_owner_read
on public.witness_signals for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists events_public_read on public.events;
drop policy if exists events_creator_read on public.events;
create policy events_creator_read
on public.events for select to authenticated
using ((select auth.uid()) = creator_id);
revoke select on public.events from anon;

revoke execute on function public.nearby_posts(
  double precision, double precision, integer, integer
) from public, anon, authenticated;
revoke execute on function public.trending_posts(integer)
  from public, anon, authenticated;

alter table public.post_feed replica identity full;
alter table public.witness_feed replica identity full;

do $$
begin
  if exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'posts'
  ) then
    alter publication supabase_realtime drop table public.posts;
  end if;
  if exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'witness_signals'
  ) then
    alter publication supabase_realtime drop table public.witness_signals;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'post_feed'
  ) then
    alter publication supabase_realtime add table public.post_feed;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'witness_feed'
  ) then
    alter publication supabase_realtime add table public.witness_feed;
  end if;
end;
$$;
