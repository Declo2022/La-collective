-- =============================================================================
-- African College — Phase 1 · Index
-- =============================================================================
-- Trois familles : unicité (via contraintes ci-avant), accès, et vectoriel.

-- Domaine A — Catalogue
create index idx_products_status on products (status);
create index idx_products_handle on products (handle);
create index idx_products_tags on products using gin (tags);
create index idx_variants_sku on product_variants (sku);
create index idx_variants_product on product_variants (product_id);
create index idx_inventory_variant on inventory_levels (variant_id);

-- Domaine B — Commercial
create index idx_orders_processed on orders (processed_at);
create index idx_orders_customer on orders (customer_id);
create index idx_oli_order on order_line_items (order_id);
create index idx_oli_product on order_line_items (product_id);
create index idx_customers_email_hash on customers (email_hash);

-- Domaine C — Mesure
create index idx_ga4_date on ga4_daily (date);
create index idx_gsc_date on gsc_daily (date);
create index idx_gsc_query on gsc_daily (query);
create index idx_clarity_date on clarity_daily (date);

-- Domaine D — Agents
create index idx_agent_runs_status on agent_runs (status);
create index idx_proposals_status on proposals (status);
-- Recherche sémantique (cosine). HNSW : bon rappel, requêtes rapides.
create index idx_agent_memory_embedding on agent_memory using hnsw (embedding vector_cosine_ops);

-- Domaine E — Ops
create index idx_webhook_topic_status on webhook_events (topic, status);
create index idx_webhook_shopify_id on webhook_events (shopify_id);
create index idx_audit_created on audit_log (created_at);
