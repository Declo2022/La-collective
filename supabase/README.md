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

_Lots suivants (à venir) : Lot 2 tâches & validation ; Lot 3 logs (event_log), policies d'approbation, registre des workflows, pilotage._

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
