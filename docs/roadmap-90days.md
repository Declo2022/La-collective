# Plan 90 jours — African College

Séquence : **BUY d'abord** (machine rentable), **BUILD ensuite** (moteur de
contenu), une fois le ROI des fondations mesuré. Chaque étape = CA ou temps.

## Mois 1 — Fondations de revenu (BUY) + mise en prod technique

**Semaine 1**

- Noter la **baseline** (`roi-tracker.md`).
- Provisionner Supabase, Shopify (read-only), OpenAI, Telegram, n8n Cloud.
- Appliquer les migrations ; importer & tester #10, #9, #1, #2, #3 en réel.
- **Klaviyo** : flows Bienvenue + Panier abandonné. GSC + GA4 + Clarity.

**Semaine 2**

- **Avis** (Judge.me/Loox) + demande d'avis automatique.
- **Upsell** natif Shopify (PDP + panier). Klaviyo : flow Post-achat.
- Charger les **COGS** (marge réelle sur #2).

**Semaine 3**

- **Gorgias** : canaux (Gmail/Instagram/Shopify) + macros + self-service.
- Klaviyo : navigation abandonnée + winback.
- Activer le **digest quotidien Telegram** (#1/#2/#3).

**Semaine 4**

- **Mesurer** les premiers résultats (ROI tracker).
- Ajuster flows/upsell/macros. Ubersuggest si besoin SEO.
- **Jalon M1** : fondations en production, premières ventes additionnelles mesurées.

## Mois 2 — Optimiser + préparer le moat

- **Optimisation** : itérer sur ce qui marche (doubler), couper ce qui ne prouve rien.
- **Fidélité** (Smile) si la rétention le justifie ; premiers **tests A/B** si trafic suffisant.
- **Alimenter la base de connaissances** : bios artistes, interviews, histoire (via ingestion RAG).
- **Jalon M2** : ROI positif et mesuré sur Klaviyo + upsell + avis → feu vert BUILD.

## Mois 3 — Lancer le moteur de contenu (BUILD)

- Déployer `rag-ingest-document-task` + `content-draft-task` (moteur de contenu).
- Produire les premières **fiches narratives + articles + interviews** (sourcés, validés).
- Établir une **cadence de publication** (SEO cumulatif).
- Suivre les **sessions & CA organiques** (GSC/GA4).
- **Jalon M3** : machine e-commerce rentable + moteur de contenu de marque en marche.

## Au-delà de 90 jours

- International : **Shopify Markets** (multi-devises/langues) → « marque mondiale ».
- Attribution avancée (Polar/Triple Whale) quand le budget pub grandit.
- Automatiser davantage d'ops via n8n (sur la couche possédée).
- Shopify Plus seulement si le volume/checkout le justifie.

## Principe directeur

On ne paie la complexité que quand le CA la rend rentable. On mesure tout. On
double ce qui marche. **Maximum d'impact commercial, minimum de code à maintenir.**
