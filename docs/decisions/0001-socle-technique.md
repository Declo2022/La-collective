# ADR 0001 — Socle technique & décisions de cadrage

- **Statut :** accepté
- **Date :** 2026-07-16
- **Phase :** 0 — Fondations

## Contexte

Projet greenfield : construire African College, entreprise e-commerce pilotée
par agents IA. Il faut fixer la pile technique et les décisions structurantes
avant d'écrire du code métier.

## Décision

Pile retenue :

- **Vitrine :** Shopify (Admin GraphQL API, Online Store 2.0).
- **Raisonnement :** OpenAI API (chat + embeddings).
- **Orchestration :** n8n (n8n Cloud au démarrage).
- **Données/mémoire :** Supabase (Postgres, pgvector, Storage, Edge Functions, Auth).
- **Contrôle humain :** Telegram Bot API.
- **Mesure :** GA4, Google Search Console, Microsoft Clarity.
- **Code & CI/CD :** GitHub + Actions.
- **Runtime dépôt :** TypeScript/Node ≥ 20, formatage Prettier.

Décisions de cadrage :

1. Modèle **produits physiques** (stock, variantes, localisations).
2. Agents hébergés **dans n8n** d'abord ; extraction en service Node/TS possible en phase 5-6.
3. **n8n Cloud** au démarrage ; migration VPS auto-hébergé possible ensuite.
4. Autonomie : **brouillon + validation Telegram** sur toute action à impact.

## Conséquences

- Priorité agents : **Contenu + Merchandising**, puis SEO, Support, Analytics.
- Le schéma Supabase (Phase 1) modélise inventaire & localisations, en miroir de Shopify.
- Les workflows n8n et migrations Supabase sont **versionnés dans ce dépôt**.
- Aucun secret dans le dépôt ; gouvernance dans `docs/access-registry.md`.

## Alternatives écartées (pour mémoire)

- **Service agents dédié dès le départ** : plus robuste mais plus lent à démarrer — reporté.
- **n8n auto-hébergé immédiat** : plus de contrôle/coût mais charge ops — reporté.
