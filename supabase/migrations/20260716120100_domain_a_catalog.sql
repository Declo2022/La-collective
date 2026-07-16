-- =============================================================================
-- African College — Phase 1 · Domaine A : Catalogue (miroir Shopify)
-- =============================================================================
-- Source de vérité = Shopify. Supabase en est le miroir analytique.
-- Toutes les tables portent shopify_id (unique) pour un upsert idempotent.

create table products (
  id                  uuid primary key default gen_random_uuid(),
  shopify_id          bigint not null unique,
  handle              text,
  title               text not null,
  status              text,                 -- active | draft | archived
  product_type        text,
  vendor              text,
  tags                text[] not null default '{}',
  body_html           text,
  seo_title           text,
  seo_description     text,
  shopify_created_at  timestamptz,
  shopify_updated_at  timestamptz,
  synced_at           timestamptz not null default now(),
  raw                 jsonb
);
comment on table products is 'Miroir des produits Shopify (source de vérité = Shopify).';
comment on column products.raw is 'Charge Shopify brute — filet de sécurité rejouable si un champ manque.';

create table product_variants (
  id                  uuid primary key default gen_random_uuid(),
  shopify_id          bigint not null unique,
  product_id          uuid not null references products(id) on delete cascade,
  sku                 text,
  title               text,
  price               numeric(12,2),
  compare_at_price    numeric(12,2),
  inventory_item_id   bigint,
  position            int,
  shopify_updated_at  timestamptz,
  synced_at           timestamptz not null default now()
);

create table collections (
  id                  uuid primary key default gen_random_uuid(),
  shopify_id          bigint not null unique,
  handle              text,
  title               text,
  description         text,
  collection_type     text,                 -- custom | smart
  shopify_updated_at  timestamptz,
  synced_at           timestamptz not null default now()
);

create table product_collections (
  product_id     uuid not null references products(id) on delete cascade,
  collection_id  uuid not null references collections(id) on delete cascade,
  primary key (product_id, collection_id)
);

create table locations (
  id            uuid primary key default gen_random_uuid(),
  shopify_id    bigint not null unique,
  name          text,
  active        boolean not null default true,
  country_code  text,
  synced_at     timestamptz not null default now()
);

create table inventory_levels (
  id                  uuid primary key default gen_random_uuid(),
  variant_id          uuid not null references product_variants(id) on delete cascade,
  location_id         uuid not null references locations(id) on delete cascade,
  available           int,
  shopify_updated_at  timestamptz,
  synced_at           timestamptz not null default now(),
  unique (variant_id, location_id)
);
