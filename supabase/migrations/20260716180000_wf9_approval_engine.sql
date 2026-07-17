-- =============================================================================
-- African College — Workflow #9 · Validation humaine (moteur d'approbation)
-- =============================================================================
-- Moteur GÉNÉRIQUE : fonctionne pour tout type d'action via approval_policies.
-- Ajouter une action commerciale = insérer une ligne dans approval_policies.
-- Chaque approbation enregistre : date, utilisateur, coût, résultat.
-- Aucune action commerciale ne s'exécute sans un fn_can_execute() = true.

-- Enrichissement de approval_requests (date via created_at ; utilisateur, coût, résultat).
alter table approval_requests
  add column if not exists action_type text,
  add column if not exists cost_usd    numeric(12,6) not null default 0,
  add column if not exists result      text not null default 'pending'
    check (result in ('pending', 'applied', 'failed', 'not_applicable')),
  add column if not exists resolved_at timestamptz,
  add column if not exists decided_by  text;

-- Politique pour l'e-mail (les autres actions commerciales sont déjà seedées).
insert into approval_policies (action_type, chain_id, requires_human, risk_level)
values ('email_send', (select id from approval_chains where key = 'external_publish'), true, 'medium')
on conflict (action_type) do nothing;

-- ---------------------------------------------------------------------------
-- Ouvre une demande d'approbation pour une proposition (selon sa politique).
-- Défaut le plus restrictif si aucune politique : chaîne shopify_write.
-- ---------------------------------------------------------------------------
create or replace function fn_open_approval(
  p_proposal_id uuid, p_action_type text, p_cost_usd numeric default 0
) returns jsonb as $$
declare v_chain uuid; v_req uuid;
begin
  select chain_id into v_chain from approval_policies
   where action_type = p_action_type and enabled;
  if v_chain is null then
    select id into v_chain from approval_chains where key = 'shopify_write';
  end if;

  insert into approval_requests(proposal_id, chain_id, action_type, current_step, status, cost_usd, result)
  values (p_proposal_id, v_chain, p_action_type, 1, 'pending', coalesce(p_cost_usd, 0), 'pending')
  returning id into v_req;

  update proposals set status = 'pending', updated_at = now() where id = p_proposal_id;

  perform fn_log_event('approval', 'open', 'system', null, null, null, 'proposal', p_proposal_id,
    'info', null, coalesce(p_cost_usd, 0), null, null,
    jsonb_build_object('request_id', v_req, 'action_type', p_action_type));

  return jsonb_build_object('request_id', v_req, 'chain_id', v_chain, 'current_step', 1,
    'next_approver', (select jsonb_build_object('type', approver_type, 'role', approver_role)
       from approval_steps where chain_id = v_chain and step_order = 1));
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Enregistre une décision (par étape). Avance la chaîne ou la clôt.
-- Écrit dans approval_decisions (immuable) ET audit_trail (hash chain).
-- ---------------------------------------------------------------------------
create or replace function fn_record_decision(
  p_request_id uuid, p_approver_type text, p_approver_id uuid, p_approver_role text,
  p_decision text, p_comment text default null
) returns jsonb as $$
declare r approval_requests; v_last int;
begin
  select * into r from approval_requests where id = p_request_id for update;
  if not found then return jsonb_build_object('error', 'request_not_found'); end if;
  if r.status <> 'pending' then
    return jsonb_build_object('error', 'not_pending', 'status', r.status);
  end if;

  insert into approval_decisions(request_id, step_order, approver_type, approver_id, approver_role, decision, comment)
  values (p_request_id, r.current_step, p_approver_type, p_approver_id, p_approver_role, p_decision, p_comment);

  insert into audit_trail(actor_type, actor_id, action, entity_type, entity_id, payload)
  values (p_approver_type, p_approver_id, 'approval_' || p_decision, 'approval_request', p_request_id,
    jsonb_build_object('step', r.current_step, 'role', p_approver_role, 'comment', p_comment));

  perform fn_log_event('approval', p_decision, p_approver_type, p_approver_id, null, null,
    'approval_request', p_request_id, 'info', null, null, null, null,
    jsonb_build_object('step', r.current_step, 'role', p_approver_role));

  if p_decision = 'rejected' then
    update approval_requests set status = 'rejected', resolved_at = now(),
      decided_by = coalesce(p_approver_role, p_approver_id::text) where id = p_request_id;
    update proposals set status = 'rejected', updated_at = now() where id = r.proposal_id;
    return jsonb_build_object('status', 'rejected');

  elsif p_decision = 'approved' then
    select coalesce(max(step_order), 1) into v_last from approval_steps where chain_id = r.chain_id;
    if r.current_step >= v_last then
      update approval_requests set status = 'approved', resolved_at = now(),
        decided_by = coalesce(p_approver_role, p_approver_id::text) where id = p_request_id;
      update proposals set status = 'approved', updated_at = now() where id = r.proposal_id;
      return jsonb_build_object('status', 'approved', 'ready_to_execute', true);
    else
      update approval_requests set current_step = r.current_step + 1 where id = p_request_id;
      return jsonb_build_object('status', 'pending', 'next_step', r.current_step + 1,
        'next_approver', (select jsonb_build_object('type', approver_type, 'role', approver_role)
           from approval_steps where chain_id = r.chain_id and step_order = r.current_step + 1));
    end if;

  else -- abstain
    return jsonb_build_object('status', 'pending', 'note', 'abstain_recorded');
  end if;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Garde-fou d'exécution : true SEULEMENT si la proposition est approuvée.
-- Toute action commerciale/Shopify DOIT appeler ceci avant de s'exécuter.
-- ---------------------------------------------------------------------------
create or replace function fn_can_execute(p_proposal_id uuid) returns boolean as $$
begin
  return exists (
    select 1 from approval_requests
    where proposal_id = p_proposal_id and status = 'approved'
  );
end;
$$ language plpgsql;

-- Enregistre le résultat d'exécution (le « résultat » de l'approbation).
create or replace function fn_record_execution_result(p_request_id uuid, p_result text)
returns void as $$
begin
  update approval_requests set result = p_result, resolved_at = coalesce(resolved_at, now())
  where id = p_request_id;
  insert into audit_trail(actor_type, action, entity_type, entity_id, payload)
  values ('system', 'execution_' || p_result, 'approval_request', p_request_id,
    jsonb_build_object('result', p_result));
end;
$$ language plpgsql;

-- Vue : approbations en attente (pour le tableau de bord / Telegram).
create or replace view v_pending_approvals as
  select ar.id as request_id, ar.proposal_id, ar.action_type, ar.current_step,
         ar.cost_usd, ar.created_at,
         s.approver_type, s.approver_role,
         p.summary
  from approval_requests ar
  left join approval_steps s on s.chain_id = ar.chain_id and s.step_order = ar.current_step
  left join proposals p on p.id = ar.proposal_id
  where ar.status = 'pending'
  order by ar.created_at;
