# Dossier de passation — African College (pour ChatGPT / autre IA / développeur)

> **Comment utiliser ce document** : colle‑le en entier dans une nouvelle
> conversation ChatGPT. Il est **autonome** : il contient le contexte, l'état
> réel, les règles et la prochaine action. Commence par lui donner le « Prompt
> système » ci‑dessous, puis le reste.

---

## 1. Prompt système à coller en premier dans ChatGPT

```
Tu es le CTO d'African College, une marque e-commerce culturelle (collectif
d'artistes) sur Shopify. Tu reprends un projet déjà construit à ~99% côté code.
Ta mission : finir la mise en production et piloter une équipe de 12 agents IA
qui collaborent via n8n.

Règles absolues, non négociables :
1. AUCUNE écriture Shopify automatique. Toute action commerciale (produit,
   collection, prix, publication, dépense, commande Printful) exige une
   validation humaine via Telegram, tracée (date/utilisateur/coût/résultat).
2. Ne considère jamais un service « opérationnel » sans l'avoir testé réellement.
3. Ne demande jamais de coller un secret (token, clé API, mot de passe) dans le
   chat. Les secrets vivent uniquement dans le coffre n8n / Supabase.
4. Si une action nécessite l'accès live de l'utilisateur (n8n, Shopify admin,
   comptes), tu ne peux pas la faire à sa place : arrête-toi et explique
   précisément les clics/commandes.
5. Architecture évolutive : privilégie le plus robuste, simple et maintenable.

Style : concis, factuel, orienté ROI (80/20). Français.
```

---

## 2. Le projet en un paragraphe

African College vend du prêt‑à‑porter culturel (ligne « Leçon 001 », 16 produits,
35–70 €, devise EUR) sur Shopify. On a construit une plateforme d'orchestration
autonome : **Supabase** (données + mémoire + audit), **n8n** (workflows), une
**équipe de 12 agents IA** (OpenAI), **Telegram** (validations humaines + alertes),
**Printful** (print‑on‑demand). Doctrine : **build** uniquement l'avantage propre
(moteur de contenu de marque + data first‑party), **buy** le reste (Klaviyo,
Gorgias, avis, upsell). Toute action commerciale passe par une **validation
humaine**.

---

## 3. État réel (testé vs à faire) — 🟢 / 🟡 / 🔴

| Élément                                     | État | Preuve / raison                                                            |
| ------------------------------------------- | ---- | -------------------------------------------------------------------------- |
| Shopify — lecture boutique                  | 🟢   | testé live : 16 produits, commande #1001 PAID 39,06 €, emplacement actif   |
| Supabase — schéma/tables/logs               | 🟢   | 36 migrations, 68 tables, RLS 68/68, pgvector (testé `scripts/test-db.sh`) |
| n8n — 17 workflows (structure)              | 🟢   | JSON tous valides                                                          |
| Dashboards                                  | 🟢   | `fn_dashboard_snapshot()` (8 métriques) testé                              |
| Activation gardée des agents                | 🟢   | `fn_activation_ready` / `fn_activate_wave` testés (refus + succès)         |
| Sécurité secrets                            | 🟢   | aucun secret commité, `.env` ignoré                                        |
| n8n — instance live, credentials, variables | 🟡   | à provisionner par l'utilisateur                                           |
| Telegram / OpenAI / Printful                | 🟡   | testables seulement via le healthcheck dans n8n                            |
| Supabase — projet **prod**                  | 🟡   | `supabase db push` à faire                                                 |
| Agents actifs                               | 🟡   | 0 actif (activation bloquée tant que connexions non vertes)                |
| Webhooks Shopify                            | 🟡   | 0 enregistré (MVP en pull quotidien — acceptable)                          |
| Erreurs                                     | 🔴   | **aucune**                                                                 |

**Score de maturité : 80/100.** Les 20 points restants = exécution live dans
l'environnement de l'utilisateur (impossible sans ses accès).

---

## 4. Dépôt

- GitHub : `declo2022/la-collective`
- Branche de travail : `claude/african-college-architecture-0ovqxv`
- Dernier commit : `ab9e3de`
- Structure clé :
  - `supabase/migrations/` — 36 migrations SQL (schéma, RLS, fonctions, seeds)
  - `n8n/workflows/` — 17 workflows JSON
  - `shopify/shopify.app.reference.toml` — config app Shopify (méthode 2026)
  - `infra/.env.example` — toutes les variables (modèle, sans secrets)
  - `docs/` — `handoff.md`, `deployment.md`, `audit.md`, `agent-activation.md`,
    `architecture.md`, `organization.md`, playbooks, ADR, ce dossier

---

## 5. Architecture technique (l'essentiel)

- **Supabase / PostgreSQL 16 + pgvector** : source de vérité. Tables clés :
  `agents`, `people`, `tasks`, `approval_requests/decisions`, `event_log`
  (immuable, hash chain), `audit_trail`, `job_queue` + `dead_letter_queue`,
  `cost_ledger`, `kpi_snapshots`, `profitability_snapshots`,
  `connection_health`, `document_chunks` (RAG). RLS refus par défaut
  (le `service_role` de n8n contourne).
- **n8n Cloud** : orchestration. Workflows notables : `report-shopify-daily-cron`,
  `report-sales-margin-cron`, `monitor-anomalies-cron`, `report-dashboard-daily-cron`,
  `monitor-connections-healthcheck`, `monitor-cost-guardrail-cron`,
  `approval-send-telegram` / `approval-human-telegram`, `action-shopify-content-publish`
  (seule écriture Shopify, gated), libs `lib-error-handler` / `lib-approval-gate`.
- **Shopify (méthode 2026 Dev Dashboard)** : pas de token statique. n8n obtient un
  token via `client_credentials` (Client ID + Secret → token 24 h) avant chaque
  appel. Scopes lecture : `read_orders, read_products, read_inventory,
read_locations` (+ `write_content` seulement pour la publication gated). Store :
  `q1tha3-jx.myshopify.com`.
- **OpenAI** : résumés (modèle mini), contenu (modèle qualité), embeddings
  (`text-embedding-3-large`, 1536 dims). Plafond quotidien de tokens (garde‑fou).
- **Telegram** : validations humaines (boutons) + alertes + outbox.
- **Printful** : API Bearer, sync catalogue POD (Printful Manager).

---

## 6. Règles non négociables (gouvernance)

- Chaîne d'approbation : `shopify_write` = CEO IA → CTO → humain ;
  `external_publish` = CEO IA → humain.
- Moteur : `fn_open_approval` → notification Telegram → `fn_record_decision` →
  `fn_can_execute` (bloque techniquement l'exécution sans validation).
- Actions gardées (politiques `approval_policies`) : `shopify_product_update`,
  `shopify_collection_update`, `price_change`, `content_publish`, `product_create`,
  `product_delete`, `bulk_product_update`, `inventory_update`, `promo_discount`,
  `campaign_spend`, `support_refund`, `social_post`, `printful_sync`,
  `printful_order_create`.

---

## 7. Les 12 agents opérationnels + activation par vagues

Roster (tous `enabled=false` au départ) : CEO IA, Shopify Manager, SEO Manager,
Marketing Manager, Design Manager, Printful Manager, Customer Support, Analytics
Manager, Content Writer (= « Content Manager »), Social Media Manager, Product
Manager, Automation Manager. (+ 8 agents de gouvernance historiques + 2 rôles
humains : Claude Rivel = validateur final, Administrateur système.)

Activation **gardée** — uniquement si `select fn_activation_ready();` = `true` :

```sql
select * from fn_activate_wave(1);  -- CEO IA, Analytics Manager, Automation Manager  (observer 48 h)
select * from fn_activate_wave(2);  -- Shopify Manager, Product Manager, Printful Manager
select * from fn_activate_wave(3);  -- SEO Manager, Content Writer, Design Manager
select * from fn_activate_wave(4);  -- Marketing Manager, Social Media Manager, Customer Support
```

Coupure d'urgence : `update agents set enabled = false where enabled = true;`

---

## 8. ÉTAPE EN COURS (la prochaine action concrète)

L'utilisateur doit **exécuter le workflow `monitor-connections-healthcheck`** dans
son n8n :

1. Importer `n8n/workflows/monitor-connections-healthcheck.json`
   (n8n → ⋯ → Import from File).
2. Rattacher 2 credentials : `Supabase Postgres`, `Telegram Bot`.
3. Renseigner les Variables (voir §9).
4. **Execute Workflow** → il teste réellement Shopify (token+produits+commandes+
   webhooks+scopes), OpenAI, Telegram, Printful, Supabase, et renvoie sur Telegram
   un rapport unique **🟢/🟡/🔴**.
5. Lire le rapport.

Selon le résultat :

- **tout 🟢** → lancer `fn_activate_wave(1)`, observer 48 h, puis vagues 2→4 ;
- **un 🔴** → corriger la ligne indiquée (le plus souvent : variable manquante,
  token Shopify, ou app non installée / mauvaise organisation Dev Dashboard).

---

## 9. Secrets nécessaires (dans le coffre n8n — JAMAIS dans le chat)

Variables : `SHOPIFY_STORE_DOMAIN`, `SHOPIFY_CLIENT_ID`, `SHOPIFY_CLIENT_SECRET`,
`SHOPIFY_API_VERSION` (=2025-07), `TELEGRAM_BOT_TOKEN`, `TELEGRAM_APPROVALS_CHAT_ID`,
`OPENAI_API_KEY`, `PRINTFUL_API_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
(+ `SUPABASE_DB_URL` pour les migrations, `RESEND_API_KEY`/`EMAIL_FROM` pour l'email).

Credentials n8n : `Supabase Postgres`, `Telegram Bot`, `OpenAI (Bearer)`,
`Resend (Bearer)`. (Shopify/Printful/Supabase‑REST utilisent les Variables, pas de
credential dédié.)

---

## 10. Risques connus (et mitigations en place)

| Risque                              | Mitigation                                              |
| ----------------------------------- | ------------------------------------------------------- |
| Workflows jamais exécutés « live »  | logique SQL testée ; checklist `deployment §5`          |
| Secret exposé                       | secrets hors dépôt, rotation 90 j (SOP), gitleaks en CI |
| Coût OpenAI dérive                  | plafond quotidien + `fn_cost_status`                    |
| Agent activé sans connexions saines | `fn_activation_ready` bloque                            |
| RGPD (PII client)                   | email haché, RLS strict, région UE ; DPA à signer       |

---

## 11. Commandes utiles

```bash
# Tester toute la base localement (PostgreSQL 16 + pgvector)
bash scripts/test-db.sh          # avec PGHOST/PGUSER/PGPASSWORD définis

# Appliquer les migrations sur Supabase prod
supabase link --project-ref <ref-prod> && supabase db push
```

```sql
-- Santé des services (après un run du healthcheck)
select * from v_connection_health;
-- Tableau de bord consolidé
select jsonb_pretty(fn_dashboard_snapshot());
-- Prêt à activer les agents ?
select fn_activation_ready();
```

---

## 12. Definition of Done (mise en production complète)

- [ ] `v_connection_health` : tous les services `ok`.
- [ ] Vagues 1→4 d'agents activées et observées.
- [ ] Rapports quotidiens Shopify + dashboard reçus sur Telegram.
- [ ] Au moins une approbation Telegram testée de bout en bout (proposition →
      validation → exécution tracée).
- [ ] Backups Supabase (PITR) activés.
- [ ] (Phase 2) GA4/GSC branchés (trafic/conversion) + webhooks Shopify temps réel.
