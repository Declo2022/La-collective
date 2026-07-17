# Scripts

| Script                | Rôle                                                                                                                                     |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `test-db.sh`          | Applique toutes les migrations sur un PostgreSQL jetable et vérifie (tables, RLS). Utilisé par la CI (service `pgvector/pgvector:pg16`). |
| `apply-migrations.sh` | `supabase db push` sur le projet lié (avec confirmation).                                                                                |
| `export-n8n.sh`       | Exporte les workflows depuis n8n vers `n8n/workflows/` (versionnement).                                                                  |

Rendre exécutable : `chmod +x scripts/*.sh`.

## Exemple CI (déjà dans `.github/workflows/ci.yml`)

```bash
PGHOST=localhost PGUSER=postgres PGPASSWORD=postgres PGDATABASE=postgres \
  bash scripts/test-db.sh
```
