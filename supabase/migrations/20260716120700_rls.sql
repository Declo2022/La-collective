-- =============================================================================
-- African College — Phase 1 · Row Level Security
-- =============================================================================
-- RLS activé sur TOUTES les tables, refus par défaut.
-- Aucune policy pour anon/authenticated => aucun accès (défaut sécurisé).
-- La clé service_role (backend n8n/agents) CONTOURNE le RLS par conception.
-- Les policies de lecture publique (ex. storefront) seront ajoutées plus tard,
-- sur décision explicite, jamais par oubli.

alter table products enable row level security;
alter table product_variants enable row level security;
alter table collections enable row level security;
alter table product_collections enable row level security;
alter table locations enable row level security;
alter table inventory_levels enable row level security;

alter table customers enable row level security;
alter table orders enable row level security;
alter table order_line_items enable row level security;

alter table ga4_daily enable row level security;
alter table gsc_daily enable row level security;
alter table clarity_daily enable row level security;

alter table agents enable row level security;
alter table agent_runs enable row level security;
alter table agent_memory enable row level security;
alter table proposals enable row level security;
alter table approvals enable row level security;
alter table actions enable row level security;

alter table webhook_events enable row level security;
alter table sync_state enable row level security;
alter table audit_log enable row level security;
