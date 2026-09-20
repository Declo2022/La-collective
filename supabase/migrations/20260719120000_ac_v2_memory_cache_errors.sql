-- =============================================================================
-- African College — Phase V2 : mémoire conversationnelle, cache 24 h, erreurs
-- =============================================================================
-- Support des workflows AC Memory (conversation_memory + response_cache) et
-- AC Error Handler (errors). audit_log existe déjà (réutilisé, pas de doublon).
-- Toutes les tables : RLS refus par défaut (service_role de n8n contourne).

-- ---------------------------------------------------------------------------
-- AC Memory — mémoire conversationnelle (reconnaissance utilisateur incluse).
-- ---------------------------------------------------------------------------
create table if not exists conversation_memory (
  id                uuid primary key default gen_random_uuid(),
  telegram_user_id  text not null,
  chat_id           text,
  user_name         text,
  direction         text not null check (direction in ('in', 'out')),
  intent            text,                      -- singa | operateur | analyste | ecriture | autre
  agent             text,                      -- persona ayant traité
  content           text not null,
  tokens            integer,
  created_at        timestamptz not null default now()
);
create index if not exists idx_conv_mem_user on conversation_memory (telegram_user_id, created_at desc);
alter table conversation_memory enable row level security;

-- Écrit un tour de conversation (comma-safe : appelé avec des paramètres liés).
create or replace function fn_conv_remember(
  p_user_id text, p_chat_id text, p_user_name text, p_direction text,
  p_intent text, p_agent text, p_content text, p_tokens int default null
) returns uuid as $$
declare v_id uuid;
begin
  insert into conversation_memory (telegram_user_id, chat_id, user_name, direction, intent, agent, content, tokens)
  values (p_user_id, p_chat_id, p_user_name, p_direction, p_intent, p_agent, p_content, p_tokens)
  returning id into v_id;
  return v_id;
end;
$$ language plpgsql;

-- Rappelle les N derniers tours d'un utilisateur (contexte pour le LLM).
create or replace function fn_conv_recent(p_user_id text, p_limit int default 6)
returns table (direction text, agent text, content text, created_at timestamptz)
language sql stable as $$
  select direction, agent, content, created_at
  from conversation_memory
  where telegram_user_id = p_user_id
  order by created_at desc
  limit greatest(1, coalesce(p_limit, 6));
$$;

-- Reconnaît un utilisateur déjà vu (nom + nb d'échanges).
create or replace function fn_conv_user_profile(p_user_id text)
returns table (user_name text, exchanges bigint, first_seen timestamptz, last_seen timestamptz)
language sql stable as $$
  select max(user_name), count(*), min(created_at), max(created_at)
  from conversation_memory
  where telegram_user_id = p_user_id;
$$;

-- ---------------------------------------------------------------------------
-- AC Memory — cache de réponses (par défaut 24 h) pour couper les coûts LLM.
-- ---------------------------------------------------------------------------
create table if not exists response_cache (
  id          uuid primary key default gen_random_uuid(),
  cache_key   text not null unique,            -- hash de la question normalisée
  question    text,
  response    text not null,
  hits        integer not null default 0,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '24 hours'
);
create index if not exists idx_response_cache_expiry on response_cache (expires_at);
alter table response_cache enable row level security;

-- Lit le cache (renvoie NULL si absent/expiré) et incrémente hits si trouvé.
create or replace function fn_cache_get(p_key text)
returns text as $$
declare v_resp text;
begin
  update response_cache
     set hits = hits + 1
   where cache_key = p_key and expires_at > now()
   returning response into v_resp;
  return v_resp;  -- NULL si rien mis à jour (absent ou expiré)
end;
$$ language plpgsql;

-- Écrit/rafraîchit une entrée de cache (TTL en heures, 24 par défaut).
create or replace function fn_cache_put(
  p_key text, p_question text, p_response text, p_ttl_hours int default 24
) returns void as $$
begin
  insert into response_cache (cache_key, question, response, expires_at)
  values (p_key, p_question, p_response, now() + make_interval(hours => coalesce(p_ttl_hours, 24)))
  on conflict (cache_key) do update
    set response = excluded.response,
        question = excluded.question,
        created_at = now(),
        expires_at = excluded.expires_at,
        hits = 0;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------------
-- AC Error Handler — journal d'erreurs global n8n.
-- ---------------------------------------------------------------------------
create table if not exists errors (
  id            uuid primary key default gen_random_uuid(),
  workflow      text,
  node          text,
  execution_id  text,
  severity      text not null default 'error' check (severity in ('info', 'warning', 'error', 'critical')),
  message       text,
  detail        jsonb not null default '{}',
  resolved      boolean not null default false,
  created_at    timestamptz not null default now()
);
create index if not exists idx_errors_severity on errors (severity, created_at desc);
create index if not exists idx_errors_open on errors (created_at desc) where not resolved;
alter table errors enable row level security;

-- Journalise une erreur ; renvoie true si critique (déclenche l'alerte Telegram).
create or replace function fn_log_error(
  p_workflow text, p_node text, p_execution_id text,
  p_severity text, p_message text, p_detail jsonb default '{}'
) returns boolean as $$
declare v_sev text := coalesce(p_severity, 'error');
begin
  insert into errors (workflow, node, execution_id, severity, message, detail)
  values (p_workflow, p_node, p_execution_id, v_sev, p_message, coalesce(p_detail, '{}'));
  return v_sev = 'critical';
end;
$$ language plpgsql;
