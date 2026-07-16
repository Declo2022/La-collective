# ADR 0006 — Organisation IA (8 agents + 2 humains)

- **Statut :** accepté
- **Date :** 2026-07-16
- **Phase :** renforcement · définition de l'organisation

## Contexte

Définir l'entreprise comme une organisation : 8 postes d'agents IA avec
périmètre, KPI et limites, encadrés par 2 rôles humains, et une chaîne
d'approbation claire.

## Décision

**8 agents** : CEO, CTO, Directeur Artistique, Responsable E-commerce Shopify,
Growth & Marketing, SEO & Content, Community Manager, Service Client.
**2 humains** : Claude Rivel (validation stratégique finale) et Administrateur
système (infra/sécurité/kill-switch).

Arbitrages validés :

1. **Data Analyst redistribué** (CEO/Growth/E-commerce), pas de 9e agent.
2. **Budget serré ≈ 500k tokens/j** au total (réparti par agent), plafond global
   `OPENAI_DAILY_TOKEN_CAP=500000`.
3. **Service Client** : aucun geste commercial automatique — tout validé au départ.
4. **Posts sociaux** validés par Claude Rivel (chaîne `external_publish`).

Chaînes d'approbation :

- `shopify_write` : CEO → CTO → humain (écritures Shopify).
- `external_publish` : CEO → humain (social, promo, dépense, remboursement).

## Implémentation

Seed idempotent `…160000_seed_organization.sql` : 8 agents (`enabled=false`),
2 `people`, 2 `approval_chains` + 5 `approval_steps`, 8 `approval_policies`,
7 `task_teams` + 49 `task_states`, 15 `kpi_definitions`.

**Validé sur PostgreSQL 16** : comptes corrects, budget total = 500 000, chaîne
shopify_write = CEO→CTO→human, seed idempotent (re-run sans doublon).

## Conséquences

- Les agents sont définis mais inactifs (`enabled=false`) jusqu'aux workflows (Phase 2).
- Prochaine étape : sous-workflows `lib-*`, puis Phase 2.

## Alternatives écartées

- **9e agent Data Analyst** : reporté ; fonction redistribuée.
- **Budgets larges (~2 M/j)** : reportés ; démarrage serré à 500k/j.
- **Auto-validation SAV / posts** : écartée ; validation humaine au départ.
