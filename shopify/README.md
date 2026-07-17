# Configuration Shopify (app back-office pour n8n)

Méthode **2026** : app créée dans le **Dev Dashboard**, authentification
`client_credentials` (server-to-server). Les custom apps de l'admin Shopify
(token `shpat_` statique) ne sont plus créables pour les nouvelles apps.

## Fichiers

- `shopify.app.reference.toml` — configuration correcte de référence (zéro
  valeur de démo). À recopier dans le `shopify.app.toml` de ton projet CLI,
  en conservant ta ligne `client_id`, puis `shopify app deploy`.

## Pourquoi `app_url = https://example.com` n'était pas le blocage

`application_url` et `redirect_urls` ne servent qu'au flux OAuth navigateur
(authorization code). La méthode `client_credentials` **ne les utilise pas**.
On les met quand même à une vraie URL (`https://africancollege.store`) pour
supprimer toute valeur de démo.

## Le vrai pré-requis (doc Shopify)

`client_credentials` n'est disponible que si **l'app et la boutique sont dans
la même organisation** du Dev Dashboard, et si **l'app est installée** sur la
boutique. Sinon : erreur `shop_not_permitted`.

## Ce que n8n utilise

- Variables : `SHOPIFY_STORE_DOMAIN`, `SHOPIFY_CLIENT_ID`,
  `SHOPIFY_CLIENT_SECRET`, `SHOPIFY_API_VERSION`.
- Aucun credential Shopify dans n8n : le token est obtenu à chaque exécution
  par le nœud « Obtenir token Shopify » (POST `/admin/oauth/access_token`).
