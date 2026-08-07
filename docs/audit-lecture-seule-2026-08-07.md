# Audit lecture seule — 7 août 2026

> Audit CTO complet, **sans aucune modification** des systèmes (Shopify, n8n,
> Printful, Supabase, Telegram, credentials). Périmètre réellement accessible
> depuis cette session : dépôt Git + Shopify Admin (lecture). Les autres
> services sont audités via le code et la documentation versionnés.

## 1. Périmètre et accès

| Système               | Accès depuis cette session | Méthode d'audit                          |
| --------------------- | -------------------------- | ---------------------------------------- |
| Git (La-collective)   | ✅ complet                 | lecture des 3 branches distantes         |
| Shopify (africancollege.store) | ✅ lecture (MCP)  | produits, collections, commandes, ventes |
| n8n Cloud             | ❌ aucun                   | via les 17 JSON versionnés uniquement    |
| Telegram              | ❌ aucun                   | via la documentation                     |
| OpenAI                | ❌ aucun                   | via la configuration versionnée          |
| Printful              | ❌ direct aucun            | indirect : SKUs/stocks Shopify           |
| Supabase              | ❌ aucun                   | via les 36 migrations versionnées        |

**Conséquence majeure** : les deux workflows décrits comme actifs en production
(« Telegram + OpenAI Bot », « African College – Équipe IA Complète ») ne sont
**ni versionnés dans Git, ni accessibles depuis cette session**. Ils n'ont pas pu
être audités (exécutions, erreurs, lenteurs). C'est le premier écart à combler.

## 2. État général

Deux réalités parallèles :

1. **Un socle Git de très bonne qualité, non déployé** (branche
   `claude/african-college-architecture-0ovqxv`) : 36 migrations Supabase
   (68 tables, RLS, audit immuable), 17 workflows n8n JSON, CI (format, validation
   migrations sur pgvector, scan Gitleaks), documentation complète (handoff,
   architecture, ADR, SOP, déploiement). Aucun secret committé (vérifié par scan).
2. **Une production réelle minimale et non versionnée** : boutique Shopify en
   ligne avec catalogue Printful propre, et des workflows n8n construits à la main
   dans n8n Cloud, sans trace dans Git.

Le dépôt a par ailleurs un problème d'hygiène : **la branche par défaut est vide**
(aucun commit), tout le travail vit sur 3 branches `claude/*` jamais fusionnées,
et un `index.html` (démo Snake) sans rapport avec le projet traîne à la racine.

## 3. Shopify — constat en direct (lecture)

- **Boutique** : AFRICAN COLLEGE, `africancollege.store`
  (`q1tha3-jx.myshopify.com`), plan Shopify, EUR, France.
- **Produits** : 16 au total — 15 ACTIVE + 1 ARCHIVED. Gamme cohérente :
  T-shirts (35 €), débardeur (35 €), hoodies (70 €), casquette (40 €),
  tote bags (40–45 €). Tags propres (`lecon-001`, `lecon-002`, `essentiels`…).
- **Printful** : tous les produits actifs portent des SKU au format Printful
  (`XXXXXXX_YYYYY`) et des stocks « 9999 » gérés par la synchro → la synchro
  produits Shopify ↔ Printful est **en place et cohérente**. Aucun produit
  actif orphelin.
- **Anomalie mineure** : le produit archivé « T-shirt manches courtes »
  (`t-shirt-courte`) a des variantes **sans SKU** (création manuelle hors
  Printful). Archivé = sans impact, mais à supprimer ou reconnecter un jour.
- **Collections** : 6 (1 smart « Catalogue » = tout le catalogue, 5 manuelles).
  Structure éditoriale claire (Leçon 001, Leçon 002, Essentiels, Nouveautés).
- **Ventes** : **1 commande sur les 90 derniers jours** (juillet 2026, 35 € HT,
  39,20 € TTC). Mai, juin, août : 0.

> Lecture CTO honnête : le premier problème du projet n'est pas technique, il est
> **commercial** (acquisition / trafic). L'infrastructure IA doit servir cela en
> priorité, pas l'inverse.

## 4. Ce qui fonctionne

- Boutique Shopify en ligne, catalogue et collections propres.
- Synchronisation produits Printful opérationnelle (constatée via SKUs/stocks).
- Socle Git : schéma de données sérieux, gouvernance (approbations Telegram,
  garde-fou coût IA, audit immuable), CI avec scan de secrets, documentation
  au-dessus de la moyenne.
- Aucun secret dans le dépôt (scan effectué pendant cet audit : négatif).

## 5. Ce qui est cassé ou manquant

1. **Écart Git ↔ production** : les workflows n8n réellement actifs ne sont pas
   versionnés ; les 17 workflows versionnés ne sont pas déployés. Deux systèmes
   parallèles qui divergent — aucun rollback possible côté prod.
2. **Aucune observabilité** : pas d'accès n8n depuis cette session, donc
   exécutions, taux d'erreur, latences Telegram et consommation OpenAI réels
   sont **invisibles**. Le monitoring conçu (#10, healthcheck) n'est pas déployé.
3. **Branche par défaut vide** + 3 branches non fusionnées = risque de perte de
   travail et confusion pour toute reprise.
4. **Aucune vente** à instrumenter : les rapports quotidiens tourneront à vide
   tant que l'acquisition n'est pas lancée (chantier BUY documenté mais non lancé).
5. Produit archivé sans SKU (mineur, voir §3).

## 6. Ce qui ralentit (probablement) le bot Telegram

Non mesurable d'ici (pas d'accès aux exécutions n8n), mais l'architecture
« Équipe IA Complète » présente des causes de lenteur classiques :

- **Orchestration multi-agents systématique** même pour une question simple :
  chaque question paie plusieurs appels OpenAI en série.
- **Outils Shopify attachés en permanence à l'agent** : l'agent est tenté
  d'appeler Shopify (ou est obligé d'y passer) même quand la réponse ne le
  nécessite pas ; chaque appel outillé ajoute un aller-retour LLM.
- **Modèle unique haut de gamme** pour tout, y compris les réponses triviales.
- **Absence de mémoire persistante** : le contexte est reconstruit (ou perdu) à
  chaque message → prompts plus longs, réponses moins précises.

Architecture cible (déjà compatible avec le socle versionné) :

```
Message Telegram
   → Routeur (1 appel, modèle mini) : simple | complexe | action
   → simple   : 1 agent, modèle mini, AUCUN outil
   → complexe : 1 agent + outils Shopify LECTURE seulement si nécessaire
   → action   : proposition + validation Telegram (fn_can_execute) avant écriture
```

Objectifs chiffrés : réponse simple < 3 s et 1 seul appel OpenAI ; réponse avec
Shopify < 8 s ; écriture = jamais sans bouton de validation.

## 7. Risques de sécurité

| Risque | Sévérité | Détail |
| --- | --- | --- |
| Workflows prod non versionnés | **élevée** | pas de revue, pas de rollback, pas d'audit des nœuds/credentials réels |
| Credentials n8n non inventoriés | **élevée** | `docs/access-registry.md` existe mais n'a pas pu être confronté à la réalité n8n |
| Écritures Shopify potentiellement non « gated » en prod | **élevée** | le garde-fou `fn_can_execute` n'existe que dans les workflows non déployés |
| Aucun plafond de coût OpenAI actif | moyenne | `monitor-cost-guardrail` non déployé → dérive de coût silencieuse possible |
| Branche par défaut vide / travail non fusionné | moyenne | perte de travail possible, confusion des reprises |
| PII dans les logs du bot | moyenne | si les conversations Telegram sont journalisées, appliquer le hachage prévu au schéma |

Aucun secret exposé dans le dépôt (vérifié). Rien de sensible n'est affiché dans
ce rapport.

## 8. Les cinq actions prioritaires

1. **Rapatrier la production dans Git** : exporter les 2 workflows n8n actifs
   (API n8n ou export manuel JSON) dans `n8n/workflows/live/` — source de vérité
   unique, credentials masqués par l'export n8n.
2. **Assainir le dépôt** : fusionner la branche architecture dans la branche par
   défaut, supprimer `index.html`, clôturer les branches obsolètes.
3. **Auditer les credentials n8n réels** contre `docs/access-registry.md`
   (scopes Shopify read-only, token Printful, clé OpenAI dédiée par usage).
4. **Refondre le bot Telegram en routeur** (1 agent par défaut, modèle mini,
   outils à la demande, écritures gated) — c'est la baisse de coût et de latence
   la plus rentable.
5. **Déployer le socle minimal d'observabilité** : migrations Supabase +
   workflows #10 (coûts/erreurs) + `monitor-connections-healthcheck` +
   rapport quotidien Telegram.

## 9. Actions nécessitant validation explicite

- Toute fusion vers la branche par défaut et suppression de branches/fichiers.
- Import/activation/désactivation de tout workflow dans n8n Cloud.
- Toute création/modification de credential.
- Provisionnement Supabase (projet + migrations).
- Toute écriture Shopify (création/modification/suppression/publication).
- Changement d'architecture du bot Telegram en production.

## 10. Plan d'exécution vers un niveau professionnel

| Phase | Contenu | Durée indicative | Prérequis |
| --- | --- | --- | --- |
| **0. Vérité unique** | export des workflows live dans Git, assainissement du dépôt, inventaire credentials | 1–2 j | clé API n8n (lecture) ou exports manuels |
| **1. Observabilité** | Supabase provisionné, migrations, #10 + healthcheck + rapport quotidien Telegram | 2–3 j | accès Supabase + n8n + bot Telegram |
| **2. Bot Telegram v2** | routeur simple/complexe/action, mini-modèle par défaut, outils lecture Shopify à la demande, mémoire persistante Supabase | 3–5 j | phase 1 |
| **3. Écritures gouvernées** | chaîne d'approbation Telegram (#9) devant toute écriture Shopify/Printful | 2 j | phase 2 |
| **4. Commerce (BUY)** | Klaviyo, avis, tracking ROI — suivant `docs/playbooks/` | continu | décision fondateur |
| **5. Moteur de contenu (BUILD)** | RAG + calendrier éditorial + publication gated | continu | phases 1–3 |

Chaque phase : proposition → validation → exécution → test réel → documentation
→ entrée au journal des modifications. Une seule modification critique à la fois.

## 11. Informations manquantes demandées

1. **Clé API n8n en lecture** (ou export JSON manuel des 2 workflows actifs) —
   indispensable pour auditer ce qui tourne vraiment.
2. Un **projet Supabase existe-t-il déjà** (dev/prod), ou faut-il le créer ?
3. Confirmation que le **token Printful** et le **bot Telegram** actuels sont
   bien ceux référencés dans `docs/access-registry.md`.
