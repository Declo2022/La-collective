-- =============================================================================
-- African College — Renforcement · RAG documentaire
-- =============================================================================
-- Pipeline : documents -> chunks -> embeddings 1536 -> recherche cosine (HNSW).

create table documents (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  source_type  text,                 -- pdf | web | note | interview | manual
  source_uri   text,
  entity_type  text,                 -- artist | interview | brand_story | product | generic
  entity_id    uuid,
  checksum     text,                 -- empreinte pour éviter la re-ingestion
  status       text not null default 'pending'
                 check (status in ('pending', 'chunked', 'embedded', 'failed')),
  metadata     jsonb not null default '{}',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create unique index idx_documents_checksum on documents (checksum) where checksum is not null;

create table document_chunks (
  id           uuid primary key default gen_random_uuid(),
  document_id  uuid not null references documents(id) on delete cascade,
  chunk_index  int not null,
  content      text not null,
  embedding    vector(1536),         -- text-embedding-3-large tronqué à 1536
  tokens       int,
  metadata     jsonb not null default '{}',
  created_at   timestamptz not null default now(),
  unique (document_id, chunk_index)
);
create index idx_chunks_document on document_chunks (document_id);
create index idx_chunks_embedding on document_chunks using hnsw (embedding vector_cosine_ops);
