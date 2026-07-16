-- =============================================================================
-- African College — Lot 2 · Structure de travail (type Linear)
-- =============================================================================
-- Équipes › projets › cycles › états. Les tâches (fichier suivant) s'y rattachent.

create table task_teams (
  id          uuid primary key default gen_random_uuid(),
  key         text not null unique,   -- préfixe des tickets, ex. CNT, GRW, DSG
  name        text not null,
  description text,
  created_at  timestamptz not null default now()
);

create table task_projects (
  id             uuid primary key default gen_random_uuid(),
  team_id        uuid not null references task_teams(id) on delete cascade,
  name           text not null,
  description    text,
  lead_agent_id  uuid references agents(id) on delete set null,
  status         text not null default 'active'
                   check (status in ('planned', 'active', 'paused', 'completed', 'canceled')),
  target_date    date,
  created_at     timestamptz not null default now()
);

create table task_cycles (
  id          uuid primary key default gen_random_uuid(),
  team_id     uuid not null references task_teams(id) on delete cascade,
  name        text not null,
  starts_on   date,
  ends_on     date,
  status      text not null default 'upcoming'
                check (status in ('upcoming', 'active', 'completed')),
  created_at  timestamptz not null default now()
);

-- États personnalisables par équipe, rattachés à une catégorie (façon Linear).
create table task_states (
  id          uuid primary key default gen_random_uuid(),
  team_id     uuid not null references task_teams(id) on delete cascade,
  key         text not null,          -- backlog, todo, in_progress, in_review, blocked, done...
  name        text not null,
  category    text not null
                check (category in ('backlog', 'unstarted', 'started', 'completed', 'canceled')),
  position    int not null default 0,
  color       text,
  created_at  timestamptz not null default now(),
  unique (team_id, key)
);
