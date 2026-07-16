-- =============================================================================
-- African College — Phase 1 · Extensions
-- =============================================================================
-- pgvector : mémoire sémantique des agents (colonne embedding vector(1536)).
-- gen_random_uuid() est disponible nativement sur Supabase (pgcrypto).

create extension if not exists vector;
