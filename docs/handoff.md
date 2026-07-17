# African College — Handoff maître

> **Point d'entrée unique.** Ce document permet à un développeur ou une autre IA
> de reprendre le projet sans information manquante. Lis-le en entier d'abord.

## 1. Ce qu'est African College

Marque e-commerce **culturelle / collectif d'artistes** sur Shopify. Stratégie :
**acheter les commodités (SaaS), construire uniquement le différenciant** (contenu
de marque + couche de données/pilotage first-party). Objectif : machine
e-commerce rentable, plusieurs M€, **maintenance minimale**.

Doctrine complète : artifacts « Décision ROI » et « Écosystème e-commerce ».

## 2. État du projet (au dernier commit)

| Bloc                                        | État                  | Où                              |
| ------------------------------------------- | --------------------- | ------------------------------- |
| Socle données Supabase (67 tables)          | ✅ migrations testées | `supabase/migrations/`          |
| Organisation (8 agents + 2 humains)         | ✅ seed               | `…160000_seed_organization.sql` |
| Workflow #10 (journalisation/coûts/erreurs) | ✅ SQL testé + n8n    | `…170000` + `n8n/workflows/`    |
| Workflow #9 (validation Telegram)           | ✅ SQL testé + n8n    | `…180000`                       |
| Workflow #1 (rapport Shopify)               | ✅ SQL testé + n8n    | `…190000`                       |
| Workflow #3 (anomalies)                     | ✅ SQL testé + n8n    | `…200000`                       |
| Workflow #2 (ventes & marges)               | ✅ SQL testé + n8n    | `…210000`                       |
| Moteur de contenu (BUILD)                   | ✅ SQL testé + n8n    | `…220000/220100`                |
| **Chantier BUY (SaaS)**                     | 📋 à mettre en prod   | `docs/playbooks/`               |
| **Tests réels n8n Cloud**                   | ⏳ dépend des accès   | `docs/setup-n8n-telegram.md`    |

**Rien n'est encore en production** : les migrations et workflows sont écrits et
testés en base, mais Supabase/n8n Cloud/Shopify/Telegram/OpenAI doivent être
provisionnés (voir §4).

## 3. Structure du dépôt

```
docs/
  handoff.md              ← CE FICHIER
  architecture.md         blueprint technique
  organization.md         les 8 agents + 2 humains + chaînes d'approbation
  mvp.md                  périmètre MVP + décisions #7/#8
  setup-n8n-telegram.md   config n8n Cloud + bot Telegram
  maintenance.md          procédures de maintenance
  roadmap-90days.md       plan 90 jours (BUY puis BUILD)
  sop.md                  procédures opérationnelles standard + checklists
  access-registry.md      gouvernance des accès/secrets
  runbook.md              journal d'incidents + procédures
  decisions/              ADR 0001–0006
  playbooks/
    klaviyo-flows.md      3 flows Klaviyo complets (BUY)
    roi-tracker.md        tableau ROI + baseline + suivi hebdo
  build/
    content-engine.md     plan du moteur de contenu (le moat)
    prompts.md            bibliothèque de prompts
  workflows/              1 fiche par workflow (#1, #2, #3)
supabase/
  migrations/             31 migrations SQL (ordre = timestamp)
  README.md               ordre & contenu des migrations
n8n/
  workflows/              10 workflows JSON importables + README
infra/.env.example        toutes les variables (sans secrets)
```

## 4. Comment démarrer (reprise)

1. **Lire** ce fichier, `docs/architecture.md`, `docs/organization.md`, `docs/mvp.md`.
2. **Provisionner** (voir `docs/setup-n8n-telegram.md` + `docs/access-registry.md`) :
   Supabase, Shopify (custom app read-only), OpenAI, Telegram (bot), n8n Cloud.
3. **Appliquer les migrations** : `supabase db push` (dev puis prod).
4. **Importer les workflows n8n**, brancher les credentials, activer un par un.
5. **Tester en réel** #10, #9, #1, #2, #3 (checklist `docs/setup-n8n-telegram.md`).
6. **Lancer le chantier BUY** (`docs/playbooks/`) : Klaviyo → avis → upsell → Gorgias.
7. **Puis le chantier BUILD** : moteur de contenu (`docs/build/content-engine.md`).

## 5. Règles non négociables

- **Aucune écriture Shopify sans validation humaine** (chaîne `content_publish` /
  `shopify_write` = CEO → CTO → humain via Telegram). Garde-fou : `fn_can_execute`.
- **Aucune publication ou envoi externe automatique.**
- **Plafond de coût IA** (`OPENAI_DAILY_TOKEN_CAP`) + garde-fou `monitor-cost-guardrail`.
- **Secrets jamais dans le dépôt** (coffre n8n / GitHub Secrets).
- **Audit immuable** : décisions dans `approval_decisions` + `audit_trail` (hash chain).

## 6. Comment tester (méthode éprouvée)

Toute la logique SQL est testable sur PostgreSQL 16 local (voir les blocs de test
dans l'historique). pgvector (`vector`, `<=>`) et `storage.*` ne sont testables que
sur Supabase réel. Les JSON n8n sont importables mais doivent être exécutés dans
n8n Cloud pour la validation « live ».

## 7. Contacts / rôles

- **Claude Rivel** — fondateur, validation stratégique finale.
- **Administrateur système** — infra, sécurité, kill-switch.
- Les 8 agents IA sont définis (`enabled=false`) dans la table `agents`.
