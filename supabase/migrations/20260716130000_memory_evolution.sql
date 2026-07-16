-- =============================================================================
-- African College — Renforcement · Mémoire longue durée
-- =============================================================================
-- Fait évoluer agent_memory (Phase 1) vers 3 registres + importance/décroissance.

alter table agent_memory
  add column memory_type      text
    check (memory_type in ('episodic', 'semantic', 'procedural')),
  add column importance       numeric(4,3) not null default 0.5
    check (importance >= 0 and importance <= 1),
  add column access_count     int not null default 0,
  add column last_accessed_at timestamptz,
  add column expires_at       timestamptz,          -- null = permanent
  add column source_run_id    uuid references agent_runs(id) on delete set null;

comment on column agent_memory.memory_type is 'episodic (ce qui s''est passé) | semantic (faits durables) | procedural (recettes).';
comment on column agent_memory.expires_at is 'Décroissance : les souvenirs peu utiles expirent. null = permanent.';

create index idx_agent_memory_type on agent_memory (memory_type);
create index idx_agent_memory_importance on agent_memory (importance);
create index idx_agent_memory_expires on agent_memory (expires_at);
