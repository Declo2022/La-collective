-- =============================================================================
-- African College — Activation progressive & gardée des agents
-- =============================================================================
-- Règle : un agent ne peut être activé que si les connexions critiques sont
-- vertes (fn_activation_ready). fn_enable_agent applique ce garde-fou et trace.
-- fn_activate_wave active un lot d'agents (activation progressive par vagues).

-- Prêt à activer si aucun service critique n'est en erreur ET que les 4 socles
-- (shopify, supabase, telegram, openai) sont au vert dans v_connection_health.
create or replace function fn_activation_ready()
returns boolean language sql stable as $$
  select
    not exists (select 1 from v_connection_health where status = 'error')
    and (select count(*) from v_connection_health
         where service in ('shopify', 'supabase', 'telegram', 'openai')
           and status = 'ok') >= 4;
$$;

-- Active un agent par nom, uniquement si les connexions sont prêtes.
create or replace function fn_enable_agent(p_name text)
returns boolean language plpgsql as $$
declare v_found int;
begin
  if not fn_activation_ready() then
    raise exception 'Activation refusée : connexions non vertes (voir v_connection_health).';
  end if;
  update agents set enabled = true where name = p_name;
  get diagnostics v_found = row_count;
  if v_found = 0 then
    raise exception 'Agent introuvable : %', p_name;
  end if;
  perform fn_log_event('agent_activation', 'enable', 'service', null,
    'agent-activation', null, 'agent', null, 'info', null, null, null, null,
    jsonb_build_object('agent', p_name));
  return true;
end;
$$;

-- Active une vague (1..4) d'agents. Ordre d'activation progressif :
--   1 = pilotage (lecture seule)          : CEO IA, Analytics Manager, Automation Manager
--   2 = e-commerce (lecture + propositions): Shopify Manager, Product Manager, Printful Manager
--   3 = contenu/SEO (propositions)         : SEO Manager, Content Writer, Design Manager
--   4 = externe/communauté/support         : Marketing Manager, Social Media Manager, Customer Support
create or replace function fn_activate_wave(p_wave int)
returns setof text language plpgsql as $$
declare v_names text[];
begin
  v_names := case p_wave
    when 1 then array['CEO IA', 'Analytics Manager', 'Automation Manager']
    when 2 then array['Shopify Manager', 'Product Manager', 'Printful Manager']
    when 3 then array['SEO Manager', 'Content Writer', 'Design Manager']
    when 4 then array['Marketing Manager', 'Social Media Manager', 'Customer Support']
    else null end;
  if v_names is null then
    raise exception 'Vague inconnue : % (attendu 1..4)', p_wave;
  end if;
  return query
    select n from unnest(v_names) as n
    where fn_enable_agent(n);  -- lève si connexions non prêtes
end;
$$;
