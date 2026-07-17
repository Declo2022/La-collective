-- =============================================================================
-- African College — Moteur de contenu de marque (fondation SQL, testable)
-- =============================================================================
-- Le seul chantier BUILD : contenu différenciant depuis la KB/RAG.
-- fn_create_content_proposal : crée un brouillon de contenu -> proposition ->
-- ouvre la chaîne d'approbation (content_publish = CEO -> CTO -> humain).
-- La recherche vectorielle (fn_rag_search) est dans le fichier _rag (Supabase).

create or replace function fn_create_content_proposal(
  p_content_type      text,           -- product_description | article | interview | seo_meta
  p_title             text,
  p_body              text,
  p_target_shopify_id bigint default null,
  p_agent_run_id      uuid default null,
  p_cost_usd          numeric default 0,
  p_sources           jsonb default '[]'   -- chunks/documents cités (provenance RAG)
) returns jsonb as $$
declare v_prop uuid; v_appr jsonb;
begin
  insert into proposals(agent_run_id, type, target_type, target_shopify_id, summary, payload, status)
  values (p_agent_run_id, 'content_publish', 'content', p_target_shopify_id, p_title,
    jsonb_build_object('content_type', p_content_type, 'title', p_title, 'body', p_body, 'sources', p_sources),
    'draft')
  returning id into v_prop;

  -- Approbation obligatoire avant publication (jamais d'auto-publication).
  v_appr := fn_open_approval(v_prop, 'content_publish', p_cost_usd);

  return jsonb_build_object('proposal_id', v_prop, 'approval', v_appr);
end;
$$ language plpgsql;

-- Vue : brouillons de contenu en attente de validation.
create or replace view v_content_pending as
  select ar.id as request_id, p.id as proposal_id,
         p.payload->>'content_type' as content_type,
         p.payload->>'title' as title,
         ar.current_step, ar.cost_usd, ar.created_at
  from approval_requests ar
  join proposals p on p.id = ar.proposal_id
  where ar.status = 'pending' and p.type = 'content_publish'
  order by ar.created_at;
