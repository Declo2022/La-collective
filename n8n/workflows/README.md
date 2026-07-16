# Workflows n8n — Phase 1

Six workflows, tous en **écriture vers Supabase uniquement** (aucune écriture
Shopify en Phase 1). Le JSON importable est construit dans **n8n Cloud** (avec
les credentials), puis **exporté ici** (`*.json`) pour être versionné.

Ce dossier contient d'abord les **spécifications** ; les exports JSON arrivent
au fur et à mesure de la construction dans n8n Cloud.

Déclencheurs : `webhook` (temps réel) · `cron` (planifié).

---

## 1. `shopify-webhook-ingest` — webhook

**But :** ingérer les événements Shopify en temps réel.

**Étapes :**

1. Webhook n8n (un par topic, ou un routeur).
2. Vérifier la signature **HMAC** (`SHOPIFY_WEBHOOK_SECRET`). Si invalide → `hmac_valid=false`, statut `failed`, stop.
3. Déduplication par `webhook_id` (en-tête `X-Shopify-Webhook-Id`) → si déjà vu, statut `skipped`.
4. Insérer l'événement brut dans `webhook_events`.
5. Router selon `topic` et **upsert** la table miroir (comparer `shopify_updated_at`, ignorer si plus ancien).
   - Pour `customers/*` : calculer `email_hash` (SHA-256), **ne pas** stocker l'email en clair.
6. Marquer `webhook_events.status = 'processed'`, `processed_at = now()`.

**Écrit :** `webhook_events`, `products`, `product_variants`, `collections`, `orders`, `order_line_items`, `customers`, `inventory_levels`.

**Topics :** `products/create|update|delete`, `orders/create|updated`, `inventory_levels/update`, `collections/update`, `customers/create|update`.

---

## 2. `shopify-catalog-backfill` — cron (nuit)

**But :** synchronisation initiale et réconciliation périodique du catalogue.

**Étapes :**

1. Lancer une **bulk operation** GraphQL (`bulkOperationRunQuery`) sur produits/variantes/collections/emplacements/stock.
2. **Polling** du statut jusqu'à `COMPLETED` ; récupérer l'URL du fichier **JSONL**.
3. Streamer le JSONL, **upsert** par lots dans les tables miroir.
4. Mettre à jour `sync_state` (`resource='products'…`, `last_synced_at`, `status`).

**Écrit :** tables du domaine A + `sync_state`.

---

## 3. `ga4-daily-pull` — cron (quotidien)

**But :** agrégats d'audience/conversion par page et source.

**Étapes :**

1. Appeler la **GA4 Data API** (service account Google) sur une fenêtre **J-3 → J-1** (rattrapage de la latence).
2. Dimensions : `date`, `pagePath`, `sessionSourceMedium` ; métriques : sessions, users, engaged, conversions, revenue.
3. **Upsert** dans `ga4_daily` (clé `date,page_path,source_medium`).
4. Mettre à jour `sync_state` (`resource='ga4'`).

**Écrit :** `ga4_daily`, `sync_state`.

---

## 4. `gsc-daily-pull` — cron (quotidien)

**But :** performance SEO (requêtes, positions, CTR).

**Étapes :**

1. Appeler la **Search Analytics API** (`searchanalytics.query`) sur J-3 (délai GSC ~2-3 j).
2. Dimensions : `date`, `query`, `page`.
3. **Upsert** dans `gsc_daily` (clé `date,query,page`).
4. Mettre à jour `sync_state` (`resource='gsc'`).

**Écrit :** `gsc_daily`, `sync_state`.

---

## 5. `clarity-daily-pull` — cron (quotidien)

**But :** signaux UX (rage/dead clicks, scroll).

**Étapes :**

1. Appeler la **Data Export API** de Clarity (`CLARITY_API_TOKEN`).
2. Agréger par `page_path` (signal qualitatif, granularité limitée).
3. **Upsert** dans `clarity_daily` (clé `date,page_path`).
4. Mettre à jour `sync_state` (`resource='clarity'`).

**Écrit :** `clarity_daily`, `sync_state`.

---

## 6. `sync-health-monitor` — cron (horaire)

**But :** garde-fou de fraîcheur des données ; premier usage du canal Telegram.

**Étapes :**

1. Lire `sync_state` : détecter les ressources non rafraîchies dans leur SLA.
2. Lire `webhook_events` : taux d'échec (`status='failed'`) sur la dernière heure.
3. Si anomalie → message **Telegram** (`TELEGRAM_APPROVALS_CHAT_ID`).

**Lit :** `sync_state`, `webhook_events`. **Notifie :** Telegram.
