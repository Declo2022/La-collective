# Workflow #2 — Analyse ventes & marges

`report-sales-margin-cron` · Lot B · valeur commerciale **directe** (marge réelle).

## Objectif

Chaque semaine : performance de ventes **et marge réelle** (via COGS) — CA,
marge €/%, couverture coût, produits à forte marge (à pousser) et à faible
marge (à corriger). Base de décision pour le merchandising.

## La marge exige un coût (COGS)

Shopify ne fournit pas le coût d'achat dans les données de commande. On stocke
donc `product_variants.unit_cost`, alimenté par :

1. **Import CSV** → `fn_import_variant_costs('[{"sku":"BI-01","unit_cost":"20"}, …]')`.
2. **Shopify `InventoryItem.unitCost`** (champ « cost per item ») lu par un
   workflow de sync (GraphQL) puis passé à `fn_import_variant_costs`.

Les lignes sans coût connu sont **exclues du calcul de marge** ; la transparence
est assurée par `cost_coverage_pct` (part du CA dont le coût est connu).

## Fonctionnement

1. **Cron hebdo** (lundi 07:00).
2. `fn_sales_margin_report(from, to)` — agrégats SQL : revenue, cogs,
   gross_margin, gross_margin_pct, cost_coverage_pct, top/low par marge.
   Écrit `kpi_snapshots(gross_margin)`. Exclut les commandes remboursées.
3. **Résumé IA** (modèle mini, sur les chiffres calculés).
4. Journalise le coût, envoie sur Telegram.

## Optimisation des coûts API

- Agrégats en SQL ; l'IA ne voit qu'un petit JSON (~250 tokens). Modèle mini.
- Hebdomadaire (pas quotidien) → coût ~0,01 €/mois.

## Prérequis

- Migrations (dont `…210000_wf2_sales_margin.sql`).
- Coûts chargés (au moins partiellement) pour une marge utile.
- Credentials : `Supabase Postgres`, `OpenAI (Bearer)`, `Telegram Bot`.
- Variables : `OPENAI_SUMMARY_MODEL`, `TELEGRAM_APPROVALS_CHAT_ID`.

## Déploiement

1. **Charger les coûts** : préparer un CSV (sku, unit_cost) et appeler
   `select fn_import_variant_costs('[…]'::jsonb);` (ou brancher la sync Shopify).
2. Importer `report-sales-margin-cron.json`, associer les credentials.
3. **Test manuel** → vérifier le message Telegram + `kpi_snapshots(gross_margin)`.
4. Activer le cron hebdo.

## Sécurité

- **Lecture seule** — aucune écriture Shopify.

## KPI

- `gross_margin` (%), CA, couverture coût.
- Produits à pousser / à corriger (décisions merchandising).

## Tests (PostgreSQL 16)

- Import de 2 coûts ; rapport : CA 155 €, COGS 68 €, marge 87 € (56,1%),
  couverture 100%, top/low corrects, commande remboursée exclue, KPI écrit. ✓
