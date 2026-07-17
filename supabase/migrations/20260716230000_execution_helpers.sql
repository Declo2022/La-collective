-- =============================================================================
-- African College — Helpers d'exécution (publication, notifications, jobs)
-- =============================================================================
-- Complète la boucle : publication de contenu APRÈS approbation (gated),
-- livraison fiable des notifications (outbox), et helpers de garde.

-- ---------------------------------------------------------------------------
-- Publication de contenu : renvoie le contenu SEULEMENT si la proposition est
-- approuvée. Garde-fou d'exécution pour action-shopify-content-publish.
-- ---------------------------------------------------------------------------
create or replace function fn_get_approved_content(p_proposal_id uuid)
returns table(request_id uuid, title text, body text, content_type text, target_shopify_id bigint) as $$
  select ar.id, p.payload->>'title', p.payload->>'body', p.payload->>'content_type', p.target_shopify_id
  from approval_requests ar
  join proposals p on p.id = ar.proposal_id
  where p.id = p_proposal_id and ar.status = 'approved'
  limit 1;
$$ language sql stable;

-- ---------------------------------------------------------------------------
-- Notifications (outbox) : émettre, récupérer les en attente, marquer envoyées.
-- ---------------------------------------------------------------------------
create or replace function fn_notify(
  p_recipient_type text, p_recipient_id uuid, p_channel text, p_event text,
  p_title text, p_body text, p_task_id uuid default null, p_payload jsonb default '{}'
) returns uuid as $$
  insert into notifications(recipient_type, recipient_id, channel, event, task_id, title, body, payload)
  values (p_recipient_type, p_recipient_id, p_channel, p_event, p_task_id, p_title, p_body, coalesce(p_payload, '{}'))
  returning id;
$$ language sql;

create or replace function fn_next_notifications(p_limit int default 20)
returns setof notifications as $$
  select * from notifications where status = 'pending' order by created_at limit p_limit;
$$ language sql stable;

create or replace function fn_mark_notification(p_id uuid, p_ok boolean)
returns void as $$
  update notifications
     set status  = case when p_ok then 'sent' else 'failed' end,
         sent_at = case when p_ok then now() else sent_at end
   where id = p_id;
$$ language sql;

-- ---------------------------------------------------------------------------
-- Vues d'exploitation.
-- ---------------------------------------------------------------------------
create or replace view v_deadletter_open as
  select id, kind, workflow_key, error, created_at
  from dead_letter_queue where resolved_at is null order by created_at;

create or replace view v_ops_health as
  select
    (select count(*) from job_queue where status = 'dead') as jobs_dead,
    (select count(*) from job_queue where status = 'pending' and next_run_at <= now()) as jobs_due,
    (select count(*) from notifications where status = 'pending') as notif_pending,
    (select count(*) from approval_requests where status = 'pending') as approvals_pending,
    (select coalesce(sum(tokens), 0) from cost_ledger where occurred_on = current_date) as tokens_today;
