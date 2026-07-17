-- =============================================================================
-- African College — Moteur de contenu · recherche RAG (Supabase, pgvector)
-- =============================================================================
-- Recherche sémantique des chunks pertinents pour nourrir la génération.
-- Nécessite pgvector (opérateur <=> cosine). Validé sur Supabase, pas en local.

create or replace function fn_rag_search(
  p_embedding vector(1536), p_k int default 6, p_entity_type text default null
) returns table(chunk_id uuid, document_id uuid, content text, similarity double precision) as $$
  select dc.id, dc.document_id, dc.content,
         1 - (dc.embedding <=> p_embedding) as similarity
  from document_chunks dc
  join documents d on d.id = dc.document_id
  where (p_entity_type is null or d.entity_type = p_entity_type)
    and dc.embedding is not null
  order by dc.embedding <=> p_embedding
  limit p_k;
$$ language sql stable;
