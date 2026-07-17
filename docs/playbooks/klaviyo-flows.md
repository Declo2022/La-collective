# Playbook Klaviyo — 3 flows complets

Prêts à recopier dans Klaviyo. Ton : marque culturelle, artistes, sobre et
chaleureux. Objets courts, sans spam. Adapter `{{ marque }}`, liens, codes promo.

**Prérequis** : Klaviyo connecté à Shopify ; pop-up d'inscription actif ;
consentement SMS configuré si SMS.

**KPI transverses** : % du CA attribué à Klaviyo (cible > 20% à 60 j), CA par
flow, taux d'ouverture (> 40% sur flows), taux de clic, croissance de liste.

---

## Flow 1 — Bienvenue (Welcome series)

**Déclencheur** : inscription à la liste (pop-up / formulaire).
**Segment** : nouveaux abonnés non clients.
**Objectif** : convertir l'inscription en 1re commande (souvent 3–5% du CA email).

| #   | Timing   | Objet                                     | Contenu                                                                                                  |
| --- | -------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| 1   | immédiat | « Bienvenue dans le collectif 🌍 »        | Merci + histoire courte de la marque + le code de bienvenue (ex. `-10%`). CTA : découvrir la collection. |
| 2   | +2 jours | « Les artistes derrière African College » | Récit d'un·e artiste + produits liés. Preuve sociale (avis). CTA : voir les pièces.                      |
| 3   | +4 jours | « Votre -10% expire bientôt »             | Rappel du code + best-sellers + réassurance (livraison, retours). CTA : commander.                       |

**Condition de sortie** : achat effectué (bascule vers le flow post-achat).
**Automatisation** : arrêter la série si commande passée.

---

## Flow 2 — Panier abandonné (Abandoned checkout)

**Déclencheur** : `Checkout Started` sans commande.
**Segment** : a commencé un paiement, pas de commande dans les 4 h.
**Objectif** : récupérer 5–11% des paniers perdus (le flow le plus rentable).

| #   | Timing | Objet                                   | Contenu                                                                                                            |
| --- | ------ | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1   | +1 h   | « Vous avez oublié quelque chose ✨ »   | Rappel des articles du panier (bloc dynamique) + CTA « Reprendre ma commande ». Pas de promo (préserver la marge). |
| 2   | +24 h  | « Toujours intéressé·e ? »              | Réassurance (livraison, retours, paiement sécurisé) + avis clients + CTA panier.                                   |
| 3   | +48 h  | « Dernière chance sur votre sélection » | Léger incitatif si nécessaire (ex. livraison offerte) + urgence douce (stock limité). CTA panier.                  |

**Condition de sortie** : commande passée.
**Bonnes pratiques** : bloc « articles du panier » dynamique ; ne pas offrir de
remise dès l'e-mail 1 (on entraîne sinon les clients à attendre la promo).
**Variante SMS** : un SMS à +2 h (fort taux d'ouverture) si consentement.

---

## Flow 3 — Post-achat (fidélisation + avis)

**Déclencheur** : `Placed Order`.
**Segment** : clients ayant commandé.
**Objectif** : rétention (réachat) + collecte d'avis + montée de gamme.

| #   | Timing                        | Objet                                       | Contenu                                                                                           |
| --- | ----------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 1   | immédiat                      | « Merci — votre commande est confirmée 🙏 » | Confirmation + ce qui va se passer (préparation, expédition) + histoire de la marque.             |
| 2   | +3 jours après livraison      | « Comment trouvez-vous votre pièce ? »      | Demande d'avis (lien Judge.me/Loox) + incitation photo. Alimente la preuve sociale.               |
| 3   | +14 jours                     | « Complétez votre look »                    | Cross-sell personnalisé (produits complémentaires) + contenu de marque (interview). CTA boutique. |
| 4   | +45 jours (si pas de réachat) | « On vous a préparé quelque chose »         | Réactivation douce + nouveautés + éventuel avantage fidélité.                                     |

**Condition** : e-mail 2 déclenché sur l'événement de livraison (fulfilled).
**Lien avec les avis** : synchroniser la demande d'avis avec l'outil d'avis pour
éviter le doublon.

---

## Segments à créer dans Klaviyo

- **Nouveaux abonnés non clients** (welcome).
- **Clients actifs** (au moins 1 commande, &lt; 90 j).
- **Clients inactifs** (dernière commande &gt; 90 j) → winback (à ajouter ensuite).
- **VIP** (≥ 3 commandes ou panier élevé) → attentions particulières.

## À ajouter après validation des 3 flows

- **Navigation abandonnée** (`Viewed Product` sans achat).
- **Winback** (inactifs 60–90 j).
- **Réassort / retour en stock** (si ruptures fréquentes).

## Checklist de mise en production

- [ ] Klaviyo connecté à Shopify.
- [ ] Pop-up d'inscription en ligne (contre e-mail).
- [ ] Flow Bienvenue actif + code promo créé côté Shopify.
- [ ] Flow Panier abandonné actif (blocs dynamiques testés).
- [ ] Flow Post-achat actif + lien avis fonctionnel.
- [ ] Consentement SMS configuré (si SMS).
- [ ] Suivi du CA attribué activé (baseline notée).
