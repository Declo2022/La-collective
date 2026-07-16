# African College

Entreprise e-commerce **pilotée par des agents IA**. La vitrine vit sur Shopify ;
derrière, un système multi-agents prend en charge le contenu, le merchandising,
le SEO, le support et la croissance, orchestré par n8n, avec Supabase comme
mémoire/entrepôt et OpenAI comme moteur de raisonnement. L'humain garde le
contrôle via un poste de commande Telegram (validation des actions à impact).

> **État : Phase 0 — Fondations.** Ce dépôt pose le socle (structure, secrets,
> CI, gouvernance). Aucun agent ni workflow métier n'est encore actif.

## Architecture

Voir [`docs/architecture.md`](docs/architecture.md) pour le blueprint complet
(7 couches, feuille de route en 7 phases, matrice d'intégration, risques).

```
la-collective/
├── docs/            # architecture, registre des accès, runbook, décisions (ADR)
├── infra/           # gabarit d'environnement (.env.example)
├── supabase/        # migrations SQL + seed (Phase 1+)
├── n8n/             # workflows exportés, versionnés (Phase 2+)
├── agents/          # orchestrateur & agents IA (Phase 3+)
├── scripts/         # utilitaires
└── .github/         # CI (Actions) + template de PR
```

## Démarrer (développeur)

```bash
npm ci
npm run format:check      # vérifie le formatage (utilisé par la CI)
cp infra/.env.example .env # puis remplir les valeurs (jamais commité)
```

## Feuille de route

| Phase | Objet                                      | État         |
| ----- | ------------------------------------------ | ------------ |
| 0     | Fondations & gouvernance                   | **en cours** |
| 1     | Socle données & instrumentation            | à venir      |
| 2     | Backbone d'automatisation (n8n)            | à venir      |
| 3     | Couche agents — Contenu & SEO              | à venir      |
| 4     | Poste de commande humain (Telegram / HITL) | à venir      |
| 5     | Agents métier avancés                      | à venir      |
| 6     | Boucle autonome & durcissement             | à venir      |

## Sécurité

Aucun secret n'est stocké dans le dépôt. Voir
[`docs/access-registry.md`](docs/access-registry.md) pour la gouvernance des accès.

---

_Note : `index.html` est une démo Snake héritée de l'historique du dépôt, sans
rapport avec African College. Conservée pour l'instant, à retirer sur demande._
