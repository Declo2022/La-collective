# ADR 0004 — Système de tâches (type Linear/Jira)

- **Statut :** accepté
- **Date :** 2026-07-16
- **Phase :** renforcement · Lot 2

## Contexte

La coordination des 8 agents doit être aussi rigoureuse qu'une équipe humaine
outillée (Linear/Jira) : créer, assigner, valider, bloquer, commenter, changer
de statut, tout historiser — avec priorités, dépendances, deadlines, estimation
et notifications.

## Décision

**16 tables** (29 → 45), organisées en 5 groupes :

- **Structure** : task_teams, task_projects, task_cycles, task_states (états
  personnalisables par équipe, rattachés à une catégorie façon Linear).
- **Cœur** : tasks (clé lisible `CNT-123`, priorité 0–4, sous-tâches,
  estimation minutes + points, deadlines), task_labels, task_label_links,
  task_dependencies (blocks | relates | duplicates, anti-cycle).
- **Collaboration** : task_comments (threadés), task_reviews (validation
  inter-agents ou humaine), task_subscribers.
- **Suivi** : task_activity (historique par changement de champ),
  task_time_logs (estimé vs réel).
- **Notifications** : people (destinataires humains), notifications (outbox
  Telegram/e-mail/in-app), notification_preferences.

Arbitrages validés :

1. **Cycles/sprints** conservés dès maintenant.
2. **Estimation** en minutes ET points (aucun obligatoire).
3. **Table people** créée (routage des notifications humaines).
4. **E-mail via Resend** (variable d'env, implémenté en Phase 2).

Principes :

- Tout changement laisse une trace (`task_activity` local + `event_log` global au Lot 3).
- États en table (pas d'enum figé) → extensibles sans migration.
- Notifications en **outbox** : écriture découplée de l'envoi (fiabilité).
- Ce lot remplace l'esquisse `tasks/deps/reviews/events` du renforcement (non implémentée).

## Conséquences

- 45 tables au total, RLS activé sur les 45, accès backend via service_role.
- Les workflows n8n (envoi des notifications, génération des clés) viennent en Phase 2.
- **Validé sur PostgreSQL 16** : 45 tables, RLS sur les 45, 49 FK.

## Alternatives écartées

- **Enum d'états figé** : non extensible — écarté au profit de task_states.
- **Envoi synchrone des notifications** : fragile si un canal tombe — écarté au profit de l'outbox.
