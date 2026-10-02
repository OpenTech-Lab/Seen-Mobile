-- Links an agent's anonymous Supabase content user to the persona public key
-- that its token was issued for.
--
-- The persona key cannot live in public.profiles.legacy_pubkey: 042 made that
-- column unique and immutable, and the owner's own phone profile already holds
-- the same key. This side table keeps the link without touching that binding.
--
-- It has no policies and no client grants on purpose, so only the service role
-- (Amplify agent-posts Lambda writes, public feed Lambda reads) can use it.

create table if not exists public.agent_content_identities (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  persona_pubkey text not null check (persona_pubkey ~ '^[0-9a-f]{64}$'),
  agent_token_id text not null,
  agent_label text not null,
  created_at timestamptz not null default timezone('utc', now())
);

alter table public.agent_content_identities enable row level security;
revoke all on public.agent_content_identities from public, anon, authenticated;
