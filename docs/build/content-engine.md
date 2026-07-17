# Plan BUILD — Moteur de contenu de marque African College

Le **seul** chantier construit sur mesure : l'avantage stratégique que personne
ne vend. Objectif : produire à la chaîne du contenu **fidèle à la marque**
(artistes, interviews, histoire) pour le SEO et la conversion — sourcé, jamais
inventé, jamais publié sans validation humaine.

## 1. Pourquoi le construire (et pas l'acheter)

Jasper/Copy.ai ignorent la base de connaissances d'African College. Notre moteur
s'appuie sur la **KB + RAG** (`kb_artists`, `kb_interviews`, `kb_brand_story`,
`documents`, `document_chunks`) → un contenu que seule la marque peut produire.
Actif SEO **cumulatif** (chaque article attire du trafic pendant des mois).

## 2. Architecture

```
Sources (bios, interviews, notes) --> rag-ingest-document-task
   -> documents + document_chunks (embeddings 1536, HNSW)

Brief (sujet) --> content-draft-task
   -> embedding du brief -> fn_rag_search (contexte cité)
   -> génération (modèle contenu) -> fn_create_content_proposal
   -> proposition 'content_publish' -> chaîne CEO->CTO->humain (Telegram)
   -> APRÈS validation humaine : publication (manuelle ou action-shopify-content-publish)
```

## 3. Composants (déjà écrits & testés)

| Composant                | Fichier                                                                                       | État            |
| ------------------------ | --------------------------------------------------------------------------------------------- | --------------- |
| Ingestion RAG            | `n8n/workflows/rag-ingest-document-task.json`                                                 | à tester en n8n |
| Recherche RAG            | `fn_rag_search` (`…220100`, Supabase/pgvector)                                                | Supabase only   |
| Génération + proposition | `n8n/workflows/content-draft-task.json` + `fn_create_content_proposal` (`…220000`, **testé**) | ✅ SQL testé    |
| Validation               | réutilise #9 (`fn_open_approval`, Telegram)                                                   | ✅ testé        |
| Publication              | manuelle OU `action-shopify-content-publish` (à créer, derrière approbation)                  | à faire         |

## 4. Garde-fous (non négociables)

- **Sourcé uniquement** : le prompt impose de n'utiliser que le CONTEXTE RAG ; si
  insuffisant → « information non disponible ». Anti-hallucination.
- **Jamais publié sans humain** : chaîne `content_publish` = CEO → CTO → humain.
- **Provenance** : chaque proposition stocke les `sources` (chunks/documents cités).
- **Coût maîtrisé** : contexte limité (top-6 chunks), modèle configurable
  (`OPENAI_CONTENT_MODEL`), coût journalisé (`fn_log_event`).

## 5. Types de contenu

- `product_description` — fiches produits narratives (SEO + conversion).
- `article` — articles de blog (histoire, culture, coulisses).
- `interview` — interviews d'artistes (depuis `kb_interviews` / documents).
- `seo_meta` — titres/méta-descriptions optimisés.

## 6. Coût estimé

- Ingestion : embeddings ~0,0001 $/1k tokens → négligeable.
- Génération : ~1–2k tokens/pièce → ~0,01–0,03 $/pièce (modèle standard).
- Volume 20 pièces/mois → **~1–2 $/mois**. Le SEO rapporté dépasse largement.

## 7. Déploiement

1. Appliquer migrations `…220000` et `…220100` (Supabase, pgvector requis).
2. Importer `rag-ingest-document-task` et `content-draft-task` dans n8n.
3. Credentials : `Supabase Postgres`, `OpenAI (Bearer)`. Variable `OPENAI_CONTENT_MODEL`.
4. **Ingérer la KB** : bios artistes, interviews, manifeste de marque (via ingestion).
5. Générer un premier brouillon (`content-draft-task`) → valider sur Telegram → publier.
6. Mesurer via `docs/playbooks/roi-tracker.md` (sessions & CA organiques).

## 8. Prérequis avant de lancer BUILD

- Chantier BUY en production **avec ROI mesuré** (voir roadmap).
- Base de connaissances alimentée (au moins quelques artistes + l'histoire).
- Search Console + GA4 en place (mesure du SEO).

## 9. Prompts

Voir `docs/build/prompts.md` (bibliothèque complète, versionnée).

## 10. Checklist

- [ ] Migrations 220000 + 220100 appliquées.
- [ ] KB ingérée (artistes, interviews, histoire).
- [ ] `content-draft-task` importé + credentials.
- [ ] 1er brouillon généré, sourcé, validé sur Telegram.
- [ ] 1re publication + suivi SEO démarré.
