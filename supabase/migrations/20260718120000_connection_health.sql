-- =============================================================================
-- African College — Santé des connexions (auto-vérification des services)
-- =============================================================================
-- Support du workflow monitor-connections-healthcheck : chaque service
-- (Shopify, OpenAI, Telegram, Printful, n8n, Supabase) est testé périodiquement
-- et son état enregistré ici. fn_record_connection_check journalise aussi dans
-- event_log (warn si error). v_connection_health = dernier état par service.

create table if not exists connection_health (
  id          uuid primary key default gen_random_uuid(),
  service     text not null,
  status      text not null check (status in ('ok', 'error', 'unknown')),
  detail      text,
  latency_ms  integer,
  checked_at  timestamptz not null default now()
);

create index if not exists idx_connection_health_service
  on connection_health (service, checked_at desc);

-- RLS : refus par défaut (le service_role de n8n contourne).
alter table connection_health enable row level security;

-- ---------------------------------------------------------------------------
-- Enregistre le résultat d'un contrôle + trace dans event_log.
-- ---------------------------------------------------------------------------
create or replace function fn_record_connection_check(
  p_service   text,
  p_status    text,
  p_detail    text default null,
  p_latency_ms int default null
) returns uuid as $$
declare v_id uuid;
begin
  insert into connection_health (service, status, detail, latency_ms)
  values (p_service, p_status, p_detail, p_latency_ms)
  returning id into v_id;

  perform fn_log_event(
    'connection_check', p_service, 'service', null,
    'monitor-connections-healthcheck', null, null, null,
    case when p_status = 'ok' then 'info' else 'warn' end,
    null, null, p_latency_ms, null,
    jsonb_build_object('status', p_status, 'detail', p_detail));

  return v_id;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Dernier état connu de chaque service.
-- ---------------------------------------------------------------------------
create or replace view v_connection_health as
select distinct on (service)
  service, status, detail, latency_ms, checked_at
from connection_health
order by service, checked_at desc;
