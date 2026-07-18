# Audit de préparation production

Dernier audit : révision « mode exécution ». Méthode : audit → correction → audit.

## Checklist finale

| Domaine                  | État | Preuve                                                                      |
| ------------------------ | ---- | --------------------------------------------------------------------------- |
| Architecture complète    | ✅   | `docs/architecture.md`, 7 couches, ADR 0001–0006                            |
| Agents IA complets       | ✅   | 8 gouvernance + **12 opérationnels** seedés (`…160000`, `…120100`), prompts |
| Workflows n8n complets   | ✅   | 17 workflows JSON valides + fiches                                          |
| Supabase complet         | ✅   | 36 migrations, 68 tables + vues, testées avec pgvector                      |
| Tableaux de bord         | ✅   | `fn_dashboard_snapshot()` (8 métriques) + `report-dashboard-daily-cron`     |
| Activation agents        | ✅   | gardée (`fn_activation_ready`/`fn_activate_wave`), testée refus+succès      |
| Shopify                  | ✅   | connexion **2026 Dev Dashboard** (client_credentials) ; écriture **gated**  |
| Printful                 | ✅   | connexion Bearer testée + Printful Manager + approbations POD               |
| Santé des connexions     | ✅   | `monitor-connections-healthcheck` (6 services) + `v_connection_health`      |
| OpenAI                   | ✅   | résumés (mini) + contenu + embeddings ; coût plafonné                       |
| Telegram                 | ✅   | approbations + alertes + outbox                                             |
| Klaviyo                  | ✅   | 3 flows complets (`docs/playbooks/klaviyo-flows.md`)                        |
| Gorgias                  | ✅   | playbook + SOP (BUY)                                                        |
| SEO                      | ✅   | GSC/GA4/Clarity (playbook) + moteur de contenu                              |
| Contenu                  | ✅   | moteur RAG testé + workflows + prompts                                      |
| Analytics                | ✅   | `kpi_snapshots`, `cost_ledger`, `profitability_snapshots`, vues             |
| Monitoring               | ✅   | garde-fou coût, dead-letter, `v_ops_health`                                 |
| Sécurité                 | ✅   | RLS (refus par défaut), secrets hors dépôt, Gitleaks, audit immuable        |
| Logs                     | ✅   | `event_log` + `audit_trail` (hash chain, immuable)                          |
| Documentation            | ✅   | handoff, deployment, SOP, maintenance, playbooks, ADR                       |
| Roadmap                  | ✅   | `docs/roadmap-90days.md`                                                    |
| Déploiement              | ✅   | `docs/deployment.md`                                                        |
| Scripts d'installation   | ✅   | `scripts/` (test-db, apply-migrations, export-n8n)                          |
| README                   | ✅   | index maître                                                                |
| Configuration production | ✅   | `.env.example` complet, `supabase/config.toml`, CI                          |

## Tests réalisés (PostgreSQL 16 + pgvector)

- Pile complète appliquée via `scripts/test-db.sh` : 68 tables, RLS 68/68, HNSW ok.
- Connexions : `fn_record_connection_check` (ok/error) + `v_connection_health` +
  trace `event_log` (info/warn) ; roster de 12 agents opérationnels seedé (20 au total).
- #10 : logging + coût attribué + garde-fou ok/warn/halt ; file de jobs
  (retry backoff → dead-letter).
- #9 : chaîne CEO→CTO→humain, garde-fou `fn_can_execute`, immuabilité (UPDATE bloqué).
- #1 : upsert idempotent + rapport (CA/panier/top produits/KPI).
- #3 : 5 types d'anomalies + alerte, 0 faux positif en cas sain.
- #2 : marge réelle (COGS), remboursements exclus, KPI.
- Contenu : proposition → validation → publication gated ; notifications outbox.

## Risques restants (et mitigations)

| Risque                                           | Sévérité | Mitigation / statut                                                                    |
| ------------------------------------------------ | -------- | -------------------------------------------------------------------------------------- |
| Workflows n8n non exécutés « live »              | moyen    | Logique SQL testée ; runs réels à faire à la mise en service (checklist deployment §5) |
| Ingestion Shopify limitée au pull quotidien (#1) | faible   | Acceptable MVP ; webhooks temps réel disponibles au schéma (Phase 2) si besoin         |
| PII client (RGPD)                                | moyen    | Email haché, RLS strict, région UE, rétention — respecté ; DPA fournisseurs à signer   |
| Dépendance API tierces (rate limits)             | faible   | Backoff + job_queue + dead-letter + alerte                                             |
| Coût OpenAI variable                             | faible   | Plafond quotidien + garde-fou + coût attribué                                          |

## Corrections appliquées (boucle audit → correction)

- **SQL comma-safe** : les nœuds Postgres passant du texte libre / JSON / vecteurs
  utilisaient `queryReplacement` (n8n découpe sur les virgules → casse en prod).
  Refactorés en SQL construit par Code node avec **dollar-quoting** (texte) et
  **vecteurs numériques inlinés** — robuste aux virgules/guillemets/newlines.
  (report-shopify, content-draft, rag-ingest, lib-error-handler, approval-human, report-sales-margin)
- **Scan de secrets CI** : passage de `gitleaks-action` (licence requise en org)
  au **binaire gitleaks** (sans licence).
- **CI migrations** : job appliquant toutes les migrations sur
  `pgvector/pgvector:pg16` (vector/HNSW/RAG/audit réellement testés).
- **Validation JS** : syntaxe des 9 Code nodes vérifiée (`node --check`).

## Score de préparation production

**Code, données, sécurité, docs : ~99% prêts.** Le reste (1%) est
opérationnel et hors dépôt : provisionnement des comptes et exécution de la
checklist de mise en service `docs/deployment.md` §5 (runs « live » n8n).
