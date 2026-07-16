# Supabase — schéma & migrations

Phase 1 : **21 tables** en 5 domaines (catalogue, commercial, mesure, agents,
plomberie). Renforcement (multi-agents) : tables ajoutées par lots. Voir
`docs/architecture.md` et les artifacts d'architecture pour le détail.

## Ordre des migrations

Les migrations s'appliquent dans l'ordre du timestamp.

**Phase 1 — socle (21 tables) :**

| Fichier                            | Contenu                                                        |
| ---------------------------------- | -------------------------------------------------------------- |
| `…120000_extensions.sql`           | pgvector                                                       |
| `…120100_domain_a_catalog.sql`     | products, variants, collections, locations, inventory          |
| `…120200_domain_b_commercial.sql`  | customers (PII hachée), orders, line items                     |
| `…120300_domain_c_measurement.sql` | ga4_daily, gsc_daily, clarity_daily                            |
| `…120400_domain_d_agents.sql`      | agents, runs, memory (pgvector), proposals, approvals, actions |
| `…120500_domain_e_ops.sql`         | webhook_events, sync_state, audit_log                          |
| `…120600_indexes.sql`              | index d'accès + HNSW vectoriel                                 |
| `…120700_rls.sql`                  | RLS activé partout, refus par défaut                           |
| `…120800_storage_buckets.sql`      | buckets privés : product-media, agent-artifacts, exports       |

**Renforcement multi-agents — Lot 1 (mémoire + RAG + KB, +8 tables) :**

| Fichier                         | Contenu                                                      |
| ------------------------------- | ------------------------------------------------------------ |
| `…130000_memory_evolution.sql`  | agent_memory : +type, importance, décroissance, source_run   |
| `…130100_rag_documents.sql`     | documents, document_chunks (embeddings HNSW)                 |
| `…130200_kb_knowledge_base.sql` | kb_artists, kb_interviews, kb_brand_story, product_profiles… |
| `…130300_lot1_rls_storage.sql`  | RLS des 8 tables + bucket privé `documents`                  |

**Renforcement multi-agents — Lot 2 (système de tâches type Linear/Jira, +16 tables) :**

| Fichier                           | Contenu                                                            |
| --------------------------------- | ------------------------------------------------------------------ |
| `…140000_lot2_task_structure.sql` | task_teams, task_projects, task_cycles, task_states                |
| `…140100_lot2_tasks_core.sql`     | tasks, task_labels, task_label_links, task_dependencies            |
| `…140200_lot2_task_collab.sql`    | task_comments, task_reviews, task_subscribers, activity, time_logs |
| `…140300_lot2_notifications.sql`  | people, notifications (outbox), notification_preferences           |
| `…140400_lot2_indexes_rls.sql`    | index d'accès (board/filtres) + RLS des 16 tables                  |

**Total après Lot 2 : 45 tables.**

**Renforcement multi-agents — Lot 3 (gouvernance entreprise, +23 tables) :**

| Fichier                                      | Contenu                                                                               |
| -------------------------------------------- | ------------------------------------------------------------------------------------- |
| `…150000_lot3a_logs_audit_rollback.sql`      | event_log ; audit_trail (immuable, hash chain) ; change_sets                          |
| `…150100_lot3b_errors_monitoring_alerts.sql` | job_queue, dead_letter_queue, heartbeats, health_checks, metrics, alert_rules, alerts |
| `…150200_lot3c_kpi_cost.sql`                 | kpi_definitions, kpi_snapshots, cost_ledger, profitability_snapshots                  |
| `…150300_lot3c_approval.sql`                 | approval_chains/steps/policies/requests + approval_decisions (immuable)               |
| `…150400_lot3c_registry_backups.sql`         | workflow_registry, workflow_versions, workflow_runs, backup_runs                      |

**Total après Lot 3 : 67 tables.** `audit_log` (Phase 1) est remplacé par
`event_log` + `audit_trail`. Nécessite `pgcrypto` (activé par la migration 3a).

### Immuabilité

`audit_trail` et `approval_decisions` sont **append-only** : des triggers
rejettent tout `UPDATE`/`DELETE`. `audit_trail` chaîne en plus chaque ligne par
hash SHA-256 (`hash = sha256(seq ‖ prev_hash ‖ payload ‖ created_at)`) —
toute altération rompt la chaîne et devient détectable.

_Prochaine étape : définition des 8 agents (+ policies), puis sous-workflows `lib-*`, puis Phase 2._

## Appliquer

Avec la Supabase CLI (recommandé), sur les projets **dev** puis **prod** :

```bash
supabase link --project-ref <ref>
supabase db push
```

## Vérification locale (sans pgvector)

Les migrations ont été validées sur PostgreSQL 16 (tables, FK, contraintes
CHECK, index, RLS). Les éléments spécifiques à Supabase — l'extension `vector`
et le schéma `storage` — ne sont testables que sur un projet Supabase réel.

## Conventions

- Nom de fichier : `<timestamp 14 chiffres>_<nom_en_snake_case>.sql` (vérifié par la CI).
- `shopify_id` unique sur chaque table miroir → upsert idempotent.
- Aucune donnée en clair sensible : l'email client est **haché** (`email_hash`).
