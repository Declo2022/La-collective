# SOP — Procédures opérationnelles standard

Procédures reproductibles + checklists. Chacune est courte, actionnable, et
respecte les règles non négociables (`docs/handoff.md` §5).

---

## SOP 1 — Revue quotidienne (5 min)

1. Lire le digest Telegram (rapport #1) : CA, top produits, remboursements.
2. Lire les alertes #3 (anomalies) : rupture, prix nul, commande inhabituelle.
3. Traiter les approbations en attente (Telegram) : valider / modifier / refuser.
4. Si anomalie → agir (corriger stock/prix côté Shopify, manuellement).

**Checklist** : ☐ digest lu ☐ alertes traitées ☐ approbations traitées.

---

## SOP 2 — Publier un contenu (moteur BUILD)

1. Lancer `content-draft-task` avec un brief (type, sujet, entity_type).
2. Le brouillon arrive en validation (`v_content_pending` + Telegram).
3. **Relire** : ton de marque, exactitude (sources citées), SEO.
4. Valider la chaîne CEO → CTO → **humain** sur Telegram.
5. Publier (manuellement dans Shopify, ou via action dédiée après approbation).
6. Vérifier le suivi SEO (GSC/GA4) sur les jours suivants.

**Checklist** : ☐ sourcé ☐ ton OK ☐ validé humain ☐ publié ☐ suivi SEO.

---

## SOP 3 — Traiter une demande d'approbation

1. Ouvrir la demande (Telegram / `v_pending_approvals`).
2. Vérifier le résumé + le diff/contenu proposé + le coût.
3. Décider : **Valider** (avance la chaîne) / **Refuser** (clôt) / demander modif.
4. La décision est enregistrée (immuable) automatiquement.
5. Une action ne s'exécute que si `fn_can_execute(proposal)` = true.

---

## SOP 4 — Ajouter un nouveau workflow n8n

1. Nommer : `<domaine>-<action>-<déclencheur>` (ex. `seo-audit-cron`).
2. Réutiliser les briques : `lib-error-handler`, `lib-approval-gate`.
3. Journaliser via `fn_log_event` ; toute action commerciale via `fn_open_approval`.
4. Exporter le JSON dans `n8n/workflows/`, commiter (revue Git).
5. Documenter dans `docs/workflows/`. Tester (SQL en local, run en n8n Cloud).

**Checklist** : ☐ nommage ☐ error-handler ☐ approbation si commercial ☐ log coût
☐ JSON versionné ☐ doc ☐ testé.

---

## SOP 5 — Ajouter un nouvel agent

1. Insérer une ligne dans `agents` (nom, rôle, prompt, outils, budget).
2. Définir ses politiques d'approbation si actions commerciales (`approval_policies`).
3. Créer ses workflows (SOP 4). `enabled=true` seulement après test.

---

## SOP 6 — Ajouter / évaluer un SaaS (chantier BUY)

1. Vérifier qu'aucun outil existant ne couvre déjà le besoin (règle « un outil par job »).
2. Installer, brancher à Shopify, noter la baseline.
3. Mesurer le ROI à 30/60 j (`docs/playbooks/roi-tracker.md`).
4. Garder / ajuster / couper selon les seuils.

---

## SOP 7 — Réponse à incident

1. Identifier via alertes (#10 dead-letter, garde-fou coût, monitoring).
2. Consulter `docs/runbook.md` (procédures) et `event_log` (trace).
3. Corriger ; rejouer les jobs en dead-letter si applicable.
4. Journaliser l'incident dans `docs/runbook.md`.

---

## SOP 8 — Rotation d'un secret

1. Révoquer la clé chez le fournisseur.
2. Émettre une nouvelle clé, mettre à jour n8n Cloud / GitHub Secrets.
3. Vérifier que les workflows repassent au vert.
4. Journaliser (date, service) dans `docs/runbook.md`.
