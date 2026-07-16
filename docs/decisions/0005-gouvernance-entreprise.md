# ADR 0005 — Gouvernance de niveau entreprise

- **Statut :** accepté
- **Date :** 2026-07-16
- **Phase :** renforcement · Lot 3

## Contexte

Rendre l'entreprise autonome sûre et redevable : savoir à tout moment qui a
décidé quoi, à quel coût, et pouvoir revenir en arrière. Treize exigences de
gouvernance à couvrir avant de brancher les workflows.

## Décision

**~23 tables** (45 → 67), livrées en 3 sous-lots. `audit_log` (Phase 1)
remplacé par `event_log` + `audit_trail`.

- **3a — logs/audit/rollback** : `event_log` (journal global, trace_id, coût),
  `audit_trail` (immuable), `change_sets` (rollback).
- **3b — erreurs/monitoring/alertes** : `job_queue` + `dead_letter_queue`
  (reprise auto, backoff), `service_heartbeats` / `health_checks` / `metrics`,
  `alert_rules` / `alerts`.
- **3c — KPI/approbation/registre/backups** : `kpi_definitions` /
  `kpi_snapshots` / `cost_ledger` / `profitability_snapshots` ;
  `approval_chains` / `approval_steps` / `approval_policies` /
  `approval_requests` / `approval_decisions` ; `workflow_registry` /
  `workflow_versions` / `workflow_runs` ; `backup_runs`.

Arbitrages validés :

1. **Audit immuable = chaîne de hash + triggers** (rejettent UPDATE/DELETE).
   `hash = sha256(seq ‖ prev_hash ‖ payload ‖ created_at)`. Toute altération détectable.
2. **Migrations en 3 sous-lots**, testés séparément.
3. **Slack** prévu (variable d'env `SLACK_WEBHOOK_URL`), branché plus tard.
4. **Chaîne d'approbation Shopify : CEO (agent) → CTO (agent) → humain.**
5. **Rétention export logique : 30 jours** (par défaut).

Principes :

- Rollback jamais « sauvage » : un change set inverse repasse par l'approbation.
- Reprise auto : backoff exponentiel, puis dead-letter + alerte (rien perdu en silence).
- Coût attribué par agent ET par workflow (depuis event_log → cost_ledger).
- `approval_decisions` = historique immuable des validations (agents + humains).

## Conséquences

- 67 tables au total ; RLS sur les 67 ; triggers d'immuabilité sur
  `audit_trail` et `approval_decisions`.
- Nécessite `pgcrypto` (hachage). Extension activée par la migration 3a.
- **Validé sur PostgreSQL 16** : 67 tables, RLS 67/67, chaîne de hash correcte,
  UPDATE/DELETE sur l'audit effectivement bloqués.
- Après ce lot, le socle de données est complet → définition des 8 agents, puis
  sous-workflows `lib-*`, puis Phase 2.

## Alternatives écartées

- **Append-only sans hash** : moins fort (n'auto-détecte pas une réécriture) — écarté.
- **Approbation humaine seule** : reportée ; on met d'emblée la chaîne CEO→CTO→humain.
