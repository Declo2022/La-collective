# Phase 0 — Inventaire des credentials n8n (à confronter à la réalité)

> Checklist à dérouler **dans n8n Cloud → Credentials** par le fondateur ou
> l'administrateur. Objectif : confronter `docs/access-registry.md` (théorie)
> aux credentials réellement configurés (pratique). **Aucune valeur secrète ne
> doit être recopiée ici** — on ne note que : existe / n'existe pas, nom, scope,
> et la date de vérification.

Date de vérification : ______ · Vérifié par : ______

## 1. Inventaire (cocher ce qui existe réellement dans n8n Cloud)

| # | Credential attendu | Existe ? | Nom exact dans n8n | Conforme au registre ? |
| - | ------------------ | -------- | ------------------ | ---------------------- |
| 1 | Shopify (token Admin API ou app Dev Dashboard client_credentials) | ☐ | | ☐ |
| 2 | OpenAI (clé API — idéalement projet dédié avec plafond de dépense) | ☐ | | ☐ |
| 3 | Telegram (token du bot @BotFather) | ☐ | | ☐ |
| 4 | Printful (token API privé, Bearer) | ☐ | | ☐ |
| 5 | Supabase / Postgres (si déjà provisionné) | ☐ | | ☐ |
| 6 | Autres credentials présents non listés ci-dessus → les inventorier | ☐ | | ☐ |

## 2. Vérifications de moindre privilège

- ☐ **Shopify** : lister les scopes de l'app. Attendu : lecture
  (`read_products`, `read_orders`, `read_customers`, `read_inventory`) +
  `write_content` uniquement (blog/pages). **Aucun** `write_products`,
  `write_orders` tant que la chaîne de validation Telegram (#9) n'est pas en
  service. Si des scopes d'écriture larges existent → les réduire (action à
  valider).
- ☐ **OpenAI** : la clé appartient à un projet dédié « African College » avec
  une **limite de dépense mensuelle** configurée sur la plateforme OpenAI.
  Noter la limite : ______ $/mois.
- ☐ **Telegram** : le bot n'est administrateur d'aucun groupe public ; le chat
  d'approbation est un groupe privé dont on connaît les membres.
- ☐ **Printful** : le token est bien un token de la boutique liée à
  africancollege.store (et pas un token personnel multi-boutiques).
- ☐ **Doublons** : aucun credential en double (deux clés OpenAI, deux tokens
  Shopify…) — sinon, supprimer le doublon après vérification d'usage (action à
  valider).

## 3. Hygiène

- ☐ Chaque credential porte un nom explicite (`shopify-prod-read`,
  `openai-agents`, `telegram-bot-approbations`…), pas « My credentials 2 ».
- ☐ Les workflows référencent le bon credential (pas un credential de test).
- ☐ Noter la date de création/rotation de chaque clé ; toute clé > 90 jours
  passe en file de rotation (`docs/access-registry.md`).
- ☐ Personne d'autre que le fondateur + l'administrateur n'a accès au workspace
  n8n Cloud.

## 4. Résultat

À l'issue : reporter les écarts constatés dans `docs/runbook.md` et mettre à
jour `docs/access-registry.md` si le réel diffère de la théorie. Les actions
correctives (réduction de scopes, suppression de doublons, rotation) sont
**soumises à validation** avant exécution.
