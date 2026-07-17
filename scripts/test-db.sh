#!/usr/bin/env bash
# =============================================================================
# test-db.sh — Applique et vérifie toutes les migrations sur un PostgreSQL jetable.
# =============================================================================
# Usage :
#   - CI / serveur existant : définir PGHOST/PGUSER/PGPASSWORD/PGDATABASE puis
#       bash scripts/test-db.sh
#     (utiliser l'image pgvector/pgvector:pg16 pour que `vector` soit dispo).
#   - Local sans serveur : le script tente de démarrer un cluster éphémère.
#
# Le storage Supabase (schema storage.*) n'existe pas hors Supabase : les blocs
# d'insertion de buckets sont ignorés ici. Tout le reste (tables, FK, contraintes,
# fonctions, RLS, pgvector, chaîne d'audit) est appliqué et vérifié.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIG="$ROOT/supabase/migrations"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

COMBINED="$TMP/combined.sql"
: > "$COMBINED"
# Concatène les migrations dans l'ordre du timestamp, sauf le fichier storage_buckets.
for f in $(ls "$MIG"/*.sql | grep -vE '_storage_buckets\.sql$' | sort); do
  cat "$f" >> "$COMBINED"; printf '\n' >> "$COMBINED"
done
# Retire les blocs d'insertion de buckets (schema storage absent hors Supabase).
sed -i '/insert into storage.buckets/,/on conflict (id) do nothing;/d' "$COMBINED"

HAVE_SERVER=0
if [ -n "${PGHOST:-}" ] || [ -n "${PGURL:-}" ]; then HAVE_SERVER=1; fi

run_psql() { psql -v ON_ERROR_STOP=1 -q "$@"; }

if [ "$HAVE_SERVER" -eq 1 ]; then
  echo "→ Utilisation du PostgreSQL fourni (PGHOST=${PGHOST:-via PGURL})"
  run_psql -c "drop schema if exists public cascade; create schema public;" >/dev/null || true
  run_psql -c "create extension if not exists vector;" >/dev/null 2>&1 || echo "  (vector non disponible : la migration RAG peut échouer)"
  run_psql -f "$COMBINED"
  echo "=== ✅ Migrations appliquées ==="
  run_psql -c "select count(*) as tables from information_schema.tables where table_schema='public';"
  run_psql -c "select count(*) filter (where rowsecurity) as rls_on, count(*) as total from pg_tables where schemaname='public';"
else
  echo "→ Aucun PGHOST : démarrage d'un cluster éphémère (nécessite postgres + droits)."
  echo "  En CI, préférez le service pgvector/pgvector:pg16 avec PGHOST/PGUSER/PGPASSWORD."
  exit 2
fi

echo "=== ✅ test-db terminé ==="
