-- =============================================================================
-- African College — Lot 3b · Erreurs & reprise, monitoring, alertes
-- =============================================================================

-- ---------------------------------------------------------------------------
-- File de jobs durable, avec reprise automatique (backoff).
-- ---------------------------------------------------------------------------
create table job_queue (
  id             uuid primary key default gen_random_uuid(),
  kind           text not null,          -- shopify_call | google_pull | openai_call | notification | ...
  payload        jsonb not null default '{}',
  status         text not null default 'pending'
                   check (status in ('pending', 'running', 'succeeded', 'failed', 'dead')),
  attempts       int not null default 0,
  max_attempts   int not null default 5,
  next_run_at    timestamptz not null default now(),
  backoff_seconds int not null default 30,
  last_error     text,
  workflow_key   text,
  trace_id       uuid,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index idx_job_queue_due on job_queue (status, next_run_at);
create index idx_job_queue_kind on job_queue (kind);

-- Jobs ayant épuisé leurs tentatives : conservés pour rejeu manuel.
create table dead_letter_queue (
  id               uuid primary key default gen_random_uuid(),
  original_job_id  uuid,
  kind             text,
  payload          jsonb,
  error            text,
  workflow_key     text,
  created_at       timestamptz not null default now(),
  resolved_at      timestamptz
);

-- ---------------------------------------------------------------------------
-- Monitoring temps réel.
-- ---------------------------------------------------------------------------
create table service_heartbeats (
  id            uuid primary key default gen_random_uuid(),
  service       text not null unique,    -- n8n | supabase | agent:seo | workflow:catalog-backfill-cron
  status        text not null default 'up' check (status in ('up', 'degraded', 'down')),
  last_seen_at  timestamptz not null default now(),
  detail        jsonb not null default '{}'
);

create table health_checks (
  id          uuid primary key default gen_random_uuid(),
  target      text not null,
  status      text not null check (status in ('ok', 'warn', 'fail')),
  latency_ms  int,
  checked_at  timestamptz not null default now(),
  detail      jsonb not null default '{}'
);
create index idx_health_checks_target on health_checks (target, checked_at);

create table metrics (
  id           uuid primary key default gen_random_uuid(),
  metric       text not null,            -- ex. workflow.duration_ms, agent.tokens
  labels       jsonb not null default '{}',
  value        numeric not null,
  recorded_at  timestamptz not null default now()
);
create index idx_metrics_name on metrics (metric, recorded_at);

-- ---------------------------------------------------------------------------
-- Alertes multi-canal (Telegram / Slack / e-mail).
-- ---------------------------------------------------------------------------
create table alert_rules (
  id               uuid primary key default gen_random_uuid(),
  name             text not null unique,
  description      text,
  severity         text not null default 'warn' check (severity in ('info', 'warn', 'critical')),
  channels         text[] not null default '{telegram}',  -- telegram | slack | email
  condition        jsonb not null default '{}',
  throttle_seconds int not null default 300,
  enabled          boolean not null default true,
  created_at       timestamptz not null default now()
);

create table alerts (
  id           uuid primary key default gen_random_uuid(),
  rule_id      uuid references alert_rules(id) on delete set null,
  severity     text not null default 'warn' check (severity in ('info', 'warn', 'critical')),
  title        text not null,
  body         text,
  status       text not null default 'firing' check (status in ('firing', 'acknowledged', 'resolved')),
  payload      jsonb not null default '{}',
  fired_at     timestamptz not null default now(),
  acknowledged_at timestamptz,
  resolved_at  timestamptz
);
create index idx_alerts_status on alerts (status, fired_at);

-- RLS
alter table job_queue enable row level security;
alter table dead_letter_queue enable row level security;
alter table service_heartbeats enable row level security;
alter table health_checks enable row level security;
alter table metrics enable row level security;
alter table alert_rules enable row level security;
alter table alerts enable row level security;
