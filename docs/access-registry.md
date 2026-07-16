# Registre des accès — African College

> Source de vérité sur **qui détient quelle clé, avec quel périmètre, stockée où, et sa politique de rotation**.
> Aucune valeur secrète ne figure ici — uniquement la gouvernance.

## Principes

- **Moindre privilège** : chaque clé n'a que les scopes strictement nécessaires.
- **Séparation dev / prod** : chaque service a des identifiants distincts par environnement.
- **Stockage** : secrets d'exécution dans **n8n Cloud** ; secrets de CI dans **GitHub Secrets** ; jamais de clé en clair dans le dépôt.
- **Rotation** : toute clé est révocable et rotée selon le rythme ci-dessous (ou immédiatement en cas de doute).

## Inventaire

| Service  | Clé / identifiant      | Scope minimal                                                                | Stockage       | Env        | Rotation  |
| -------- | ---------------------- | ---------------------------------------------------------------------------- | -------------- | ---------- | --------- |
| Shopify  | Admin API access token | `read/write_products`, `read_orders`, `read/write_content`, `read_inventory` | n8n Cloud      | dev + prod | 90 j      |
| Shopify  | Webhook HMAC secret    | vérification signature                                                       | n8n Cloud      | dev + prod | 90 j      |
| OpenAI   | API key                | usage API (projet dédié + plafond)                                           | n8n Cloud      | dev + prod | 90 j      |
| Supabase | `service_role` key     | accès serveur complet (jamais côté client)                                   | n8n Cloud      | dev + prod | 90 j      |
| Supabase | `anon` key             | lecture publique restreinte (RLS)                                            | n8n / thème    | dev + prod | 180 j     |
| Supabase | DB connection URL      | migrations (Supabase CLI)                                                    | GitHub Secrets | dev + prod | 90 j      |
| Telegram | Bot token              | envoi/réception messages du bot                                              | n8n Cloud      | dev + prod | au besoin |
| Google   | Service account JSON   | `analytics.readonly` + `webmasters.readonly`                                 | n8n Cloud      | prod       | 180 j     |
| Clarity  | Data Export token      | export des signaux UX                                                        | n8n Cloud      | prod       | 180 j     |
| n8n      | API key                | export/import des workflows (CI)                                             | GitHub Secrets | dev + prod | 90 j      |
| GitHub   | `GITHUB_TOKEN`         | fourni auto par Actions                                                      | —              | CI         | auto      |

## Procédure en cas de fuite suspectée

1. **Révoquer** la clé immédiatement chez le fournisseur.
2. **Émettre** une nouvelle clé, mettre à jour n8n Cloud / GitHub Secrets.
3. **Journaliser** l'incident (date, service, cause probable) dans `docs/runbook.md`.
4. **Notifier** via le canal Telegram d'alerte.

## À faire au démarrage (checklist Phase 0)

- [ ] Créer les 2 projets Supabase (dev + prod).
- [ ] Créer le _development store_ Shopify + custom app avec scopes minimaux.
- [ ] Créer le projet OpenAI dédié + plafond de dépense.
- [ ] Créer le bot Telegram (@BotFather) + récupérer le chat d'approbation.
- [ ] Créer le service account Google, l'autoriser sur GA4 + Search Console.
- [ ] Créer le projet Clarity + récupérer le token d'export.
- [ ] Provisionner l'espace n8n Cloud + clé API.
- [ ] Renseigner tous les secrets dans n8n Cloud et GitHub Secrets.
