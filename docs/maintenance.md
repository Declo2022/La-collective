# Procédures de maintenance

Objectif : **maintenance minimale**. Les SaaS s'entretiennent seuls ; notre
charge se limite à la couche possédée (Supabase, n8n, workflows).

## Rythme

| Fréquence    | Tâche                                                                                     |
| ------------ | ----------------------------------------------------------------------------------------- |
| Quotidien    | Revue Telegram (SOP 1) : rapport, anomalies, approbations.                                |
| Hebdomadaire | Suivi ROI (`roi-tracker.md`) ; vérifier les jobs en dead-letter ; coût IA vs plafond.     |
| Mensuel      | Test de restauration d'un backup ; revue des coûts (ratio outils/CA) ; audit des accès.   |
| Trimestriel  | Audit des SaaS (garder/couper) ; rotation des secrets ; revue des versions d'API Shopify. |

## Sauvegardes

- **Supabase** : backups managés + PITR (selon plan) — rien à faire.
- **Export logique nocturne** (à mettre en place) : `pg_dump` chiffré vers bucket
  `backups`, rétention **30 jours** (`backup_runs`).
- **Workflows n8n** : exportés dans Git (source de vérité) → rollback possible.
- **Test de restauration mensuel** : restaurer un export dans une base jetable,
  vérifier l'intégrité, journaliser le résultat.

## Monitoring (déjà en place — #10)

- `monitor-cost-guardrail-cron` : alerte à 80% du plafond IA.
- `event_log` / `cost_ledger` : coût par workflow/agent (`v_cost_today`).
- `job_queue` / `dead_letter_queue` : erreurs + reprise ; surveiller les dead-letters.
- `audit_trail` : vérifier périodiquement l'intégrité de la chaîne de hash.

## Coûts — garder le cap

- Cible : **outils ≈ 2% du CA**. Si dépassement → auditer.
- Plafond IA : `OPENAI_DAILY_TOKEN_CAP` (démarrage 500 000). Relever seulement si
  la rentabilité le justifie.

## Mises à jour

- **Version d'API Shopify** : épinglée (`SHOPIFY_API_VERSION`). La faire évoluer
  volontairement (tester en dev), pas subie.
- **Dépendances repo** : Prettier & tooling — mises à jour mineures via la CI.
- **Migrations** : jamais modifier une migration appliquée ; en créer une nouvelle.

## Sécurité

- Secrets : coffre n8n / GitHub Secrets, jamais dans le dépôt (scan Gitleaks en CI).
- Rotation trimestrielle (`access-registry.md`).
- `service_role` Supabase : backend uniquement, jamais côté client.
- RLS activé sur toutes les tables (refus par défaut).

## Kill-switch

- Désactiver un workflow n8n (toggle) coupe son exécution.
- Passer un agent `enabled=false` le neutralise.
- L'Administrateur système détient le kill-switch global.
