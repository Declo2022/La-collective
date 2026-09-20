# CHANGELOG — African College AI

Format : date · bloc · détail. Le plus récent en haut.

## 2026-09-20 — V2.1 : robustesse du bot AC Core (validé par le fondateur)

### `ac-core-telegram-bot.json` (toujours brouillon, non activé)

- **Gestion d'erreurs** : sorties d'erreur sur les 3 nœuds critiques (Postgres
  mémoire, routeur OpenAI, réponse OpenAI) → `fn_log_error` (severity
  `critical`) + **réponse de secours** à l'utilisateur (chat.id dynamique).
  La journalisation tolère une base indisponible (`continueRegularOutput`).
- **L'utilisateur d'abord** : la réponse Telegram part **avant** l'écriture
  mémoire/cache ; un échec d'écriture (après 3 retries) ne prive plus
  l'utilisateur de sa réponse.
- **Escalade de modèle** : intention `analyste` → `OPENAI_DEFAULT_MODEL`
  (gpt-4.1, 480 tokens) ; les autres restent sur le modèle mini (320 tokens).
- **Cache anti-péremption** : clé de cache **datée** (UTC) — jamais de réponse
  de la veille ; cache **désactivé** (lecture et écriture) sur les questions
  temporelles (aujourd'hui, hier, maintenant, cette semaine…).
- Tests : JSON valide, syntaxe des 4 Code nodes (`node --check`), simulation
  du nœud SQL (cache normal vs question temporelle), câblage vérifié.

## 2026-07-19 — Phase V2 (périmètre 6 workflows)

### Telegram — durcissement + bot AC Core

- **Retry auto** ajouté sur les 10 workflows à nœud Telegram (`retryOnFail`,
  `maxTries=4`, `waitBetweenTries=2000`) — tolérance timeout / rate-limit 429.
- **Credential unique** confirmé partout (`Telegram Bot`), aucune divergence.
- **Distinction chat_id** : broadcasts (rapports/alertes) = `TELEGRAM_APPROVALS_CHAT_ID`
  (diffusion groupe, volontaire) ; réponses utilisateur = `chat.id` dynamique.
- **`ac-core-telegram-bot.json`** (brouillon) : bot 24/7 — Telegram Trigger →
  contexte → mémoire+cache+dashboard → (cache 24 h : réponse immédiate) →
  routeur d'intention (modèle léger) → persona (Singa/Opérateur/Analyste/
  garde-fou écriture) → mémorise+cache → réponse. `chat.id` **dynamique**,
  retry sur LLM/Telegram, aucune écriture Shopify. SQL du bot testé sur la base
  (mémoire, cache hit/miss, profil, dashboard).

### Ajouté

- **Bloc schéma V2** (`supabase/migrations/20260719120000_ac_v2_memory_cache_errors.sql`) :
  - `conversation_memory` (+ `fn_conv_remember`, `fn_conv_recent`, `fn_conv_user_profile`)
    — mémoire conversationnelle + reconnaissance utilisateur (AC Memory).
  - `response_cache` (+ `fn_cache_get`, `fn_cache_put`) — cache 24 h anti-coût LLM (AC Memory).
  - `errors` (+ `fn_log_error`) — journal d'erreurs global n8n (AC Error Handler),
    `fn_log_error` renvoie `true` si `critical` (déclenche l'alerte Telegram).
  - Réutilise `audit_log` existant (pas de doublon).
- Testé sur PostgreSQL 16 + pgvector : 37 migrations, 71 tables, RLS 71/71 ;
  fonctions vérifiées (mémoire, cache hit/miss, erreurs critique/warning).

### Contexte

- Recentrage sur 6 workflows (AC Core / Bot Telegram, AC Memory, AC Écritures
  validées, AC Monitoring, AC Backup, AC Error Handler). SEO/Marketing/Réseaux/
  Finance/Analytics avancé reportés jusqu'à traction réelle.
- Audit : les fichiers de référence V2 (`ARCHITECTURE.md`, `equipe_ia_prompts.md`,
  `workflow_telegram_bot_v3.json`, etc.) ne sont pas dans cette branche —
  build parallèle à réconcilier (voir rapport de session).

## ≤ 2026-07-18 — Fondation (Phase 1 → mise en production)

- Supabase : 36 migrations (schéma, RLS, RAG/pgvector, audit immuable, file de
  jobs, approbations, KPI/coûts, santé des connexions, dashboards, activation
  gardée des agents). 20 agents seedés.
- n8n : 17 workflows (rapports Shopify/marges/anomalies, dashboard, garde-fou
  coût, dead-letter, approbations Telegram, healthcheck, contenu gated).
- Shopify : connexion 2026 Dev Dashboard (client_credentials).
- Docs : handoff, deployment, audit, agent-activation, passation-chatgpt.
