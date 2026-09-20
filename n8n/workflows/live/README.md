# Workflows n8n LIVE (production réelle)

> Ce dossier accueille les exports JSON des workflows **réellement actifs dans
> n8n Cloud**, pour qu'ils soient versionnés (revue, rollback, audit). C'est le
> livrable n°1 de la **Phase 0 — Vérité unique** (voir
> `docs/audit-lecture-seule-2026-08-07.md`).

## Workflows attendus

| Nom dans n8n Cloud                  | Fichier attendu ici                     | Statut      |
| ----------------------------------- | --------------------------------------- | ----------- |
| Telegram + OpenAI Bot               | `telegram-openai-bot.json`              | ⏳ à exporter |
| African College – Équipe IA Complète | `african-college-equipe-ia-complete.json` | ⏳ à exporter |

Tout autre workflow actif ou archivé dans n8n Cloud doit aussi être exporté ici.

## Comment exporter

### Option A — manuelle (2 minutes, aucun prérequis)

1. Ouvrir le workflow dans n8n Cloud.
2. Menu `⋯` (en haut à droite) → **Download** → un fichier `.json` est téléchargé.
3. Le déposer dans ce dossier avec le nom attendu ci-dessus, committer.

> L'export n8n **ne contient jamais les secrets** : les credentials sont
> référencés par identifiant/nom uniquement. Il est donc sûr à committer.

### Option B — automatique (API)

1. n8n Cloud → **Settings → API** → créer une clé API.
2. La renseigner en local (jamais committée) :

   ```bash
   export N8N_BASE_URL="https://<workspace>.app.n8n.cloud"
   export N8N_API_KEY="<clé>"
   ./scripts/export-n8n.sh
   ```

3. Le script écrit tous les workflows dans `n8n/workflows/` — déplacer les
   exports de production dans `live/` et committer.

## Règles

- **Jamais de secret** dans ce dossier (le scan Gitleaks de la CI le vérifie).
- Chaque modification faite dans n8n Cloud doit être ré-exportée ici — l'objectif
  Phase 1+ est d'automatiser cet export (cron CI hebdomadaire).
- La revue de ces exports alimentera la refonte du bot (routeur, Phase 2).
