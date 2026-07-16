-- =============================================================================
-- African College — Renforcement · RLS & Storage (Lot 1 : RAG + KB)
-- =============================================================================
-- Mêmes règles que Phase 1 : RLS activé, refus par défaut, backend = service_role.

alter table documents enable row level security;
alter table document_chunks enable row level security;
alter table kb_artists enable row level security;
alter table kb_interviews enable row level security;
alter table kb_brand_story enable row level security;
alter table kb_product_profiles enable row level security;
alter table kb_product_artists enable row level security;
alter table kb_entity_documents enable row level security;

-- Bucket privé pour les fichiers sources RAG (PDF, exports web, notes).
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;
