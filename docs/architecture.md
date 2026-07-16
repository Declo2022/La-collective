# Blueprint d'architecture — African College

> Document de référence. Version markdown du blueprint validé.
> Une version visuelle (diagrammes) est publiée comme artifact séparé.

## 1. Thèse

Marque e-commerce **produits physiques** opérée par une équipe d'agents IA,
en boucle fermée **mesurer → décider → agir → réapprendre**. L'humain valide
les actions à fort impact ; l'autonomie se gagne progressivement.

## 2. Architecture en 7 couches

1. **Vitrine** — Shopify (Online Store 2.0, Admin GraphQL API). Source de vérité commerciale.
2. **Cerveau** — Orchestrateur + agents spécialisés (Contenu, Merchandising, SEO, Support, Analytics), raisonnement OpenAI.
3. **Système nerveux** — n8n (n8n Cloud) : workflows, bus d'événements, webhooks, cron.
4. **Mémoire & données** — Supabase : Postgres (entrepôt), pgvector (mémoire agents), Storage, Edge Functions, Auth.
5. **Mesure** — GA4 (audience/conversion), Search Console (SEO), Clarity (UX). Agrégés dans Supabase.
6. **Poste de commande humain** — Bot Telegram : alertes, résumés, approbations (HITL).
7. **Plateforme dev** — GitHub : versionnement, CI/CD (Actions), secrets.

## 3. Décisions verrouillées (Phase 0)

| Sujet           | Choix                                                     |
| --------------- | --------------------------------------------------------- |
| Modèle          | Produits physiques (stock, variantes, localisations)      |
| Runtime agents  | Dans n8n d'abord ; extraction service Node/TS plus tard   |
| Hébergement n8n | n8n Cloud d'abord ; VPS auto-hébergé possible ensuite     |
| Autonomie       | Brouillon + validation Telegram sur toute action à impact |

## 4. Intégrations (résumé)

n8n est le point de passage central. Flux type : événement Shopify → n8n →
(décision agent) → proposition → approbation Telegram → action Admin API →
journalisation Supabase.

| Liaison                          | Sens | Déclencheur                | Objet                              |
| -------------------------------- | ---- | -------------------------- | ---------------------------------- |
| Shopify ↔ n8n                    | ⇄    | webhooks + Admin API       | événements / écritures catalogue   |
| Shopify → Supabase               | →    | via n8n + resync           | miroir catalogue, commandes        |
| n8n ↔ OpenAI/Agents              | ⇄    | étape nécessitant décision | prompt+contexte → action           |
| Agents ↔ Supabase                | ⇄    | chaque raisonnement        | mémoire, embeddings pgvector       |
| GA4/GSC/Clarity → n8n → Supabase | →    | pull planifié              | KPIs, positions, signaux UX        |
| Telegram ↔ n8n                   | ⇄    | bot                        | alertes / décisions                |
| GitHub → n8n & Supabase          | →    | push/merge (Actions)       | déploiement workflows & migrations |

## 5. Risques majeurs & garde-fous

- **Agent agit à tort sur la prod** → brouillon par défaut + approbation + staging.
- **Coûts OpenAI** → plafonds tokens/jour, budget par agent, cache d'embeddings.
- **Hallucination / hors marque** → prompts contraints + charte en mémoire + revue humaine.
- **n8n = SPOF** → backups, healthchecks, workflows versionnés dans Git.
- **Rate limits / dépréciation API** → backoff, files d'attente, versions épinglées.
- **Fuite de secrets** → gestionnaire de secrets, rotation, scopes minimaux.

## 6. Ordre de développement

Fondations → Données+instrumentation → Backbone n8n → Agents faible risque →
Garde-fou humain → Agents métier → Boucle autonome. _Données avant cerveau ;
garde-fou humain avant élargissement de l'autonomie._
