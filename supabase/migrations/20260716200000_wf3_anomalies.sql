-- =============================================================================
-- African College — Workflow #3 · Détection d'anomalies (moteur SQL)
-- =============================================================================
-- 100% SQL déterministe (aucun appel LLM → coût nul). Détecte :
--   - commandes inhabituelles (montant élevé)
--   - remboursements
--   - variantes à prix nul/absent
--   - ruptures de stock
--   - produits actifs sans vente depuis N jours
-- Insère une alerte si anomalies. Aucune écriture Shopify.

create or replace function fn_detect_anomalies(p_days int default 30, p_high_value numeric default 500)
returns jsonb as $$
declare items jsonb := '[]'::jsonb; v jsonb;
begin
  -- Commandes inhabituelles (montant élevé), la veille.
  select coalesce(jsonb_agg(jsonb_build_object('type', 'unusual_order', 'order', shopify_id, 'total', total_price)), '[]')
    into v from orders
   where coalesce(processed_at, shopify_created_at)::date = current_date - 1
     and total_price > p_high_value;
  items := items || v;

  -- Remboursements, la veille.
  select coalesce(jsonb_agg(jsonb_build_object('type', 'refund', 'order', shopify_id, 'status', financial_status)), '[]')
    into v from orders
   where coalesce(processed_at, shopify_created_at)::date = current_date - 1
     and financial_status in ('refunded', 'partially_refunded');
  items := items || v;

  -- Variantes à prix nul ou absent.
  select coalesce(jsonb_agg(jsonb_build_object('type', 'zero_price', 'variant', shopify_id, 'sku', sku)), '[]')
    into v from product_variants where price is null or price = 0;
  items := items || v;

  -- Ruptures de stock.
  select coalesce(jsonb_agg(jsonb_build_object('type', 'stockout', 'variant', variant_id, 'available', available)), '[]')
    into v from inventory_levels where available is not null and available <= 0;
  items := items || v;

  -- Produits actifs sans vente depuis p_days (match par SKU variante).
  select coalesce(jsonb_agg(jsonb_build_object('type', 'no_sales', 'product', p.shopify_id, 'title', p.title)), '[]')
    into v from products p
   where p.status = 'active'
     and not exists (
       select 1 from product_variants pv
       join order_line_items oli on oli.sku = pv.sku
       join orders o on o.id = oli.order_id
       where pv.product_id = p.id
         and coalesce(o.processed_at, o.shopify_created_at) >= now() - (p_days || ' days')::interval
     );
  items := items || v;

  if jsonb_array_length(items) > 0 then
    insert into alerts(severity, title, body, status, payload)
    values ('warn', 'Anomalies détectées (' || jsonb_array_length(items) || ')',
      'Détail dans le payload.', 'firing', jsonb_build_object('items', items));
    perform fn_log_event('tool_call', 'anomalies_detected', 'workflow', null, 'monitor-anomalies-cron',
      null, null, null, 'warn', null, null, null, null, jsonb_build_object('count', jsonb_array_length(items)));
  end if;

  return jsonb_build_object('count', jsonb_array_length(items), 'items', items);
end;
$$ language plpgsql;
