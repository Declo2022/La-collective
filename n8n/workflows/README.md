# Workflows n8n — MVP (10 workflows)

Périmètre resserré : **10 workflows**. **Shopify en lecture seule** (aucune
écriture). Toute action externe ou commerciale (#7 prospection, #8 service
client) passe par une **validation humaine Telegram** (#9) avant envoi.

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

## Prochains workflows

#9, puis lot B, etc. Décisions spécifiques déjà prises (voir `docs/mvp.md`) :

- **#7 Prospection** : recherche web externe + enrichissement IA + import de
  listes fournies.
- **#8 Service client** : demandes centralisées depuis Shopify, Gmail et
  Instagram ; **aucune réponse automatique** — proposition validée par un humain
  avant envoi.
