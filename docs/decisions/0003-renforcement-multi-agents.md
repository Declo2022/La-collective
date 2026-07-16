# ADR 0003 — Renforcement multi-agents (mémoire, RAG, KB, tâches, pilotage)

- **Statut :** accepté (architecture) — implémentation par lots
- **Date :** 2026-07-16
- **Phase :** renforcement, avant Phase 2

## Contexte

Avant de brancher 100+ workflows n8n, on pose le « cerveau » de l'entreprise :
système multi-agents, mémoire longue durée, RAG, base de connaissances,
coordination par tâches, approbation humaine, logs complets, pilotage.

## Décision

**8 agents** : CEO (orchestrateur), CTO (intégrité technique), Designer,
Marketing, SEO, Rédacteur, Support, Data Analyst. Règle absolue : **aucun agent
n'écrit dans Shopify** — ils proposent, un humain valide.

Arbitrages validés :

1. **Marque culturelle / collectif d'artistes** → KB = artistes, interviews,
   histoire de marque, profils produits narratifs.
2. **Pilotage léger d'abord** : approbations via Telegram + vues Supabase ;
   dashboard web (Next.js + Realtime) dans un second temps.
3. **Migrations par lots** : Lot 1 mémoire+RAG+KB, Lot 2 tâches, Lot 3
   logs/approbation/workflows/pilotage.
4. **Ordre** : migrations d'extension → agents & policies → sous-workflows
   `lib-*` → Phase 2.

Autres décisions structurantes :

- **Mémoire** à 3 registres (épisodique/sémantique/procédurale) + importance +
  décroissance + consolidation nocturne.
- **RAG** avec provenance (chunks sources cités) ; refus si similarité faible.
- **Tâches typées** plutôt que conversation libre entre agents (auditable, rejouable).
- **event_log** unique avec `trace_id` remplace `audit_log` (Lot 3).
- **Scaling n8n** : nommage `<domaine>-<action>-<déclencheur>`, dispatchers,
  sous-workflows `lib-*`, `workflow_registry` comme source de vérité.

## Conséquences

- ~17 tables ajoutées au total (21 → ~38), par lots.
- Toutes héritent des règles Phase 1 : RLS activé, refus par défaut, service_role.
- **Lot 1 livré et validé sur PostgreSQL 16** (29 tables, RLS sur les 29).

## Alternatives écartées

- **Conversation libre entre agents** : ingérable et non auditable à l'échelle — écarté.
- **Dashboard Next.js complet d'emblée** : reporté au profit d'un démarrage léger.
- **Écriture Shopify directe par les agents** : contraire au garde-fou — exclu.
