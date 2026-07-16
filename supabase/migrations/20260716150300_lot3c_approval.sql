-- =============================================================================
-- African College — Lot 3c · Approbation multi-niveaux (CEO → CTO → humain)
-- =============================================================================

-- Chaîne d'approbation réutilisable (ex. « écriture Shopify »).
create table approval_chains (
  id           uuid primary key default gen_random_uuid(),
  key          text not null unique,
  name         text not null,
  description  text,
  created_at   timestamptz not null default now()
);

-- Étapes ordonnées d'une chaîne : CEO (agent), CTO (agent), humain.
create table approval_steps (
  id             uuid primary key default gen_random_uuid(),
  chain_id       uuid not null references approval_chains(id) on delete cascade,
  step_order     int not null,
  approver_type  text not null check (approver_type in ('agent', 'human')),
  approver_role  text not null,          -- CEO | CTO | human
  required       boolean not null default true,
  unique (chain_id, step_order)
);

-- Politique : quel type d'action utilise quelle chaîne, à quel niveau de risque.
create table approval_policies (
  id            uuid primary key default gen_random_uuid(),
  action_type   text not null unique,    -- shopify_product_update | seo_update | price_change | ...
  chain_id      uuid references approval_chains(id) on delete set null,
  requires_human boolean not null default true,
  risk_level    text not null default 'high' check (risk_level in ('low', 'medium', 'high')),
  enabled       boolean not null default true,
  created_at    timestamptz not null default now()
);

-- Instance d'approbation en cours pour une proposition.
create table approval_requests (
  id            uuid primary key default gen_random_uuid(),
  proposal_id   uuid references proposals(id) on delete cascade,
  chain_id      uuid references approval_chains(id) on delete set null,
  current_step  int not null default 1,
  status        text not null default 'pending'
                  check (status in ('pending', 'approved', 'rejected', 'escalated', 'canceled')),
  created_at    timestamptz not null default now(),
  decided_at    timestamptz
);
create index idx_approval_requests_status on approval_requests (status);

-- Historique IMMUABLE de chaque décision (agents ET humains).
create table approval_decisions (
  id             uuid primary key default gen_random_uuid(),
  request_id     uuid not null references approval_requests(id) on delete cascade,
  step_order     int not null,
  approver_type  text not null check (approver_type in ('agent', 'human')),
  approver_id    uuid,
  approver_role  text,                   -- CEO | CTO | human
  decision       text not null check (decision in ('approved', 'rejected', 'abstain')),
  comment        text,
  decided_at     timestamptz not null default now()
);
create index idx_approval_decisions_request on approval_decisions (request_id);

-- Immuabilité de l'historique des validations (réutilise prevent_mutation du Lot 3a).
create trigger trg_approval_decisions_no_update before update on approval_decisions
  for each row execute function prevent_mutation();
create trigger trg_approval_decisions_no_delete before delete on approval_decisions
  for each row execute function prevent_mutation();

-- RLS
alter table approval_chains enable row level security;
alter table approval_steps enable row level security;
alter table approval_policies enable row level security;
alter table approval_requests enable row level security;
alter table approval_decisions enable row level security;
