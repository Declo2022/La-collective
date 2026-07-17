# Déploiement production

Procédure complète, dans l'ordre. Objectif : plateforme en production, sûre.

## 0. Prérequis (comptes)

| Service  | Ce qu'il faut                    | Scope / plan                                                                                                                               |
| -------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Supabase | projet dev + projet prod         | Pro (PITR/backups)                                                                                                                         |
| Shopify  | custom app                       | `read_orders`, `read_products`, `read_inventory`, `read_locations` ; **`write_content`** (uniquement pour la publication de contenu gated) |
| OpenAI   | clé API + projet dédié + plafond | —                                                                                                                                          |
| Telegram | bot (@BotFather) + groupe privé  | —                                                                                                                                          |
| n8n      | workspace n8n Cloud              | Starter                                                                                                                                    |
| Resend   | clé API + domaine e-mail vérifié | Free au départ                                                                                                                             |

## 1. Base de données (Supabase)

1. `supabase link --project-ref <ref-prod>`
2. `bash scripts/apply-migrations.sh` (ou `supabase db push`).
3. Vérifier : `select * from v_ops_health;` doit répondre.
4. Confirmer les extensions : `select extname from pg_extension;` → `vector`, `pgcrypto`.
5. Confirmer les buckets Storage : `product-media`, `agent-artifacts`, `exports`, `documents`.

## 2. Secrets & variables

- Renseigner **toutes** les variables de `infra/.env.example` dans le coffre n8n Cloud
  (jamais dans le dépôt). Voir `docs/access-registry.md`.
- Variables critiques : `SUPABASE_*`, `SHOPIFY_*`, `OPENAI_*`, `TELEGRAM_*`,
  `RESEND_API_KEY`, `EMAIL_FROM`, `OPENAI_DAILY_TOKEN_CAP=500000`.

## 3. Credentials n8n

Créer dans n8n Cloud (Settings → Credentials) :

| Nom                                      | Type         | Contenu                                 |
| ---------------------------------------- | ------------ | --------------------------------------- |
| `Supabase Postgres`                      | Postgres     | connexion DB Supabase (SSL)             |
| `Telegram Bot`                           | Telegram API | `TELEGRAM_BOT_TOKEN`                    |
| `Shopify Admin (X-Shopify-Access-Token)` | Header Auth  | header `X-Shopify-Access-Token` = token |
| `OpenAI (Bearer)`                        | Header Auth  | header `Authorization` = `Bearer <clé>` |
| `Resend (Bearer)`                        | Header Auth  | header `Authorization` = `Bearer <clé>` |

## 4. Workflows n8n

1. Importer tous les `n8n/workflows/*.json`.
2. Associer les credentials aux nœuds.
3. Activer dans cet ordre (tester chacun avant d'activer le suivant) :
   1. `monitor-cost-guardrail-cron`, `notify-outbox-dispatch-cron`, `monitor-deadletter-cron`
   2. `approval-send-telegram`, `approval-human-telegram` (+ `lib-approval-gate`, `lib-error-handler` importés)
   3. `report-shopify-daily-cron`, `monitor-anomalies-cron`, `report-sales-margin-cron`
   4. (BUILD) `rag-ingest-document-task`, `content-draft-task`, `action-shopify-content-publish`

## 5. Tests de mise en service (obligatoires)

- [ ] `#10` garde-fou coût : plafond bas + coût de test → alerte Telegram.
- [ ] `#9` approbation : envoi + clic Valider → `approval_decisions` écrit.
- [ ] `#1` rapport : run manuel → message Telegram + `kpi_snapshots`.
- [ ] `#3` anomalies : insérer une anomalie de test → alerte.
- [ ] `#2` marges : charger COGS + run → message + `gross_margin`.
- [ ] Contenu : ingérer un doc → générer un brouillon → valider → publier (page brouillon Shopify).

## 6. Chantier BUY (SaaS)

Suivre `docs/playbooks/klaviyo-flows.md` puis avis, upsell, Gorgias. Mesurer via
`docs/playbooks/roi-tracker.md`.

## 7. Post-déploiement

- Activer les backups (`docs/maintenance.md`).
- Programmer la revue quotidienne (SOP 1).
- Surveiller `v_ops_health` (jobs dead, notif en attente, coût du jour).

## Rollback

- Workflows : réimporter la version Git précédente.
- Migrations : ne jamais modifier une migration appliquée ; créer une migration corrective.
- Données : PITR Supabase / export logique (`backup_runs`).
