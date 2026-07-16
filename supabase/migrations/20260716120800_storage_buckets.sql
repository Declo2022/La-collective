-- =============================================================================
-- African College — Phase 1 · Buckets Storage
-- =============================================================================
-- Trois buckets PRIVÉS. Accès via service_role ou URLs signées à durée limitée.
-- Aucun bucket public en Phase 1.
--   product-media   : visuels générés par les agents avant publication (Phase 3+)
--   agent-artifacts : brouillons / sorties d'agents (Phase 3+)
--   exports         : rapports & exports analytics (dès Phase 1)

insert into storage.buckets (id, name, public)
values
  ('product-media', 'product-media', false),
  ('agent-artifacts', 'agent-artifacts', false),
  ('exports', 'exports', false)
on conflict (id) do nothing;
