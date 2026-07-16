-- =============================================================================
-- African College — Phase 1 · Domaine D : Agents
-- =============================================================================
-- Structure posée maintenant (tables vides), remplie à partir de la Phase 3.
-- Matérialise le garde-fou « brouillon + validation » : proposals → approvals → actions.

create table agents (
  id           uuid primary key default gen_random_uuid(),
  name         text not null unique,
  role         text,
  description  text,
  enabled      boolean not null default false,
  config       jsonb not null default '{}',
  created_at   timestamptz not null default now()
);

create table agent_runs (
  id           uuid primary key default gen_random_uuid(),
  agent_id     uuid references agents(id) on delete set null,
  trigger      text,
  status       text not null default 'running'
                 check (status in ('running', 'succeeded', 'failed')),
  input        jsonb,
  output       jsonb,
  tokens_used  int,
  cost_usd     numeric(10,4),
  error        text,
  started_at   timestamptz not null default now(),
  finished_at  timestamptz
);

create table agent_memory (
  id          uuid primary key default gen_random_uuid(),
  agent_id    uuid references agents(id) on delete set null,
  kind        text,                 -- product | content | policy | insight
  ref_type    text,
  ref_id      uuid,
  content     text,
  embedding   vector(1536),         -- text-embedding-3-large tronqué à 1536 (indexable HNSW)
  metadata    jsonb not null default '{}',
  created_at  timestamptz not null default now()
);
comment on column agent_memory.embedding is 'text-embedding-3-large réduit à 1536 dims — indexable (pgvector <= 2000).';

create table proposals (
  id                 uuid primary key default gen_random_uuid(),
  agent_run_id       uuid references agent_runs(id) on delete set null,
  type               text not null,        -- product_update | seo_update | collection_change | content_create | support_reply
  target_type        text,
  target_shopify_id  bigint,
  summary            text,
  payload            jsonb,
  status             text not null default 'draft'
                       check (status in ('draft', 'pending', 'approved', 'rejected', 'applied', 'failed')),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table approvals (
  id                   uuid primary key default gen_random_uuid(),
  proposal_id          uuid not null references proposals(id) on delete cascade,
  decision             text not null check (decision in ('approved', 'rejected')),
  decided_by           text,
  telegram_message_id  bigint,
  note                 text,
  decided_at           timestamptz not null default now()
);

create table actions (
  id                uuid primary key default gen_random_uuid(),
  proposal_id       uuid not null references proposals(id) on delete cascade,
  kind              text,
  shopify_mutation  text,
  request           jsonb,
  response          jsonb,
  status            text not null default 'pending'
                      check (status in ('pending', 'success', 'failed')),
  executed_at       timestamptz
);
