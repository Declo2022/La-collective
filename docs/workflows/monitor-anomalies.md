# Workflow #3 — Détection d'anomalies produits/commandes

`monitor-anomalies-cron` · Lot B · valeur commerciale **directe** (ventes protégées).

## Objectif

Repérer chaque jour ce qui fait perdre des ventes ou de la marge : ruptures de
stock, prix nuls/erronés, remboursements, commandes inhabituelles, produits
actifs sans vente. Alerter immédiatement — **aucune correction automatique**.

## Fonctionnement

1. **Cron quotidien** (08:00).
2. **`fn_detect_anomalies(p_days, p_high_value)`** — 100% SQL, scanne 5 familles :
   - `unusual_order` (montant > seuil, veille)
   - `refund` (remboursements, veille)
   - `zero_price` (variantes à prix nul/absent)
   - `stockout` (stock ≤ 0)
   - `no_sales` (produit actif sans vente depuis N jours, match par SKU)
3. Insère une **alerte** (`alerts`) si anomalies + journalise (`event_log`).
4. **IF count > 0** → message Telegram formaté.

`errorWorkflow: lib-error-handler`.

## Optimisation des coûts API

- **Aucun appel LLM** — détection purement SQL déterministe. **Coût ≈ 0 €.**
  (Une rupture de stock n'a pas besoin d'IA pour être vue.)

## Prérequis

- Migrations appliquées (dont `…200000_wf3_anomalies.sql`).
- Idéalement alimenté par #1 (commandes) ; les familles `stockout`/`zero_price`/
  `no_sales` deviennent pleinement utiles quand le catalogue/stock est synchronisé.
- Credentials n8n : `Supabase Postgres`, `Telegram Bot`.
- Variable : `TELEGRAM_APPROVALS_CHAT_ID`.

## Déploiement

1. Importer `monitor-anomalies-cron.json`.
2. Associer les credentials.
3. **Test manuel** : insérer une anomalie de test (ex. commande à 650 €), exécuter
   → vérifier l'alerte Telegram + la ligne dans `alerts`.
4. Ajuster les seuils (`p_high_value`, `p_days`) selon le volume réel.
5. Activer le cron.

## Sécurité

- **Lecture seule** — aucune écriture Shopify. Uniquement des alertes.

## KPI

- Anomalies détectées / jour.
- Taux de faux positifs (à surveiller, ajuster les seuils).
- Délai de détection (rupture repérée en < 24 h).

## Tests (PostgreSQL 16)

- 5 types détectés sur données de test ; alerte créée. ✓
- Cas sain → 0 anomalie (pas de faux positif). ✓
