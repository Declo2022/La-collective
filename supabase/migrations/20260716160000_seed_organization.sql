-- =============================================================================
-- African College — Seed de configuration : l'organisation
-- =============================================================================
-- Données de configuration (pas un workflow) : 8 agents, 2 humains, chaînes
-- d'approbation, équipes, états, KPI. Idempotent (ON CONFLICT DO NOTHING).
-- Les agents sont enabled=false : définis mais inactifs jusqu'à la Phase 2.

-- ---------------------------------------------------------------------------
-- Les 8 agents (id déterministes pour les références d'approbation).
-- Budget total ≈ 500k tokens/j (plafond serré de démarrage).
-- ---------------------------------------------------------------------------
insert into agents (id, name, role, description, enabled, config) values
('a0000000-0000-4000-8000-000000000001', 'CEO', 'Orchestration & stratégie',
 'Traduit la vision en objectifs et coordonne les agents.', false,
 jsonb_build_object('team','EXE','token_budget_daily',80000,'api_calls_daily',120,
   'tools', jsonb_build_array('tasks','kpi_read','event_log_read'),
   'memory', jsonb_build_array('semantic','episodic'),
   'prompt', $p$Tu es le CEO IA d'African College, marque culturelle portée par un collectif d'artistes. Transforme la vision du fondateur en objectifs mesurables et coordonne les agents : priorise, arbitre, valide le travail interne. Tu ne touches jamais Shopify directement et respectes strictement les budgets et l'approbation finale de Claude Rivel. Décide avec les données, reste fidèle à l'ADN de la marque, documente chaque décision.$p$)),
('a0000000-0000-4000-8000-000000000002', 'CTO', 'Intégrité technique',
 'Garantit données, workflows, mémoire/RAG et sécurité.', false,
 jsonb_build_object('team','EXE','token_budget_daily',60000,'api_calls_daily',200,
   'tools', jsonb_build_array('workflow_registry','metrics_read','job_queue','memory_admin'),
   'memory', jsonb_build_array('procedural','semantic'),
   'prompt', $p$Tu es le CTO IA d'African College. Garantis l'intégrité technique : données fiables, workflows sains, mémoire/RAG performants, sécurité respectée. Supervise le registre des workflows et le monitoring, valide techniquement les actions avant l'humain, escalade à l'Administrateur système tout risque d'infrastructure. Tu ne déploies rien de critique sans validation humaine et n'accèdes jamais aux secrets en clair.$p$)),
('a0000000-0000-4000-8000-000000000003', 'Directeur Artistique', 'Direction artistique',
 'Cohérence visuelle et excellence esthétique.', false,
 jsonb_build_object('team','DSG','token_budget_daily',40000,'image_quota_daily',30,
   'tools', jsonb_build_array('image_generation','storage_product_media','kb_read'),
   'memory', jsonb_build_array('semantic','procedural'),
   'prompt', $p$Tu es le Directeur Artistique IA d'African College, marque culturelle d'un collectif d'artistes. Conçois et curate des visuels fidèles à l'ADN de la marque. Produis des propositions, jamais publiées sans validation. Respecte la charte, cite tes références (KB), reste sobre et cohérent.$p$)),
('a0000000-0000-4000-8000-000000000004', 'Responsable E-commerce', 'Catalogue & merchandising',
 'Optimise catalogue, merchandising et conversion.', false,
 jsonb_build_object('team','ECM','token_budget_daily',70000,'api_calls_daily',200,
   'tools', jsonb_build_array('shopify_read','propose_mutation','sales_analytics'),
   'memory', jsonb_build_array('semantic','episodic'),
   'prompt', $p$Tu es le Responsable E-commerce Shopify IA d'African College. Optimise catalogue, merchandising et conversion. Prépare des propositions de changements toujours soumises à validation — jamais d'écriture directe. Base-toi sur les ventes et le stock réels, protège la marge et l'expérience client.$p$)),
('a0000000-0000-4000-8000-000000000005', 'Growth & Marketing', 'Acquisition & rétention',
 'Développe acquisition, engagement et rétention.', false,
 jsonb_build_object('team','GRW','token_budget_daily',60000,'api_calls_daily',150,
   'tools', jsonb_build_array('ga4_read','propose_campaign','propose_discount'),
   'memory', jsonb_build_array('episodic','semantic'),
   'prompt', $p$Tu es le Growth & Marketing IA d'African College. Développe l'acquisition et la rétention par des campagnes cohérentes avec la marque. Propose (jamais n'exécute) campagnes et promotions, sous validation budgétaire. Décide avec les données GA4 et la rentabilité, respecte le budget.$p$)),
('a0000000-0000-4000-8000-000000000006', 'SEO & Content', 'Visibilité & récit',
 'Visibilité organique et contenu narratif.', false,
 jsonb_build_object('team','CNT','token_budget_daily',100000,'api_calls_daily',200,
   'tools', jsonb_build_array('rag','kb_read','gsc_read','propose_content'),
   'memory', jsonb_build_array('semantic','procedural','rag'),
   'prompt', $p$Tu es le SEO & Content IA d'African College, marque culturelle. Écris le récit de la marque à partir de la base de connaissances et du RAG — toujours sourcé, jamais inventé. Optimise pour la recherche. Propose ; ne publie pas sans validation. Respecte le ton et cite tes sources internes.$p$)),
('a0000000-0000-4000-8000-000000000007', 'Community Manager', 'Réseaux & communauté',
 'Anime et fait grandir la communauté.', false,
 jsonb_build_object('team','COM','token_budget_daily',40000,'api_calls_daily',150,
   'tools', jsonb_build_array('generate_post','kb_read','propose_publication'),
   'memory', jsonb_build_array('episodic','semantic'),
   'prompt', $p$Tu es le Community Manager IA d'African College. Anime la communauté autour des artistes et de l'histoire de la marque. Propose posts et réponses (jamais publiés sans validation), fidèles au ton. Escalade au Service Client toute demande SAV et à un humain tout sujet sensible.$p$)),
('a0000000-0000-4000-8000-000000000008', 'Service Client', 'Support & rétention',
 'Support rapide, empathique et fidèle à la marque.', false,
 jsonb_build_object('team','SUP','token_budget_daily',50000,'api_calls_daily',300,
   'tools', jsonb_build_array('orders_read','customers_read_scoped','generate_reply','propose_gesture'),
   'memory', jsonb_build_array('episodic','semantic','rag'),
   'prompt', $p$Tu es le Service Client IA d'African College. Réponds avec empathie et précision, fidèle au ton de la marque, en t'appuyant sur les commandes et les politiques (KB). Propose réponses et gestes commerciaux — jamais exécutés sans validation. Trace tout accès aux données client et escalade les cas sensibles à un humain.$p$))
on conflict (name) do nothing;

-- ---------------------------------------------------------------------------
-- Les 2 rôles humains.
-- ---------------------------------------------------------------------------
insert into people (id, name, email, telegram_chat_id, role, active) values
('b0000000-0000-4000-8000-000000000001', 'Claude Rivel', null, null, 'founder_final_approver', true),
('b0000000-0000-4000-8000-000000000002', 'Administrateur système', null, null, 'sysadmin', true)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Chaînes d'approbation.
-- ---------------------------------------------------------------------------
insert into approval_chains (id, key, name, description) values
('c0000000-0000-4000-8000-000000000001', 'shopify_write', 'Écriture Shopify', 'CEO → CTO → humain (Claude Rivel)'),
('c0000000-0000-4000-8000-000000000002', 'external_publish', 'Publication externe / dépense', 'CEO → humain (Claude Rivel)')
on conflict (key) do nothing;

insert into approval_steps (chain_id, step_order, approver_type, approver_role, required) values
('c0000000-0000-4000-8000-000000000001', 1, 'agent', 'CEO', true),
('c0000000-0000-4000-8000-000000000001', 2, 'agent', 'CTO', true),
('c0000000-0000-4000-8000-000000000001', 3, 'human', 'human', true),
('c0000000-0000-4000-8000-000000000002', 1, 'agent', 'CEO', true),
('c0000000-0000-4000-8000-000000000002', 2, 'human', 'human', true)
on conflict (chain_id, step_order) do nothing;

-- Politiques : chaque type d'action → une chaîne. Écritures Shopify = humain requis.
insert into approval_policies (action_type, chain_id, requires_human, risk_level) values
('shopify_product_update',    'c0000000-0000-4000-8000-000000000001', true, 'high'),
('shopify_collection_update', 'c0000000-0000-4000-8000-000000000001', true, 'high'),
('price_change',              'c0000000-0000-4000-8000-000000000001', true, 'high'),
('content_publish',           'c0000000-0000-4000-8000-000000000001', true, 'high'),
('social_post',               'c0000000-0000-4000-8000-000000000002', true, 'medium'),
('promo_discount',            'c0000000-0000-4000-8000-000000000002', true, 'high'),
('campaign_spend',            'c0000000-0000-4000-8000-000000000002', true, 'high'),
('support_refund',            'c0000000-0000-4000-8000-000000000002', true, 'medium')
on conflict (action_type) do nothing;

-- ---------------------------------------------------------------------------
-- Équipes & états de tâches (états standard par équipe).
-- ---------------------------------------------------------------------------
insert into task_teams (key, name, description) values
('EXE', 'Direction', 'CEO & CTO'),
('DSG', 'Création', 'Directeur Artistique'),
('ECM', 'E-commerce', 'Responsable E-commerce Shopify'),
('GRW', 'Growth', 'Growth & Marketing'),
('CNT', 'Contenu', 'SEO & Content'),
('COM', 'Communauté', 'Community Manager'),
('SUP', 'Support', 'Service Client')
on conflict (key) do nothing;

insert into task_states (team_id, key, name, category, position)
select t.id, s.key, s.name, s.category, s.position
from task_teams t
cross join (values
  ('backlog',     'Backlog',   'backlog',    1),
  ('todo',        'Todo',      'unstarted',  2),
  ('in_progress', 'En cours',  'started',    3),
  ('in_review',   'En revue',  'started',    4),
  ('blocked',     'Bloquée',   'started',    5),
  ('done',        'Terminée',  'completed',  6),
  ('canceled',    'Annulée',   'canceled',   7)
) as s(key, name, category, position)
on conflict (team_id, key) do nothing;

-- ---------------------------------------------------------------------------
-- Définitions de KPI.
-- ---------------------------------------------------------------------------
insert into kpi_definitions (key, name, unit, target, direction) values
('daily_revenue',       'CA quotidien',            'EUR',   null, 'up_good'),
('gross_margin',        'Marge brute',             '%',     null, 'up_good'),
('ai_cost_daily',       'Coût IA quotidien',       'EUR',   20,   'down_good'),
('conversion_rate',     'Taux de conversion',      '%',     null, 'up_good'),
('avg_order_value',     'Panier moyen',            'EUR',   null, 'up_good'),
('stockout_rate',       'Taux de rupture',         '%',     null, 'down_good'),
('organic_clicks',      'Clics organiques',        'count', null, 'up_good'),
('avg_position',        'Position moyenne SEO',    'rank',  null, 'down_good'),
('task_throughput',     'Tâches terminées / jour', 'count', null, 'up_good'),
('first_response_time', 'Temps 1re réponse SAV',   'min',   null, 'down_good'),
('csat',                'Satisfaction client',     '%',     null, 'up_good'),
('cac',                 'Coût d''acquisition',     'EUR',   null, 'down_good'),
('roas',                'ROAS',                    'ratio', null, 'up_good'),
('follower_growth',     'Croissance abonnés',      '%',     null, 'up_good'),
('engagement_rate',     'Taux d''engagement',      '%',     null, 'up_good')
on conflict (key) do nothing;
