#!/usr/bin/env bash
# =============================================================================
# export-n8n.sh — Exporte les workflows depuis n8n vers le dépôt (versionnement).
# =============================================================================
# Prérequis : N8N_BASE_URL + N8N_API_KEY définis (voir infra/.env.example).
# Récupère tous les workflows via l'API n8n et les écrit dans n8n/workflows/.
set -euo pipefail

: "${N8N_BASE_URL:?définir N8N_BASE_URL}"
: "${N8N_API_KEY:?définir N8N_API_KEY}"

OUT="$(cd "$(dirname "$0")/.." && pwd)/n8n/workflows"
mkdir -p "$OUT"

echo "→ Récupération des workflows depuis $N8N_BASE_URL"
curl -sS -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_BASE_URL/api/v1/workflows?limit=250" \
  | python3 -c '
import sys, json, re
data = json.load(sys.stdin).get("data", [])
for wf in data:
    name = re.sub(r"[^a-zA-Z0-9_-]", "-", wf.get("name", "workflow"))
    with open(f"'"$OUT"'/{name}.json", "w") as f:
        json.dump(wf, f, ensure_ascii=False, indent=2)
    print(f"  ✓ {name}.json")
'
echo "=== ✅ Export terminé — vérifier puis committer ==="
