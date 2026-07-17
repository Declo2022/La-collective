#!/usr/bin/env bash
# =============================================================================
# apply-migrations.sh — Applique les migrations sur un projet Supabase.
# =============================================================================
# Prérequis : Supabase CLI installé + `supabase link --project-ref <ref>`.
# Usage : bash scripts/apply-migrations.sh
set -euo pipefail

if ! command -v supabase >/dev/null 2>&1; then
  echo "❌ Supabase CLI absent. Installer : https://supabase.com/docs/guides/cli"
  exit 1
fi

echo "→ Migrations à appliquer :"
ls -1 supabase/migrations/*.sql | sed 's#supabase/migrations/#  #'

read -r -p "Confirmer 'supabase db push' sur le projet lié ? [y/N] " ok
[ "${ok:-}" = "y" ] || { echo "Annulé."; exit 0; }

supabase db push
echo "=== ✅ Migrations poussées ==="
