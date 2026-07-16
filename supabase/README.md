# Supabase — schéma & migrations

Schéma de la Phase 1 : **21 tables** en 5 domaines (catalogue, commercial,
mesure, agents, plomberie). Voir `docs/architecture.md` et l'artifact Phase 1
pour le détail (ERD, RLS, index).

## Ordre des migrations

Les migrations s'appliquent dans l'ordre du timestamp :

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
