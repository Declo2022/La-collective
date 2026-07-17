-- =============================================================================
-- African College — Workflow #2 · Analyse ventes & marges (moteur SQL)
-- =============================================================================
-- La marge exige un coût d'achat (COGS) : ajout de product_variants.unit_cost,
-- alimenté par import CSV (fn_import_variant_costs) OU par le champ Shopify
-- InventoryItem.unitCost (lu par le workflow n8n). Sans coût -> marge non
-- calculée sur ces lignes (transparence via cost_coverage_pct).

alter table product_variants
  add column if not exists unit_cost numeric(12,2);

-- Import de coûts : tableau [{sku, unit_cost}, ...] (CSV -> jsonb -> ici).
create or replace function fn_import_variant_costs(p jsonb)
returns int as $$
declare r jsonb; n int := 0;
begin
  for r in select value from jsonb_array_elements(coalesce(p, '[]'::jsonb)) loop
    update product_variants set unit_cost = nullif(r->>'unit_cost', '')::numeric
     where sku = r->>'sku';
    if found then n := n + 1; end if;
  end loop;
  return n;
end;
$$ language plpgsql;

-- Rapport ventes & marges sur une fenêtre (par défaut : 7 derniers jours).
create or replace function fn_sales_margin_report(
  p_from date default (current_date - 7), p_to date default (current_date - 1)
) returns jsonb as $$
declare v_rev numeric; v_cogs numeric; v_known_rev numeric; v_units int;
        v_gm numeric; v_pct numeric; v_cov numeric; v_top jsonb; v_low jsonb;
begin
  select coalesce(sum(q.line_rev), 0),
         coalesce(sum(q.line_cost), 0),
         coalesce(sum(q.line_rev) filter (where q.line_cost is not null), 0),
         coalesce(sum(q.quantity), 0)
    into v_rev, v_cogs, v_known_rev, v_units
  from (
    select oli.quantity, oli.quantity * oli.price as line_rev,
           case when pv.unit_cost is not null then oli.quantity * pv.unit_cost end as line_cost
    from order_line_items oli
    join orders o on o.id = oli.order_id
    left join product_variants pv on pv.sku = oli.sku
    where coalesce(o.processed_at, o.shopify_created_at)::date between p_from and p_to
      and coalesce(o.financial_status, '') not in ('refunded', 'partially_refunded')
  ) q;

  v_gm  := v_known_rev - v_cogs;
  v_pct := case when v_known_rev > 0 then round(100 * v_gm / v_known_rev, 1) else null end;
  v_cov := case when v_rev > 0 then round(100 * v_known_rev / v_rev, 1) else 0 end;

  select coalesce(jsonb_agg(x), '[]'::jsonb) into v_top from (
    select oli.title, oli.sku,
           sum(oli.quantity * oli.price) as revenue,
           sum(oli.quantity * oli.price) - coalesce(sum(oli.quantity * pv.unit_cost), 0) as margin
    from order_line_items oli
    join orders o on o.id = oli.order_id
    left join product_variants pv on pv.sku = oli.sku
    where coalesce(o.processed_at, o.shopify_created_at)::date between p_from and p_to
      and coalesce(o.financial_status, '') not in ('refunded', 'partially_refunded')
    group by oli.title, oli.sku
    order by margin desc limit 5
  ) x;

  select coalesce(jsonb_agg(x), '[]'::jsonb) into v_low from (
    select oli.title, oli.sku,
           sum(oli.quantity * oli.price) as revenue,
           sum(oli.quantity * oli.price) - coalesce(sum(oli.quantity * pv.unit_cost), 0) as margin
    from order_line_items oli
    join orders o on o.id = oli.order_id
    left join product_variants pv on pv.sku = oli.sku
    where coalesce(o.processed_at, o.shopify_created_at)::date between p_from and p_to
      and coalesce(o.financial_status, '') not in ('refunded', 'partially_refunded')
    group by oli.title, oli.sku
    order by margin asc limit 5
  ) x;

  insert into kpi_snapshots(kpi_key, date, value) values ('gross_margin', p_to, coalesce(v_pct, 0))
    on conflict (kpi_key, date, dimension) do update set value = excluded.value;

  return jsonb_build_object(
    'from', p_from, 'to', p_to, 'revenue', v_rev, 'cogs', v_cogs,
    'gross_margin', v_gm, 'gross_margin_pct', v_pct, 'cost_coverage_pct', v_cov,
    'units', v_units, 'top_by_margin', v_top, 'low_by_margin', v_low);
end;
$$ language plpgsql;
