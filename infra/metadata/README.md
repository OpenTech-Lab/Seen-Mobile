# Spot Metadata Infra

This module manages the Supabase-backed metadata plane described in `docs/11_Migration from Nostr to Supabase.md`.

Scope:

- Supabase project lifecycle or linked-project settings
- PostgREST API search path for the metadata schema
- SQL-managed metadata schema for profiles, events, posts, witness signals, reports, follows, tags, and blocklist
- Realtime publication setup for metadata tables

Non-scope:

- Image and video transport infrastructure
- CDN/media upload path under `mobile/infra/media`

## Files

- `main.tf`: Supabase provider resources and optional SQL apply step
- `sql/*.sql`: Idempotent schema, RLS, and Realtime DDL
- `scripts/apply_sql.sh`: Applies the SQL files with `psql`

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set `linked_project` for an existing project, or set `create_project = true` plus `organization_id` and `database_password`.
3. If you want Terraform to apply the SQL migrations too, set:
   - `apply_database_migrations = true`
   - `database_url = "postgresql://..."`
4. Run:

```bash
terraform init
terraform plan
terraform apply
```

### Run SQL without Terraform

If you only want to apply the metadata SQL, you can keep a local config file next to the script:

```bash
cd infra/metadata/scripts
cp apply_sql.env.example apply_sql.env
```

Set `DATABASE_URL` in `apply_sql.env`, then run:

```bash
./apply_sql.sh ../sql
```

The script always reads `scripts/apply_sql.env` and ignores any inherited `DATABASE_URL` from the shell, so the file is the single source of truth.
Use the exact pooler host, port, and `postgres.<project-ref>` username shown in the Supabase dashboard for your project.

## Notes

- The official Supabase Terraform provider manages platform resources and settings, not table/RLS DDL. The SQL files in `./sql` cover the database schema side.
- `apply_database_migrations` uses `psql`. Leave it `false` if you prefer to run the SQL with Supabase SQL Editor or Supabase CLI.
- Enable Anonymous Auth in the Supabase project before using the Flutter anonymous sign-in flow.
