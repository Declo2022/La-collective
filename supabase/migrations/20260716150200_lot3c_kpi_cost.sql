-- =============================================================================
-- African College — Lot 3c · KPI, coûts & rentabilité
-- =============================================================================

create table kpi_definitions (
  id           uuid primary key default gen_random_uuid(),
  key          text not null unique,     -- ex. daily_revenue, ai_cost, conversion_rate
  name         text not null,
  unit         text,                     -- EUR | % | count
  description  text,
  target       numeric,
  direction    text check (direction in ('up_good', 'down_good')),
  created_at   timestamptz not null default now()
);

create table kpi_snapshots (
  id          uuid primary key default gen_random_uuid(),
  kpi_key     text not null references kpi_definitions(key) on delete cascade,
  date        date not null,
  value       numeric,
  dimension   jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  unique (kpi_key, date, dimension)
);
create index idx_kpi_snapshots_date on kpi_snapshots (date);

-- Coût ventilé par agent, workflow ou service (agrégé depuis event_log).
create table cost_ledger (
  id            uuid primary key default gen_random_uuid(),
  occurred_on   date not null,
  source_type   text not null check (source_type in ('agent', 'workflow', 'service')),
  source_key    text not null,           -- nom d'agent, clé de workflow, nom de service
  category      text not null check (category in ('llm', 'infra', 'email', 'other')),
  amount_usd    numeric(12,6) not null default 0,
  tokens        int,
  detail        jsonb not null default '{}',
  created_at    timestamptz not null default now()
);
create index idx_cost_ledger_day on cost_ledger (occurred_on);
create index idx_cost_ledger_source on cost_ledger (source_type, source_key);

-- Rentabilité quotidienne : CA − coûts.
create table profitability_snapshots (
  id            uuid primary key default gen_random_uuid(),
  date          date not null unique,
  revenue       numeric(12,2) not null default 0,
  ai_cost       numeric(12,4) not null default 0,
  other_cost    numeric(12,4) not null default 0,
  gross_margin  numeric(12,4),
  detail        jsonb not null default '{}',
  created_at    timestamptz not null default now()
);

-- RLS
alter table kpi_definitions enable row level security;
alter table kpi_snapshots enable row level security;
alter table cost_ledger enable row level security;
alter table profitability_snapshots enable row level security;
