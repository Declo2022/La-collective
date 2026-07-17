# Configuration n8n Cloud & bot Telegram

Objectif : pouvoir importer et exécuter les premiers workflows (#10, #9) dès que
les accès sont prêts. Rien ici ne contient de secret — uniquement la procédure.

## 1. Bot Telegram (via @BotFather)

1. Ouvrir Telegram, parler à **@BotFather** → `/newbot` → nom + username.
2. Récupérer le **token** → à mettre dans `TELEGRAM_BOT_TOKEN` (coffre n8n).
3. Créer un **groupe privé** « African College — Validations » et y ajouter le bot.
4. Récupérer le **chat_id** du groupe → `TELEGRAM_APPROVALS_CHAT_ID`.
   (Astuce : ajouter @RawDataBot au groupe une minute, lire le `chat.id`, puis le retirer.)
5. Dans BotFather : `/setprivacy` → **Disable** (pour que le bot voie les messages du groupe).

## 2. Supabase

1. Créer les projets **dev** puis **prod**.
2. Appliquer les migrations : `supabase link --project-ref <ref>` puis `supabase db push`.
3. Récupérer la **chaîne de connexion Postgres** (Settings → Database) →
   credential n8n « Supabase Postgres » (host, db, user, password, port 5432, SSL on).

## 3. n8n Cloud

1. Créer un workspace n8n Cloud (Starter suffit pour le MVP).
2. **Credentials** à créer :
   - `Supabase Postgres` (type Postgres) — depuis la chaîne de connexion ci-dessus.
   - `Telegram Bot` (type Telegram API) — avec `TELEGRAM_BOT_TOKEN`.
3. **Variables d'environnement** (Settings → Variables) :
   - `TELEGRAM_APPROVALS_CHAT_ID`
   - `OPENAI_DAILY_TOKEN_CAP` = `500000`
4. **Importer les workflows** (`n8n/workflows/*.json`) :
   - `monitor-cost-guardrail-cron` (#10)
   - `lib-error-handler` (#10)
   - `lib-approval-gate` (#9)
   - `approval-send-telegram` (#9)
   - `approval-human-telegram` (#9)
5. Les workflows sont importés **inactifs** (`active:false`) — les activer un par un après test.

## 4. Premiers tests réels (checklist)

- [ ] **#10 garde-fout** : baisser temporairement `OPENAI_DAILY_TOKEN_CAP` à `1`,
      insérer un coût de test (`select fn_log_event('llm_call','test','service',null,null,null,null,null,'info',10,0.01,null,null,'{}');`),
      exécuter `monitor-cost-guardrail-cron` → une alerte doit arriver sur Telegram.
- [ ] **#9 envoi** : appeler `approval-send-telegram` avec un `request_id` de test →
      un message avec boutons Valider/Refuser doit apparaître.
- [ ] **#9 décision** : cliquer **Valider** → `approval-human-telegram` doit
      enregistrer la décision (vérifier `approval_decisions` + `approval_requests.result`).
- [ ] **#9 gate** : `select fn_can_execute('<proposal_id>')` doit refléter la décision.

## Rappels de sécurité

- Aucune écriture Shopify dans le MVP.
- Toute action commerciale (publication, e-mail, promo, prix, produit) passe par
  une politique `approval_policies` → validation Telegram avant exécution.
- Les décisions sont immuables (`approval_decisions`) et chaînées (`audit_trail`).
