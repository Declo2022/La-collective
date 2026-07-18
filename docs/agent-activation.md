# Activation progressive des agents

L'activation est **gardée** : un agent ne peut passer `enabled=true` que si les
connexions critiques sont vertes (`fn_activation_ready()` = aucun service en
erreur + `shopify`, `supabase`, `telegram`, `openai` au vert dans
`v_connection_health`). Sinon l'appel lève une exception.

## Pré-requis

1. `monitor-connections-healthcheck` a tourné au moins une fois et
   `select * from v_connection_health;` montre tout au vert.
2. `select fn_activation_ready();` renvoie `true`.

## Activation par vagues (dans l'ordre)

```sql
-- Vague 1 — pilotage (lecture seule, zéro risque)
select * from fn_activate_wave(1);   -- CEO IA, Analytics Manager, Automation Manager

-- Vague 2 — e-commerce (lecture + propositions)
select * from fn_activate_wave(2);   -- Shopify Manager, Product Manager, Printful Manager

-- Vague 3 — contenu / SEO (propositions)
select * from fn_activate_wave(3);   -- SEO Manager, Content Writer, Design Manager

-- Vague 4 — externe / communauté / support
select * from fn_activate_wave(4);   -- Marketing Manager, Social Media Manager, Customer Support
```

> **Content Manager = Content Writer** (même agent, rôle « Rédaction de marque »).

Activer une vague, observer 24–48 h (tâches, coûts, qualité des propositions),
puis passer à la suivante. Un agent seul : `select fn_enable_agent('CEO IA');`.

## Règle non négociable

Aucun agent n'écrit sur Shopify. Toute action sensible (produits, collections,
prix, publications, dépenses, commandes Printful) passe par l'approbation
humaine (`fn_open_approval` → Telegram → `fn_can_execute`). Voir
`supabase/migrations/…180000_wf9_approval_engine.sql` et les politiques
(`…160000_seed_organization.sql`, `…120100_seed_agents_v2.sql`).

## Désactivation d'urgence

```sql
update agents set enabled = false where enabled = true;  -- coupe tous les agents
```
