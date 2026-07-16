# Organisation — African College

L'entreprise est opérée par **8 agents IA** sous le contrôle de **2 rôles
humains**. Règle absolue : les agents proposent, les humains disposent —
aucune écriture Shopify, dépense réelle ou publication externe sans approbation.

## Rôles humains

| Rôle                         | Mission                     | Valide                                            |
| ---------------------------- | --------------------------- | ------------------------------------------------- |
| **Claude Rivel** (fondateur) | Vision & dernier mot        | Écritures Shopify, dépenses, publications, budget |
| **Administrateur système**   | Infra, sécurité, continuité | Déploiements critiques, secrets, kill-switch      |

## Les 8 agents

| Agent                  | Équipe | Budget tokens/j | Fréquence                |
| ---------------------- | ------ | --------------- | ------------------------ |
| CEO                    | EXE    | 80k             | quotidien + événementiel |
| CTO                    | EXE    | 60k             | continu (monitoring)     |
| Directeur Artistique   | DSG    | 40k (+30 img/j) | événementiel             |
| Responsable E-commerce | ECM    | 70k             | quotidien + événementiel |
| Growth & Marketing     | GRW    | 60k             | quotidien + hebdo        |
| SEO & Content          | CNT    | 100k            | quotidien + événementiel |
| Community Manager      | COM    | 40k             | quotidien + événementiel |
| Service Client         | SUP    | 50k             | événementiel + récap     |

**Total ≈ 500k tokens/j** (plafond serré de démarrage, `OPENAI_DAILY_TOKEN_CAP`).
La fonction « Data Analyst » est redistribuée : KPI globaux → CEO, acquisition →
Growth, ventes → E-commerce.

Détail complet (13 attributs par agent, prompts système, organigramme) : voir
l'artifact « Organisation IA » et le seed `supabase/migrations/…160000_seed_organization.sql`.

## Chaînes d'approbation

| Chaîne             | Étapes                 | Types d'action                                                   |
| ------------------ | ---------------------- | ---------------------------------------------------------------- |
| `shopify_write`    | CEO → CTO → **humain** | product_update, collection_update, price_change, content_publish |
| `external_publish` | CEO → **humain**       | social_post, promo_discount, campaign_spend, support_refund      |

Règles de démarrage :

- **Agents `enabled=false`** : définis mais inactifs jusqu'à la Phase 2 (workflows).
- **Service Client** : aucun geste commercial automatique — tout validé.
- **Posts sociaux** : validés par Claude Rivel (comme les écritures Shopify).
- Toute décision d'approbation est écrite dans `approval_decisions` (immuable).
