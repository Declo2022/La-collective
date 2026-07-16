-- =============================================================================
-- African College — Lot 2 · Collaboration & suivi
-- =============================================================================
-- Commentaires, revues/validation, abonnés, historique granulaire, temps.

create table task_comments (
  id                 uuid primary key default gen_random_uuid(),
  task_id            uuid not null references tasks(id) on delete cascade,
  author_type        text not null check (author_type in ('agent', 'human', 'system')),
  author_id          uuid,
  body               text not null,
  parent_comment_id  uuid references task_comments(id) on delete cascade,  -- fil threadé
  created_at         timestamptz not null default now(),
  edited_at          timestamptz
);
create index idx_task_comments_task on task_comments (task_id);

-- Demande de validation à un agent OU à un humain.
create table task_reviews (
  id                     uuid primary key default gen_random_uuid(),
  task_id                uuid not null references tasks(id) on delete cascade,
  requested_by_agent_id  uuid references agents(id) on delete set null,
  reviewer_type          text not null check (reviewer_type in ('agent', 'human')),
  reviewer_id            uuid,
  status                 text not null default 'pending'
                           check (status in ('pending', 'approved', 'changes_requested', 'rejected')),
  comment                text,
  requested_at           timestamptz not null default now(),
  decided_at             timestamptz
);
create index idx_task_reviews_task on task_reviews (task_id);
create index idx_task_reviews_status on task_reviews (status);

-- Abonnés (watchers). Créateur & assigné abonnés d'office (logique applicative).
create table task_subscribers (
  task_id          uuid not null references tasks(id) on delete cascade,
  subscriber_type  text not null check (subscriber_type in ('agent', 'human')),
  subscriber_id    uuid not null,
  primary key (task_id, subscriber_type, subscriber_id)
);

-- Historique : une ligne PAR changement de champ.
create table task_activity (
  id          uuid primary key default gen_random_uuid(),
  task_id     uuid not null references tasks(id) on delete cascade,
  actor_type  text not null check (actor_type in ('agent', 'human', 'system')),
  actor_id    uuid,
  action      text not null,      -- created | state_changed | assigned | priority_changed | commented | blocked…
  field       text,
  old_value   text,
  new_value   text,
  detail      jsonb not null default '{}',
  created_at  timestamptz not null default now()
);
create index idx_task_activity_task on task_activity (task_id, created_at);

-- Suivi du temps réel (estimé vs réel).
create table task_time_logs (
  id         uuid primary key default gen_random_uuid(),
  task_id    uuid not null references tasks(id) on delete cascade,
  agent_id   uuid references agents(id) on delete set null,
  minutes    int not null check (minutes > 0),
  note       text,
  logged_at  timestamptz not null default now()
);
create index idx_task_time_logs_task on task_time_logs (task_id);
