-- =============================================================================
-- African College — Workflow #10 · Journalisation, coûts & erreurs (moteur SQL)
-- =============================================================================
-- Fonctions réutilisées par TOUS les workflows n8n :
--   fn_log_event   : journalise dans event_log (+ attribution de coût)
--   fn_track_cost  : agrège le coût du jour dans cost_ledger
--   fn_cost_status : usage IA du jour vs plafond (garde-fou)
--   fn_enqueue_job / fn_claim_due_jobs / fn_job_succeeded / fn_job_failed :
--                    file de jobs durable avec reprise auto (backoff) + dead-letter

-- Clé d'agrégation quotidienne du coût (upsert par jour/source/catégorie).
create unique index if not exists idx_cost_ledger_daily
  on cost_ledger (occurred_on, source_type, source_key, category);

-- ---------------------------------------------------------------------------
-- Coût : agrégation quotidienne.
-- ---------------------------------------------------------------------------
create or replace function fn_track_cost(
  p_source_type text, p_source_key text, p_category text,
  p_amount numeric, p_tokens int
) returns void as $$
begin
  insert into cost_ledger (occurred_on, source_type, source_key, category, amount_usd, tokens)
  values (current_date, p_source_type, p_source_key, coalesce(p_category, 'llm'),
          coalesce(p_amount, 0), coalesce(p_tokens, 0))
  on conflict (occurred_on, source_type, source_key, category)
  do update set amount_usd = cost_ledger.amount_usd + excluded.amount_usd,
                tokens     = coalesce(cost_ledger.tokens, 0) + coalesce(excluded.tokens, 0);
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Journalisation : une entrée event_log (+ coût attribué si présent).
-- Attribution : au workflow si connu, sinon à l'agent, sinon au service.
-- ---------------------------------------------------------------------------
create or replace function fn_log_event(
  p_category        text,
  p_action          text default null,
  p_actor_type      text default null,
  p_actor_id        uuid default null,
  p_workflow_key    text default null,
  p_workflow_run_id uuid default null,
  p_entity_type     text default null,
  p_entity_id       uuid default null,
  p_level           text default 'info',
  p_tokens          int  default null,
  p_cost_usd        numeric default null,
  p_duration_ms     int  default null,
  p_trace_id        uuid default null,
  p_detail          jsonb default '{}'
) returns uuid as $$
declare v_id uuid; v_src_type text; v_src_key text;
begin
  insert into event_log(trace_id, actor_type, actor_id, workflow_key, workflow_run_id,
    category, action, entity_type, entity_id, level, tokens, cost_usd, duration_ms, detail)
  values (coalesce(p_trace_id, gen_random_uuid()), p_actor_type, p_actor_id, p_workflow_key,
    p_workflow_run_id, p_category, p_action, p_entity_type, p_entity_id, coalesce(p_level, 'info'),
    p_tokens, p_cost_usd, p_duration_ms, coalesce(p_detail, '{}'))
  returning id into v_id;

  if coalesce(p_cost_usd, 0) > 0 or coalesce(p_tokens, 0) > 0 then
    if p_workflow_key is not null then
      v_src_type := 'workflow'; v_src_key := p_workflow_key;
    elsif p_actor_type = 'agent' and p_actor_id is not null then
      v_src_type := 'agent';
      select name into v_src_key from agents where id = p_actor_id;
      v_src_key := coalesce(v_src_key, p_actor_id::text);
    else
      v_src_type := 'service'; v_src_key := coalesce(p_actor_type, 'unknown');
    end if;
    perform fn_track_cost(v_src_type, v_src_key, 'llm', coalesce(p_cost_usd, 0), coalesce(p_tokens, 0));
  end if;
  return v_id;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- Garde-fou coût : usage du jour vs plafond de tokens.
-- ---------------------------------------------------------------------------
create or replace function fn_cost_status(p_token_cap bigint default 500000)
returns jsonb as $$
declare v_tokens bigint; v_usd numeric; v_pct numeric; v_status text;
begin
  select coalesce(sum(tokens), 0), coalesce(sum(amount_usd), 0)
    into v_tokens, v_usd
    from cost_ledger where occurred_on = current_date;
  v_pct := case when p_token_cap > 0 then round(100.0 * v_tokens / p_token_cap, 1) else 0 end;
  v_status := case
    when p_token_cap > 0 and v_tokens >= p_token_cap        then 'halt'
    when p_token_cap > 0 and v_tokens >= 0.8 * p_token_cap  then 'warn'
    else 'ok' end;
  return jsonb_build_object('date', current_date, 'tokens', v_tokens, 'token_cap', p_token_cap,
    'usd', v_usd, 'pct', v_pct, 'status', v_status);
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- File de jobs durable : reprise automatique (backoff exponentiel) + dead-letter.
-- ---------------------------------------------------------------------------
create or replace function fn_enqueue_job(
  p_kind text, p_payload jsonb default '{}', p_max_attempts int default 5,
  p_backoff_seconds int default 30, p_workflow_key text default null, p_trace_id uuid default null
) returns uuid as $$
declare v_id uuid;
begin
  insert into job_queue(kind, payload, max_attempts, backoff_seconds, workflow_key, trace_id)
  values (p_kind, coalesce(p_payload, '{}'), coalesce(p_max_attempts, 5),
          coalesce(p_backoff_seconds, 30), p_workflow_key, p_trace_id)
  returning id into v_id;
  return v_id;
end;
$$ language plpgsql;

-- Réclame les jobs dus (verrou concurrentiel : plusieurs runners possibles).
create or replace function fn_claim_due_jobs(p_limit int default 10)
returns setof job_queue as $$
begin
  return query
  update job_queue q set status = 'running', updated_at = now()
  where q.id in (
    select id from job_queue
    where status = 'pending' and next_run_at <= now()
    order by next_run_at
    for update skip locked
    limit p_limit
  )
  returning q.*;
end;
$$ language plpgsql;

create or replace function fn_job_succeeded(p_id uuid) returns void as $$
begin
  update job_queue set status = 'succeeded', updated_at = now() where id = p_id;
end;
$$ language plpgsql;

-- Échec : incrémente attempts ; replanifie (backoff) ou bascule en dead-letter.
create or replace function fn_job_failed(p_id uuid, p_error text) returns text as $$
declare v job_queue; v_status text;
begin
  select * into v from job_queue where id = p_id for update;
  if not found then return 'not_found'; end if;

  update job_queue set attempts = attempts + 1, last_error = p_error, updated_at = now()
  where id = p_id;
  select * into v from job_queue where id = p_id;

  if v.attempts >= v.max_attempts then
    update job_queue set status = 'dead', updated_at = now() where id = p_id;
    insert into dead_letter_queue(original_job_id, kind, payload, error, workflow_key)
    values (v.id, v.kind, v.payload, p_error, v.workflow_key);
    v_status := 'dead';
  else
    update job_queue set status = 'pending',
      next_run_at = now() + (v.backoff_seconds * power(2, v.attempts - 1)) * interval '1 second',
      updated_at = now()
    where id = p_id;
    v_status := 'retry';
  end if;
  return v_status;
end;
$$ language plpgsql;

-- Vue pratique : coût du jour ventilé par source.
create or replace view v_cost_today as
  select source_type, source_key, category, amount_usd, tokens
  from cost_ledger where occurred_on = current_date
  order by amount_usd desc;
