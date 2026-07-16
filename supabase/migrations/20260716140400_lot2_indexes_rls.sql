-- =============================================================================
-- African College — Lot 2 · Index & RLS
-- =============================================================================

-- Index d'accès sur tasks (board, filtres, tri).
create index idx_tasks_team on tasks (team_id);
create index idx_tasks_assignee on tasks (assignee_agent_id);
create index idx_tasks_state on tasks (state_id);
create index idx_tasks_project on tasks (project_id);
create index idx_tasks_cycle on tasks (cycle_id);
create index idx_tasks_priority on tasks (priority);
create index idx_tasks_due on tasks (due_date);
create index idx_tasks_parent on tasks (parent_task_id);
create index idx_task_deps_task on task_dependencies (task_id);
create index idx_task_deps_related on task_dependencies (related_task_id);

-- RLS : activé partout, refus par défaut. Backend = service_role.
alter table task_teams enable row level security;
alter table task_projects enable row level security;
alter table task_cycles enable row level security;
alter table task_states enable row level security;
alter table tasks enable row level security;
alter table task_labels enable row level security;
alter table task_label_links enable row level security;
alter table task_dependencies enable row level security;
alter table task_comments enable row level security;
alter table task_reviews enable row level security;
alter table task_subscribers enable row level security;
alter table task_activity enable row level security;
alter table task_time_logs enable row level security;
alter table people enable row level security;
alter table notifications enable row level security;
alter table notification_preferences enable row level security;
