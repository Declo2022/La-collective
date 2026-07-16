-- =============================================================================
-- African College — Lot 3a · Logs, audit immuable, rollback
-- =============================================================================
-- pgcrypto pour le hachage SHA-256 de la chaîne d'audit.
create extension if not exists pgcrypto;

-- event_log remplace audit_log (Phase 1, jamais utilisé).
drop table if exists audit_log;

-- ---------------------------------------------------------------------------
-- Journal global structuré : chaque agent, workflow et action.
-- ---------------------------------------------------------------------------
create table event_log (
  id              uuid primary key default gen_random_uuid(),
  trace_id        uuid,                 -- relie une chaîne d'actions
  span_id         uuid,
  parent_span_id  uuid,
  actor_type      text,                 -- agent | human | system | workflow
  actor_id        uuid,
  workflow_key    text,
  workflow_run_id uuid,
  category        text not null,        -- llm_call | tool_call | shopify_mutation | approval | task | memory | rag | error | backup
  action          text,
  entity_type     text,
  entity_id       uuid,
  level           text not null default 'info' check (level in ('debug', 'info', 'warn', 'error')),
  tokens          int,
  cost_usd        numeric(12,6),
  duration_ms     int,
  detail          jsonb not null default '{}',
  created_at      timestamptz not null default now()
);
create index idx_event_log_trace on event_log (trace_id);
create index idx_event_log_category on event_log (category, created_at);
create index idx_event_log_actor on event_log (actor_type, actor_id);
create index idx_event_log_workflow on event_log (workflow_key);
create index idx_event_log_created on event_log (created_at);

-- ---------------------------------------------------------------------------
-- Audit IMMUABLE des décisions : append-only + chaîne de hash.
-- ---------------------------------------------------------------------------
create sequence audit_trail_seq;

create table audit_trail (
  id           uuid primary key default gen_random_uuid(),
  seq          bigint not null,          -- rempli par le trigger (ordre de la chaîne)
  actor_type   text,
  actor_id     uuid,
  action       text not null,
  entity_type  text,
  entity_id    uuid,
  payload      jsonb not null default '{}',
  prev_hash    text,
  hash         text,
  created_at   timestamptz not null default now()
);
create unique index idx_audit_trail_seq on audit_trail (seq);

-- Scelle chaque ligne : seq + prev_hash + hash SHA-256.
create or replace function audit_trail_seal() returns trigger as $$
declare last_hash text;
begin
  new.seq := nextval('audit_trail_seq');
  new.created_at := coalesce(new.created_at, now());
  select hash into last_hash from audit_trail order by seq desc limit 1;
  new.prev_hash := coalesce(last_hash, 'genesis');
  new.hash := encode(
    digest(new.seq::text || new.prev_hash || coalesce(new.payload::text, '') || new.created_at::text, 'sha256'),
    'hex'
  );
  return new;
end;
$$ language plpgsql;

create trigger trg_audit_trail_seal
  before insert on audit_trail
  for each row execute function audit_trail_seal();

-- Immuabilité : refuse toute modification ou suppression.
create or replace function prevent_mutation() returns trigger as $$
begin
  raise exception 'Table % est append-only (immuable) : opération % interdite', TG_TABLE_NAME, TG_OP;
end;
$$ language plpgsql;

create trigger trg_audit_trail_no_update before update on audit_trail
  for each row execute function prevent_mutation();
create trigger trg_audit_trail_no_delete before delete on audit_trail
  for each row execute function prevent_mutation();

-- ---------------------------------------------------------------------------
-- Rollback : capture de l'état avant/après pour tout changement réversible.
-- ---------------------------------------------------------------------------
create table change_sets (
  id            uuid primary key default gen_random_uuid(),
  entity_type   text not null,          -- shopify_product | collection | kb_* | ...
  entity_id     uuid,
  shopify_id    bigint,
  before_state  jsonb,
  after_state   jsonb,
  action_id     uuid references actions(id) on delete set null,
  applied_by    text,
  applied_at    timestamptz not null default now(),
  reversible    boolean not null default true,
  reverted_at   timestamptz,
  revert_of     uuid references change_sets(id) on delete set null,
  detail        jsonb not null default '{}'
);
create index idx_change_sets_entity on change_sets (entity_type, entity_id);

-- RLS (refus par défaut ; backend = service_role).
alter table event_log enable row level security;
alter table audit_trail enable row level security;
alter table change_sets enable row level security;
