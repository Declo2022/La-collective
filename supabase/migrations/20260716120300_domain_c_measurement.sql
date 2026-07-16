-- =============================================================================
-- African College — Phase 1 · Domaine C : Mesure (agrégats quotidiens)
-- =============================================================================
-- Alimenté par des pulls planifiés (GA4 / Search Console / Clarity).
-- Clés d'unicité = idempotence des pulls (rejeu sans doublon).
-- Pas de FK vers le catalogue : jointure souple sur date / page_path à l'analyse.

create table ga4_daily (
  id             uuid primary key default gen_random_uuid(),
  date           date not null,
  page_path      text not null default '',
  source_medium  text not null default '',
  sessions       int,
  total_users    int,
  engaged_sessions int,
  conversions    numeric,
  revenue        numeric(12,2),
  pulled_at      timestamptz not null default now(),
  unique (date, page_path, source_medium)
);

create table gsc_daily (
  id           uuid primary key default gen_random_uuid(),
  date         date not null,
  query        text not null default '',
  page         text not null default '',
  clicks       int,
  impressions  int,
  ctr          numeric,
  position     numeric,
  pulled_at    timestamptz not null default now(),
  unique (date, query, page)
);

create table clarity_daily (
  id                uuid primary key default gen_random_uuid(),
  date              date not null,
  page_path         text not null default '',
  sessions          int,
  dead_clicks       int,
  rage_clicks       int,
  excessive_scroll  int,
  quickback_clicks  int,
  avg_scroll_depth  numeric,
  pulled_at         timestamptz not null default now(),
  unique (date, page_path)
);
