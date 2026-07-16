# ADR 0002 — Schéma de données Phase 1

- **Statut :** accepté
- **Date :** 2026-07-16
- **Phase :** 1 — Socle données & instrumentation

## Contexte

Poser le socle de données Supabase pour African College : miroir Shopify,
mesure (GA4/GSC/Clarity), et structure de la couche agents. Phase 1 = **lecture
seule** côté boutique (aucune écriture Shopify avant le garde-fou Telegram).

## Décision

**21 tables** en 5 domaines (A Catalogue, B Commercial, C Mesure, D Agents,
E Plomberie). Points arbitrés :

1. **PII minimisée** : `customers.email_hash` (SHA-256), pas d'email en clair.
   Prénom/nom + agrégats conservés pour la segmentation.
2. **Domaine Agents créé dès la Phase 1** (tables vides) pour éviter une
   migration lourde en Phase 3 et imposer la traçabilité proposals → approvals → actions.
3. **6 workflows n8n** en Phase 1 (ingestion Shopify, backfill, GA4, GSC,
   Clarity, monitoring), tous en écriture Supabase seule.
4. **Embeddings `vector(1536)`** : troncature de `text-embedding-3-large`
   (pgvector n'indexe que ≤ 2000 dims). Index **HNSW** cosine.
5. **RLS activé partout, refus par défaut** ; accès backend via `service_role`.
6. **Scopes Shopify en lecture seule** (`read_*`) ; les `write_*` viennent en Phase 3+.

## Conséquences

- Le hachage d'email est fait à l'ingestion (n8n), pas en base.
- Les tables de mesure n'ont pas de FK vers le catalogue (jointure souple à l'analyse).
- Colonnes `raw` jsonb sur products/orders : filet de sécurité rejouable.
- Migrations validées sur PostgreSQL 16 (hors `vector`/`storage`, testés sur Supabase réel).

## Alternatives écartées

- **Email en clair dès maintenant** : surface RGPD plus large — écarté.
- **Tables agents reportées en Phase 3** : migration plus lourde plus tard — écarté.
- **vector(3072)** : non indexable par pgvector — écarté au profit de 1536.
