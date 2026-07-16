-- =============================================================================
-- African College — Lot 3c · Registre des workflows (versionné) & sauvegardes
-- =============================================================================

create table workflow_registry (
  id               uuid primary key default gen_random_uuid(),
  key              text not null unique,  -- ex. catalog-backfill-cron
  name             text not null,
  category         text,                  -- ingest | sync | agent | action | rag | notify | monitor | report | lib
  trigger_type     text,                  -- webhook | cron | task | manual | sub
  owner_agent_id   uuid references agents(id) on delete set null,
  description      text,
  current_version  int,
  enabled          boolean not null default true,
  n8n_id           text,                  -- identifiant du workflow dans n8n
  created_at       timestamptz not null default now()
);

create table workflow_versions (
  id            uuid primary key default gen_random_uuid(),
  workflow_key  text not null references workflow_registry(key) on delete cascade,
  version       int not null,
  definition    jsonb,                    -- JSON exporté (aussi versionné dans Git)
  checksum      text,
  notes         text,
  deployed_by   text,
  deployed_at   timestamptz not null default now(),
  active        boolean not null default false,
  unique (workflow_key, version)
);

create table workflow_runs (
  id            uuid primary key default gen_random_uuid(),
  workflow_key  text references workflow_registry(key) on delete set null,
  version       int,
  trigger       text,
  status        text not null default 'running'
                  check (status in ('running', 'succeeded', 'failed', 'retrying')),
  trace_id      uuid,
  started_at    timestamptz not null default now(),
  finished_at   timestamptz,
  duration_ms   int,
  cost_usd      numeric(12,6),
  tokens        int,
  error         text
);
create index idx_workflow_runs_key on workflow_runs (workflow_key, started_at);
create index idx_workflow_runs_status on workflow_runs (status);

-- Sauvegardes automatiques (Supabase PITR + export logique + export workflows).
create table backup_runs (
  id               uuid primary key default gen_random_uuid(),
  kind             text not null check (kind in ('supabase_pitr', 'logical_export', 'workflow_export', 'restore_test')),
  status           text not null default 'running' check (status in ('running', 'succeeded', 'failed')),
  location         text,                  -- chemin bucket
  size_bytes       bigint,
  checksum         text,
  retention_until  date,                  -- défaut : +30 jours
  started_at       timestamptz not null default now(),
  finished_at      timestamptz,
  detail           jsonb not null default '{}'
);
create index idx_backup_runs_kind on backup_runs (kind, started_at);

-- RLS
alter table workflow_registry enable row level security;
alter table workflow_versions enable row level security;
alter table workflow_runs enable row level security;
alter table backup_runs enable row level security;
