# Workflows n8n (13)

**13 workflows** versionnés et JSON-valides. **Shopify en lecture seule**, à
l'exception de la publication de contenu (`action-shopify-content-publish`),
**toujours derrière l'approbation humaine**. Toute action externe/commerciale
passe par la **validation Telegram** (#9).

## Inventaire

| Workflow | Rôle |
| --- | --- |
| `monitor-cost-guardrail-cron` | #10 garde-fou coût IA |
| `lib-error-handler` | #10 reprise d'erreurs (log + file) |
| `monitor-deadletter-cron` | alerte jobs en échec définitif |
| `lib-approval-gate` | #9 garde-fou `fn_can_execute` |
| `approval-send-telegram` | #9 envoi demande (boutons) |
| `approval-human-telegram` | #9 réception décision |
| `notify-outbox-dispatch-cron` | livraison fiable des notifications |
| `report-shopify-daily-cron` | #1 rapport quotidien |
| `monitor-anomalies-cron` | #3 détection d'anomalies |
| `report-sales-margin-cron` | #2 ventes & marges (COGS) |
| `rag-ingest-document-task` | BUILD ingestion RAG |
| `content-draft-task` | BUILD génération de contenu (brouillon) |
| `action-shopify-content-publish` | BUILD publication gated (write_content) |

Le cœur logique vit dans des **fonctions Postgres** (migrations), déjà testées ;
les nœuds n8n restent fins. Import/config : `docs/deployment.md`.

Les workflows sont construits dans **n8n Cloud** (avec les credentials), puis
exportés ici (`*.json`) pour être versionnés. Le cœur logique vit dans des
**fonctions Postgres** (migration `…170000_wf10_observability_core.sql`), déjà
testées, que les workflows appellent — les nœuds n8n restent fins.

## Ordre de développement (par priorité)

| Lot | Workflows |
| --- | --- |
| **A — socle** | #10 Journalisation/coûts/erreurs · #9 Validation Telegram |
| **B — lecture** | #1 Rapport Shopify · #3 Anomalies · #2 Ventes & marges · #4 Veille SEO |
| **C — contenu** | #5 Calendrier éditorial · #6 Brouillons de contenu |
| **D — actions validées** | #8 Service client · #7 Prospection partenaires |

Chaque workflow est développé, testé et validé avant de passer au suivant.

---

## ✅ #10 — Journalisation, coûts & erreurs (en cours)

**Cœur SQL (testé sur PostgreSQL 16)** — `…170000_wf10_observability_core.sql` :

| Fonction | Rôle |
| --- | --- |
| `fn_log_event(...)` | écrit une entrée `event_log` (+ attribue le coût) |
| `fn_track_cost(...)` | agrège le coût du jour dans `cost_ledger` |
| `fn_cost_status(cap)` | usage IA du jour vs plafond → `ok` / `warn` (≥80%) / `halt` (≥100%) |
| `fn_enqueue_job(...)` | met un job en file (durable) |
| `fn_claim_due_jobs(n)` | réclame les jobs dus (verrou concurrentiel) |
| `fn_job_succeeded(id)` | marque un job réussi |
| `fn_job_failed(id, err)` | reprise (backoff exponentiel) puis dead-letter |
| vue `v_cost_today` | coût du jour ventilé par source |

**Workflows n8n (à importer dans n8n Cloud) :**

- `monitor-cost-guardrail-cron.json` — cron horaire → `fn_cost_status` → alerte
  Telegram si `warn`/`halt`. Garde-fou coût (protège la marge).
- `lib-error-handler.json` — brique appelée par les autres workflows : journalise
  l'erreur (`fn_log_event`) et met en file avec reprise (`fn_enqueue_job`).

> Les fonctions SQL sont validées ici. Les deux JSON n8n sont **importables** et
> doivent être exécutés dans n8n Cloud (credentials `Supabase Postgres` +
> `Telegram Bot`) pour la validation « live » — impossible à exécuter hors n8n.

**Reste à faire pour clôturer #10 :** provisionner n8n Cloud, importer les 2
workflows, brancher les credentials, faire un run réel (vérifier l'alerte
Telegram à 80%).

---

## ✅ #9 — Validation humaine Telegram (en cours)

**Cœur SQL (testé sur PostgreSQL 16)** — `…180000_wf9_approval_engine.sql`.
Moteur **générique** : marche pour tout type d'action via `approval_policies`
(ajouter une action commerciale = insérer une ligne, zéro code).

| Fonction | Rôle |
| --- | --- |
| `fn_open_approval(proposal, action_type, cost)` | ouvre une demande selon la politique (défaut restrictif) |
| `fn_record_decision(request, approver…, decision)` | enregistre la décision (immuable + audit) et avance la chaîne |
| `fn_can_execute(proposal)` | **garde-fou** : true seulement si approuvé |
| `fn_record_execution_result(request, result)` | enregistre le résultat (applied/failed) |
| vue `v_pending_approvals` | file des approbations en attente |

Chaque approbation enregistre **date** (`created_at`), **utilisateur** (`decided_by`
+ ledger par étape), **coût** (`cost_usd`), **résultat** (`result`).

**Workflows n8n (à importer) :**

- `lib-approval-gate.json` — brique appelée avant toute action ; `fn_can_execute`.
- `approval-send-telegram.json` — envoie la demande avec boutons Valider/Refuser.
- `approval-human-telegram.json` — reçoit le clic, enregistre la décision humaine.

> Fonctions SQL validées ici (chaîne CEO→CTO→humain, refus, garde-fou,
> immuabilité). Les JSON n8n sont importables et à exécuter dans n8n Cloud —
> voir `docs/setup-n8n-telegram.md`.

**Reste à faire pour clôturer #9 :** provisionner n8n Cloud + bot Telegram,
importer les 3 workflows, faire un run réel (bouton → décision enregistrée).

---

## Prochains workflows

Lot B : #1, #3, #2, #4. Décisions spécifiques déjà prises (voir `docs/mvp.md`) :

- **#7 Prospection** : recherche web externe + enrichissement IA + import de
  listes fournies.
- **#8 Service client** : demandes centralisées depuis Shopify, Gmail et
  Instagram ; **aucune réponse automatique** — proposition validée par un humain
  avant envoi.
