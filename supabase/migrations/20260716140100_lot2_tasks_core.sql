-- =============================================================================
-- African College — Lot 2 · Cœur : tasks, labels, dépendances
-- =============================================================================

create table tasks (
  id                   uuid primary key default gen_random_uuid(),
  key                  text not null unique,   -- référence lisible, ex. CNT-123 (générée à l'insert)
  title                text not null,
  description          text,                   -- markdown
  type                 text,                   -- content | design | seo | bug | ops | research…
  team_id              uuid not null references task_teams(id) on delete cascade,
  project_id           uuid references task_projects(id) on delete set null,
  cycle_id             uuid references task_cycles(id) on delete set null,
  state_id             uuid references task_states(id) on delete set null,
  priority             smallint not null default 0 check (priority between 0 and 4), -- 0 aucune → 4 urgente
  creator_agent_id     uuid references agents(id) on delete set null,
  assignee_agent_id    uuid references agents(id) on delete set null,
  parent_task_id       uuid references tasks(id) on delete set null,   -- sous-tâche
  estimate_minutes     int,
  estimate_points      numeric(5,1),
  start_date           date,
  due_date             date,
  rank                 text,                   -- tri manuel dans une colonne (style LexoRank)
  blocked_reason       text,
  related_proposal_id  uuid references proposals(id) on delete set null, -- pont vers l'approbation Shopify
  completed_at         timestamptz,
  canceled_at          timestamptz,
  metadata             jsonb not null default '{}',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create table task_labels (
  id          uuid primary key default gen_random_uuid(),
  team_id     uuid references task_teams(id) on delete cascade,   -- null = étiquette globale
  name        text not null,
  color       text,
  created_at  timestamptz not null default now()
);

create table task_label_links (
  task_id   uuid not null references tasks(id) on delete cascade,
  label_id  uuid not null references task_labels(id) on delete cascade,
  primary key (task_id, label_id)
);

-- Dépendances typées. blocked_by est le sens inverse de blocks (déduit).
create table task_dependencies (
  id                   uuid primary key default gen_random_uuid(),
  task_id              uuid not null references tasks(id) on delete cascade,
  related_task_id      uuid not null references tasks(id) on delete cascade,
  type                 text not null check (type in ('blocks', 'relates', 'duplicates')),
  created_by_agent_id  uuid references agents(id) on delete set null,
  created_at           timestamptz not null default now(),
  check (task_id <> related_task_id),
  unique (task_id, related_task_id, type)
);
