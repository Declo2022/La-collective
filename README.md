# African College

Marque e-commerce **culturelle / collectif d'artistes** sur Shopify. Stratégie :
**acheter les commodités (SaaS best-in-class), construire uniquement le
différenciant** — le contenu de marque et la couche de données/pilotage
first-party. Objectif : machine e-commerce rentable, plusieurs M€, **maintenance
minimale**. L'humain garde le contrôle via Telegram (validation des actions à impact).

> ## 👉 Reprise du projet : lire d'abord [`docs/handoff.md`](docs/handoff.md)
>
> C'est le **point d'entrée unique** — état du projet, structure, comment
> démarrer, règles non négociables. Conçu pour une reprise sans info manquante.

## Où est quoi

| Sujet                                  | Document                                                             |
| -------------------------------------- | -------------------------------------------------------------------- |
| **Handoff maître (commencer ici)**     | [`docs/handoff.md`](docs/handoff.md)                                 |
| Architecture technique                 | [`docs/architecture.md`](docs/architecture.md)                       |
| Organisation (8 agents + 2 humains)    | [`docs/organization.md`](docs/organization.md)                       |
| Périmètre MVP + décisions              | [`docs/mvp.md`](docs/mvp.md)                                         |
| Config n8n Cloud + Telegram            | [`docs/setup-n8n-telegram.md`](docs/setup-n8n-telegram.md)           |
| **Chantier BUY — Klaviyo (3 flows)**   | [`docs/playbooks/klaviyo-flows.md`](docs/playbooks/klaviyo-flows.md) |
| **Chantier BUY — tableau ROI**         | [`docs/playbooks/roi-tracker.md`](docs/playbooks/roi-tracker.md)     |
| **Chantier BUILD — moteur de contenu** | [`docs/build/content-engine.md`](docs/build/content-engine.md)       |
| Bibliothèque de prompts                | [`docs/build/prompts.md`](docs/build/prompts.md)                     |
| SOP + checklists                       | [`docs/sop.md`](docs/sop.md)                                         |
| **Déploiement production**             | [`docs/deployment.md`](docs/deployment.md)                           |
| **Audit préparation prod**             | [`docs/audit.md`](docs/audit.md)                                     |
| Maintenance                            | [`docs/maintenance.md`](docs/maintenance.md)                         |
| Plan 90 jours                          | [`docs/roadmap-90days.md`](docs/roadmap-90days.md)                   |
| Décisions d'architecture (ADR)         | [`docs/decisions/`](docs/decisions/)                                 |
| Migrations SQL                         | [`supabase/README.md`](supabase/README.md)                           |
| Workflows n8n                          | [`n8n/workflows/README.md`](n8n/workflows/README.md)                 |

## Structure

```
docs/            handoff, architecture, playbooks (BUY), build (BUILD), SOP, maintenance, roadmap, ADR
supabase/        32 migrations (67 tables + vues + fonctions), testées (PostgreSQL 16 + pgvector)
n8n/workflows/   13 workflows JSON importables + fiches
scripts/         test-db, apply-migrations, export-n8n
infra/           .env.example (toutes les variables, sans secrets)
.github/         CI (format, validation migrations/JSON, scan de secrets)
```

## Démarrer (développeur)

```bash
npm ci
npm run format:check         # utilisé par la CI
cp infra/.env.example .env   # remplir les valeurs (jamais commité)
# puis : docs/handoff.md
```

## État

**Fondations écrites & testées (SQL sur PostgreSQL 16), pas encore en production.**
Provisionner les comptes puis suivre `docs/handoff.md` §4. Chantier BUY (SaaS) à
mettre en prod ; chantier BUILD (contenu) prêt à déployer.

## Sécurité

Aucun secret dans le dépôt (scan Gitleaks en CI). Voir
[`docs/access-registry.md`](docs/access-registry.md). Règles non négociables :
[`docs/handoff.md`](docs/handoff.md) §5.

---

_Phase 0 (vérité unique) en cours : voir `docs/audit-lecture-seule-2026-08-07.md`,
`docs/phase0-credentials-checklist.md` et `n8n/workflows/live/README.md`._
