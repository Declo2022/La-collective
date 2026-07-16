-- =============================================================================
-- African College — Phase 1 · Domaine E : Plomberie / Ops
-- =============================================================================
-- Idempotence des webhooks, suivi des synchronisations, traçabilité.

create table webhook_events (
  id            uuid primary key default gen_random_uuid(),
  webhook_id    text unique,          -- en-tête X-Shopify-Webhook-Id (déduplication)
  source        text not null default 'shopify',
  topic         text,
  shopify_id    bigint,
  payload       jsonb,
  hmac_valid    boolean,
  status        text not null default 'received'
                  check (status in ('received', 'processed', 'failed', 'skipped')),
  received_at   timestamptz not null default now(),
  processed_at  timestamptz
);

create table sync_state (
  id              uuid primary key default gen_random_uuid(),
  resource        text not null unique, -- products | orders | collections | inventory | ga4 | gsc | clarity
  last_cursor     text,
  last_synced_at  timestamptz,
  status          text,
  detail          jsonb not null default '{}'
);

create table audit_log (
  id           uuid primary key default gen_random_uuid(),
  actor        text,                  -- nom d'agent | system | human
  action       text,
  entity_type  text,
  entity_id    uuid,
  detail       jsonb not null default '{}',
  created_at   timestamptz not null default now()
);
