-- =============================================================================
-- African College — Renforcement · Base de connaissances
-- =============================================================================
-- Marque culturelle / collectif d'artistes : le RÉCIT de la marque, structuré.
-- Chaque entité peut être reliée à ses documents RAG (kb_entity_documents).

create table kb_artists (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text unique,
  bio         text,
  country     text,
  active_from int,                   -- année de début d'activité
  active_to   int,
  links       jsonb not null default '{}',
  metadata    jsonb not null default '{}',
  created_at  timestamptz not null default now()
);

create table kb_interviews (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  artist_id     uuid references kb_artists(id) on delete set null,
  published_at  date,
  summary       text,
  body          text,
  source_uri    text,
  created_at    timestamptz not null default now()
);
create index idx_kb_interviews_artist on kb_interviews (artist_id);

create table kb_brand_story (
  id          uuid primary key default gen_random_uuid(),
  section     text not null,         -- histoire | valeurs | ton | manifeste
  title       text,
  body        text,
  position    int not null default 0,
  created_at  timestamptz not null default now()
);

create table kb_product_profiles (
  id                 uuid primary key default gen_random_uuid(),
  product_id         uuid not null unique references products(id) on delete cascade,
  story              text,
  materials          text,
  theme              text,
  primary_artist_id  uuid references kb_artists(id) on delete set null,
  metadata           jsonb not null default '{}',
  created_at         timestamptz not null default now()
);

create table kb_product_artists (
  product_id  uuid not null references products(id) on delete cascade,
  artist_id   uuid not null references kb_artists(id) on delete cascade,
  role        text,
  primary key (product_id, artist_id)
);

-- Lien polymorphe entité KB <-> document (provenance RAG)
create table kb_entity_documents (
  entity_type  text not null,        -- artist | interview | brand_story | product
  entity_id    uuid not null,
  document_id  uuid not null references documents(id) on delete cascade,
  primary key (entity_type, entity_id, document_id)
);
create index idx_kb_entity_docs_doc on kb_entity_documents (document_id);
