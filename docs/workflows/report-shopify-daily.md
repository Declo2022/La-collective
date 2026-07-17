# Workflow #1 — Rapport Shopify quotidien

`report-shopify-daily-cron` · Lot B · valeur commerciale **directe** (visibilité).

## Objectif

Chaque matin, un résumé clair de la boutique la veille : CA, nombre de
commandes, panier moyen, remboursements, top produits — sur Telegram (+ e-mail).
Accélère les décisions du fondateur et des agents.

## Fonctionnement

1. **Cron 07:00** → calcule la fenêtre (veille).
2. **Lecture seule Shopify** (HTTP GET `/orders.json`, `created_at_min` = veille).
3. **Upsert local** via `fn_upsert_shopify_orders(jsonb)` (idempotent, clé `shopify_id`).
4. **Agrégats SQL** via `fn_daily_shopify_report(date)` → écrit `kpi_snapshots`
   (`daily_revenue`, `avg_order_value`).
5. **Résumé IA** (modèle mini) sur les **chiffres déjà calculés** — pas les
   commandes brutes.
6. **Journalisation du coût** (`fn_log_event`).
7. **Envoi Telegram** (résumé + chiffres clés).

En cas d'erreur, `errorWorkflow: lib-error-handler` (reprise + alerte).

## Optimisation des coûts API

- **Agrégation en SQL déterministe** — l'IA ne voit qu'un petit JSON de chiffres
  (~200–300 tokens), pas les commandes. Coût ~0,001–0,002 $/jour.
- **Modèle éco** `OPENAI_SUMMARY_MODEL` (gpt-4.1-mini) pour les résumés.
- **Fenêtre limitée** (veille uniquement) : lecture Shopify minimale.
- Coût journalisé dans `cost_ledger`, borné par le garde-fou #10.

## Prérequis

- Migrations appliquées (dont `…190000_wf1_daily_report.sql`).
- Credentials n8n : `Supabase Postgres`, `Telegram Bot`,
  `Shopify Admin (X-Shopify-Access-Token)` (scope `read_orders`),
  `OpenAI (Bearer)`.
- Variables n8n : `SHOPIFY_STORE_DOMAIN`, `SHOPIFY_API_VERSION`,
  `TELEGRAM_APPROVALS_CHAT_ID`, `OPENAI_SUMMARY_MODEL`.

## Déploiement

1. Importer `report-shopify-daily-cron.json` dans n8n Cloud.
2. Associer les 4 credentials aux nœuds correspondants.
3. **Test manuel** : exécuter le workflow à la main → vérifier le message
   Telegram + les lignes dans `kpi_snapshots` et `event_log`.
4. Vérifier le coût dans `cost_ledger` (`select * from v_cost_today;`).
5. Activer le workflow (cron quotidien).

## Sécurité

- **Aucune écriture Shopify** — uniquement `GET /orders.json` (scope lecture).
- Aucune action commerciale ; rien à valider (rapport interne).

## KPI

- Rapport livré chaque jour (fiabilité).
- Délai de génération.
- Exactitude des chiffres vs Shopify.
- Alimente `daily_revenue` et `avg_order_value` (base des workflows #2/#3).

## Tests (logique, sur PostgreSQL 16)

- `fn_upsert_shopify_orders` : 3 commandes upsertées, re-run idempotent (pas de
  doublon de lignes). ✓
- `fn_daily_shopify_report` : CA 210 €, panier 70 €, 1 remboursement, top
  produits corrects, KPI écrits. ✓
- Reste à valider « live » dans n8n Cloud (lecture Shopify réelle + envoi).
