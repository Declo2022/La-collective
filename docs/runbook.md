# Runbook — African College

> Quoi faire quand ça casse. Se remplit au fil des phases.

## Journal des incidents

| Date | Service | Symptôme | Cause | Résolution |
| ---- | ------- | -------- | ----- | ---------- |
| —    | —       | —        | —     | —          |

## Procédures

### Fuite de secret suspectée

Voir `docs/access-registry.md` → « Procédure en cas de fuite suspectée ».

### Kill-switch agents (à implémenter en Phase 3+)

Objectif : pouvoir stopper toute action agent en une commande Telegram.
Détail à définir quand la couche agents existera.

### n8n indisponible (Phase 2+)

1. Vérifier l'état de n8n Cloud (page statut).
2. Vérifier les webhooks Shopify en échec (à rejouer).
3. Réimporter les workflows depuis `n8n/workflows/` si nécessaire.
