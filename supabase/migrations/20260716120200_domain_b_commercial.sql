-- =============================================================================
-- African College — Phase 1 · Domaine B : Commercial
-- =============================================================================
-- PII minimisée (décision Phase 1) : email HACHÉ, pas d'email en clair.
-- Le hachage (SHA-256 de l'email normalisé) est calculé à l'ingestion (n8n).

create table customers (
  id                  uuid primary key default gen_random_uuid(),
  shopify_id          bigint not null unique,
  email_hash          text,                 -- SHA-256 de l'email normalisé (jamais d'email en clair)
  first_name          text,
  last_name           text,
  orders_count        int not null default 0,
  total_spent         numeric(12,2) not null default 0,
  tags                text[] not null default '{}',
  accepts_marketing   boolean not null default false,
  shopify_created_at  timestamptz,
  synced_at           timestamptz not null default now()
);
comment on column customers.email_hash is 'SHA-256 de l''email normalisé — PII pseudonymisée (décision Phase 1).';

create table orders (
  id                  uuid primary key default gen_random_uuid(),
  shopify_id          bigint not null unique,
  order_number        int,
  customer_id         uuid references customers(id) on delete set null,
  financial_status    text,
  fulfillment_status  text,
  currency            text,
  subtotal_price      numeric(12,2),
  total_tax           numeric(12,2),
  total_discounts     numeric(12,2),
  total_price         numeric(12,2),
  processed_at        timestamptz,
  shopify_created_at  timestamptz,
  synced_at           timestamptz not null default now(),
  raw                 jsonb
);

create table order_line_items (
  id          uuid primary key default gen_random_uuid(),
  order_id    uuid not null references orders(id) on delete cascade,
  variant_id  uuid references product_variants(id) on delete set null,
  product_id  uuid references products(id) on delete set null,
  title       text,
  sku         text,
  quantity    int,
  price       numeric(12,2)
);
