-- =============================================================================
-- African College — Workflow #1 · Rapport Shopify quotidien (moteur SQL)
-- =============================================================================
-- Lecture seule Shopify côté n8n → upsert local → agrégats SQL (déterministes).
-- L'IA ne résume que des chiffres déjà calculés (coût minimal).
--   fn_upsert_shopify_orders(jsonb) : lecture Shopify -> orders/order_line_items
--   fn_daily_shopify_report(date)   : agrégats du jour + kpi_snapshots

-- ---------------------------------------------------------------------------
-- Upsert d'un tableau de commandes Shopify (payload REST) dans le miroir local.
-- Idempotent (clé shopify_id). Aucune écriture VERS Shopify.
-- ---------------------------------------------------------------------------
create or replace function fn_upsert_shopify_orders(p_orders jsonb)
returns int as $$
declare o jsonb; li jsonb; v_order_id uuid; n int := 0;
begin
  for o in select value from jsonb_array_elements(coalesce(p_orders, '[]'::jsonb)) loop
    insert into orders(shopify_id, order_number, financial_status, fulfillment_status, currency,
      subtotal_price, total_tax, total_discounts, total_price, processed_at, shopify_created_at, raw)
    values (
      (o->>'id')::bigint,
      nullif(o->>'order_number', '')::int,
      o->>'financial_status',
      o->>'fulfillment_status',
      o->>'currency',
      nullif(o->>'subtotal_price', '')::numeric,
      nullif(o->>'total_tax', '')::numeric,
      nullif(o->>'total_discounts', '')::numeric,
      nullif(o->>'total_price', '')::numeric,
      nullif(o->>'processed_at', '')::timestamptz,
      nullif(o->>'created_at', '')::timestamptz,
      o
    )
    on conflict (shopify_id) do update set
      financial_status   = excluded.financial_status,
      fulfillment_status = excluded.fulfillment_status,
      total_price        = excluded.total_price,
      subtotal_price     = excluded.subtotal_price,
      total_tax          = excluded.total_tax,
      total_discounts    = excluded.total_discounts,
      processed_at       = excluded.processed_at,
      raw                = excluded.raw,
      synced_at          = now()
    returning id into v_order_id;

    delete from order_line_items where order_id = v_order_id;
    for li in select value from jsonb_array_elements(coalesce(o->'line_items', '[]'::jsonb)) loop
      insert into order_line_items(order_id, title, sku, quantity, price)
      values (v_order_id, li->>'title', li->>'sku',
              nullif(li->>'quantity', '')::int, nullif(li->>'price', '')::numeric);
    end loop;
    n := n + 1;
  end loop;
  return n;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Rapport agrégé du jour (par défaut : la veille) + écriture des KPI.
-- ---------------------------------------------------------------------------
create or replace function fn_daily_shopify_report(p_date date default (current_date - 1))
returns jsonb as $$
declare v_orders int; v_revenue numeric; v_aov numeric; v_refunds int; v_top jsonb;
begin
  select count(*), coalesce(sum(total_price), 0)
    into v_orders, v_revenue
    from orders
   where coalesce(processed_at, shopify_created_at)::date = p_date;

  v_aov := case when v_orders > 0 then round(v_revenue / v_orders, 2) else 0 end;

  select count(*) into v_refunds
    from orders
   where coalesce(processed_at, shopify_created_at)::date = p_date
     and financial_status in ('refunded', 'partially_refunded');

  select coalesce(jsonb_agg(t), '[]'::jsonb) into v_top
  from (
    select coalesce(oli.title, '?') as title, oli.sku, sum(oli.quantity) as qty
    from order_line_items oli
    join orders o on o.id = oli.order_id
    where coalesce(o.processed_at, o.shopify_created_at)::date = p_date
    group by oli.title, oli.sku
    order by sum(oli.quantity) desc
    limit 5
  ) t;

  -- KPI (idempotent)
  insert into kpi_snapshots(kpi_key, date, value) values ('daily_revenue', p_date, v_revenue)
    on conflict (kpi_key, date, dimension) do update set value = excluded.value;
  insert into kpi_snapshots(kpi_key, date, value) values ('avg_order_value', p_date, v_aov)
    on conflict (kpi_key, date, dimension) do update set value = excluded.value;

  return jsonb_build_object('date', p_date, 'orders', v_orders, 'revenue', v_revenue,
    'aov', v_aov, 'refunds', v_refunds, 'top_products', v_top);
end;
$$ language plpgsql;
