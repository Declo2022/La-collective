-- =============================================================================
-- African College — Tableaux de bord (agrégation unique pour Telegram / UI)
-- =============================================================================
-- fn_dashboard_snapshot() renvoie un JSON consolidé couvrant :
--   ventes, panier moyen, marges | trafic, conversion (GA4/GSC) |
--   coût IA, erreurs, dead-letters, tâches en attente | santé des services.
-- Source unique de vérité pour report-dashboard-daily-cron et toute UI.
-- Lecture seule, robuste aux tables vides (coalesce / left).

create or replace function fn_dashboard_snapshot()
returns jsonb language sql stable as $$
with sales as (
  select date, revenue, gross_margin
  from profitability_snapshots
  order by date desc limit 1
),
kpi as (
  select k.kpi_key, k.value
  from kpi_snapshots k
  where k.date = (select max(k2.date) from kpi_snapshots k2 where k2.kpi_key = k.kpi_key)
),
errors24 as (
  select
    count(*) filter (where level = 'error') as errors,
    count(*) filter (where level = 'warn')  as warnings
  from event_log
  where created_at > now() - interval '24 hours'
),
tasks_open as (
  select count(*) as pending
  from tasks t
  join task_states s on s.id = t.state_id
  where s.category not in ('completed', 'canceled')
),
deadletters as (select count(*) as open_dead from v_deadletter_open),
cost_today as (
  select coalesce(sum(amount_usd), 0) as spend
  from cost_ledger where occurred_on = current_date
),
health as (
  select
    count(*) filter (where status = 'ok')    as ok,
    count(*) filter (where status = 'error') as error,
    count(*)                                  as total
  from v_connection_health
)
select jsonb_build_object(
  'generated_at', now(),
  'ventes', jsonb_build_object(
    'date',             (select date from sales),
    'revenue_eur',      coalesce((select revenue from sales), 0),
    'aov_eur',          (select value from kpi where kpi_key = 'avg_order_value'),
    'gross_margin_eur', (select gross_margin from sales),
    'gross_margin_pct', case
      when coalesce((select revenue from sales), 0) > 0
      then round((select gross_margin from sales) / (select revenue from sales) * 100, 1)
      else null end
  ),
  'trafic', jsonb_build_object(
    'organic_clicks', (select value from kpi where kpi_key = 'organic_clicks'),
    'conversion_pct', (select value from kpi where kpi_key = 'conversion_rate'),
    'source',         'GA4/GSC (à brancher en Phase 2)'
  ),
  'operations', jsonb_build_object(
    'cost_today_usd',    (select spend from cost_today),
    'errors_24h',        (select errors from errors24),
    'warnings_24h',      (select warnings from errors24),
    'dead_letters_open', (select open_dead from deadletters),
    'tasks_pending',     (select pending from tasks_open)
  ),
  'sante_services', jsonb_build_object(
    'ok',       (select ok from health),
    'error',    (select error from health),
    'total',    (select total from health),
    'services', coalesce((select jsonb_object_agg(service, status) from v_connection_health), '{}'::jsonb)
  )
);
$$;

-- Vue pratique : un appel = un tableau de bord.
create or replace view v_dashboard_today as
select fn_dashboard_snapshot() as dashboard;
