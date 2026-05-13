# ROADMAP_V2.md — DuoSpend

> **Roadmap V2** : intègre la stratégie produit issue de 8 documents de discovery (concept, recherche concurrentielle, PRD, personas, verdict go/no-go, backlog, devplan, roadmap v1→v2).
>
> Remplace et complète `docs/ROADMAP_RELEASE.md` (V1). La V1 couvrait uniquement « jusqu'à la mise en ligne ». La V2 couvre aussi **le post-launch**, l'**acquisition**, la **rétention** et les **signaux de kill/pivot**.

---

## Note de contexte importante

Les 8 documents de discovery datés du 15 avril 2026 sont rédigés **comme si l'app était déjà publiée**. En réalité, selon l'état projet actuel, **l'app n'est pas encore sur l'App Store** (Phase 7 en cours : préparation soumission).

→ Cette roadmap V2 **recadre** : les phases « v1.1/v1.2/v1.3 » des documents deviennent des phases **post-launch** qui arrivent après la soumission initiale (Sprints 1 à 7 du plan V1, conservés intégralement).

---

## 1. Synthèse stratégique (issue du verdict go/no-go)

**Score verdict : 25/45 — Recommandation « PIVOTER » prudent.**

### Points forts (à capitaliser)
- **Timing favorable** : Honeydue en déclin documenté (bugs 2025-2026, support défaillant). Fenêtre de 12–24 mois.
- **Positionnement différenciant** : « budget par projet » peu exploité par la concurrence. Splitwise = dette, Honeydue = compte commun mensuel, DuoSpend = enveloppe projet.
- **Faisabilité technique élevée** : app quasi prête, stack Apple-only, pas de backend.
- **Anti-subscription fatigue** : aligné avec ton modèle one-time 6,99 €.

### Points faibles (à mitiger)
- **Différenciation copiable** : Balance ou Splitwise peuvent ajouter les projets en un sprint.
- **Double adoption** : chaque couple = 2 installs → CAC mécaniquement doublé.
- **Rétention incertaine** : projet terminé = risque de désinstallation.
- **Go-to-market sans budget** : ASO + bouche-à-oreille, pas d'acquisition payante.

### Décision stratégique retenue
**Aller jusqu'à la soumission v1.0 (plan V1 intact), puis évaluer à 3 mois post-launch avec un kill switch clair.** Pas de pivot préemptif.

---

## 2. Personas cibles (issus de discovery + PRD)

Trois personas prioritaires pour orienter design, copy App Store, et messages marketing.

### Persona 1 — Léa, la planificatrice organisée (29 ans)
- Gère actuellement avec Google Sheets → frustration mobile.
- Projets actifs : voyage Japon, rénovation légère.
- Fréquence : 2–3 fois/semaine projet actif.
- WTP : 2,99 €/mois ou 12,99 €/an → **validable avec ton 6,99 € one-time** (meilleur deal que l'abo annuel).
- Canaux : Instagram finance perso, Reddit r/personalfinance.

### Persona 2 — Thomas & Julie, couple en projet lourd (34 ans)
- Rénovation 30 K€ en cours, usage intensif 6–12 mois puis arrêt.
- WTP élevée sur la durée du projet.
- **Risque de churn élevé** post-projet → le kill risk n°1.
- Canaux : subreddits bricolage, groupes Facebook « premier achat immobilier ».

### Persona 3 — Sophie & Marc, organisés chroniques (38 ans)
- Revenus asymétriques, contribution proportionnelle.
- Usage hebdomadaire, **enchaînent les projets** (vacances, activités enfants).
- **Persona clé pour la rétention long terme**.
- Canaux : podcasts finance perso, blogs parentalité.

### Implication design & copy
- Messages App Store doivent parler **à un projet concret** (voyage, mariage, rénovation), pas à une abstraction « budget ».
- Screenshots doivent montrer **des projets nommés** (pas « Projet 1 »).
- Onboarding doit suggérer des **templates d'exemples** pour déclencher l'usage.

---

## 3. Positionnement concurrentiel

Extrait du deep research. À afficher dans la copy App Store.

| Concurrent | Angle de bataille |
|---|---|
| **Honeydue** | « DuoSpend marche toujours. Pas besoin de lier votre banque. » |
| **Splitwise** | « Splitwise dit qui doit de l'argent. DuoSpend dit combien reste dans votre budget vacances. » |
| **Balance** | « Balance vous dit ce que vous avez dépensé ce mois. DuoSpend vous dit s'il reste de l'argent pour votre projet. » |
| **YNAB / Monarch** | « 6,99 € une fois, pas 109 €/an. Conçu pour couples, pas pour experts. » |

**Proposition de valeur à une phrase** :
> « L'app couple qui sait répondre à une seule question : combien reste-t-il dans notre budget projet — et qui a payé quoi ? »

---

## 4. Pricing : cohérence entre ton modèle et le marché

Ton modèle actuel : **6,99 € one-time, optionnel 4,99 € launch promo**.

Le verdict discovery recommandait plutôt un freemium 2,99 €/mois + 19,99 €/an. **Ton choix one-time reste défendable et potentiellement plus fort** pour ces raisons :

- Anti-subscription fatigue documentée (signal positif marché).
- Cible « achat unique » (Persona 2 : rénovation limitée dans le temps) **pénalisée** par un abo.
- Plus simple pour un indie (pas de churn d'abo à gérer, pas de support billing).
- Différenciation marketing forte vs YNAB (109 €/an).

**Recommandation V2** : conserver 6,99 € one-time pour v1.0, évaluer à 3 mois. Si conversion < 5 %, envisager **complément lifetime à 19,99 €** + **trial gratuit 14 jours** (pas un switch vers abo).

---

## 5. Nouveau plan d'exécution (sprints fusionnés V1 + post-launch)

Sprints 1 à 7 inchangés par rapport à `docs/ROADMAP_RELEASE.md` V1 (stabilisation → soumission). Ajouts V2 ci-dessous.

### Sprint 7-bis — Amorce stratégique AVANT soumission (nouveau)

**Quand** : entre Sprint 5 (archive Release) et Sprint 7 (soumission).

**Objectif** : préparer les **conditions de mesurabilité** pour pouvoir évaluer l'app 3 mois plus tard sans data aveugle.

#### Tâches

##### 7bis.1 — Analytics privacy-first
Tu n'as pas besoin d'analytics complet pour v1.0, mais tu as besoin de **savoir si les utilisateurs créent un 2ème projet** (signal rétention n°1).

**Option retenue** (à arbitrer) :
- **TelemetryDeck** (payant, ~10 $/mois, GDPR-friendly, SDK Swift Package) — nécessite un SPM dans le projet (exception à « zéro dépendance »).
- **Auto-hébergé via Umami/Plausible** côté beabot.fr + ping HTTP depuis l'app — plus de contrôle, zéro SPM, événements limités.
- **Journal local + export manuel** — rien à ajouter, mais pas de données agrégées.

Événements minimaux à tracker (anonymes, sans ID utilisateur) :
- `app_launched`
- `project_created`
- `expense_added`
- `paywall_shown`
- `purchase_completed`
- `second_project_created` ← **métrique rétention clé**

**Décision** : ajouter entrée dans `docs/DECISIONS.md` avant d'implémenter.

Commit : `feat: analytics privacy-first minimale`.

##### 7bis.2 — Questionnaire feedback prêt
Créer un Typeform (5 min, 8 questions max) que tu enverras aux premiers utilisateurs 2 semaines après l'installation.

Questions clés :
1. Quel projet as-tu créé en premier ?
2. Ton/ta partenaire utilise-t-il l'app aussi ?
3. Qu'est-ce qui t'a convaincu de la télécharger ?
4. Qu'est-ce qui te bloque ou te frustre ?
5. Quelle fonctionnalité te manque le plus ?
6. Prêt(e) à recommander à un proche ? (NPS 0–10)
7. Utilises-tu une autre app de budget en parallèle ?
8. Combien aurais-tu été prêt(e) à payer ?

Stocker l'URL dans `docs/COMMERCIAL.md` pour réutilisation.

##### 7bis.3 — Baseline ASO mesurable
Avant la soumission, **noter les keywords visés** dans `docs/app-store-assets/metadata.md` avec leur volume estimé (App Store Connect → Keywords), pour pouvoir mesurer leur évolution à 1 mois et 3 mois.

Outils gratuits : [AppFollow](https://appfollow.io/) (free tier), estimations manuelles.

---

### Sprint 8 — Lancement (amélioré vs V1)

Remplacer le Sprint 8 du plan V1 par celui-ci, plus opérationnel.

**Objectif** : capter la fenêtre Honeydue et amorcer le bouche-à-oreille.

#### 8.1 — Communication launch (jour J)
- **Tweet / X** : screenshot + proposition de valeur + mention explicite « alternative à Honeydue / Splitwise pour couples ».
- **LinkedIn** : angle « indie dev français, 6,99 € one-time, zéro abo, zéro pub ».
- **Reddit** : posts dans `r/personalfinance`, `r/iOSApps`, `r/ynab` (avec transparence « je suis le dev, voici comment ça marche »), `r/AppHookup` si tu fais une promo 4,99 €. Attention aux règles anti-promo des subs.
- **Forums FR** : Korben, Journal du Geek (pitch à froid), Indie Hackers.
- **Produit Hunt** : optionnel, à tenter seulement si tu peux assembler 20–30 upvotes amis pour le matin du lancement.

#### 8.2 — Ciblage « ex-Honeydue »
**Angle unique à exploiter** : beaucoup d'utilisateurs Honeydue churnés cherchent une alternative fiable.

- Sur Reddit, chercher les threads récents mentionnant « Honeydue bugs / alternative / replacement » et y **répondre utilement** (pas spammer).
- Créer un article de comparaison sur `beabot.fr/apps/duo-send/vs-honeydue/`.
- Optimiser la description App Store pour que la phrase « alternative Honeydue » y apparaisse naturellement.

#### 8.3 — Demande d'avis in-app
Déclencheur : **après la création de la 2e dépense d'un projet** (pas à l'ouverture, pas au paywall).

API : `SKStoreReviewRequest.requestReview(in:)` via iOS 18+.

Commit : `feat: demande d'avis contextuelle`.

#### 8.4 — Monitoring quotidien (2 semaines après launch)
Dashboard manuel dans une note :

| Jour | DL | IAP | Avis | Crashes | Source top |
|---|---|---|---|---|---|
| J+0 | | | | | |
| J+1 | | | | | |
| ... | | | | | |

---

### Sprint 9 — Itération feedback-driven (semaines 3–6 post-launch)

**Objectif** : traiter le feedback des premiers utilisateurs, corriger les vrais blockers et non pas les perceptions.

#### 9.1 — Analyse feedback
Centraliser dans `docs/_scratch/feedback_v1.md` :
- Avis App Store (notes + commentaires).
- Réponses Typeform.
- Messages support reçus sur beabot.fr.
- Crashes rapportés par Xcode Organizer.

Pour chaque retour, décider :
- `v1.0.1 fix` → correctif rapide.
- `v1.1 feature` → planifier dans Sprint 11.
- `backlog` → `docs/TODO.md`.
- `wontfix` → justifier dans `docs/DECISIONS.md`.

#### 9.2 — Bugs fix v1.0.1
Uploader une build 1.0.1 qui corrige les bugs bloquants. Pas de nouvelle feature.

---

### Sprint 10 — ASO itératif (semaines 4–8 post-launch)

**Objectif** : améliorer le classement des keywords sans toucher au produit.

#### 10.1 — A/B test des screenshots (option Apple)
App Store Connect permet depuis 2024 des **Product Page Optimization** (jusqu'à 3 variantes de screenshots testables).

Hypothèse à tester en priorité :
- **V1** : screenshot 1 = liste de projets peuplée.
- **V2** : screenshot 1 = balance claire « Tom doit 142 € à Léa ».
- **V3** : screenshot 1 = comparaison visuelle « avant tableur / après DuoSpend ».

#### 10.2 — Itération keywords
Selon les volumes observés, ajuster le champ `keywords`. Tester :
- Remplacer un mot peu performant par un synonyme.
- Ajouter une variante longue tail (ex. `budget vacances couple`).

#### 10.3 — Localisation supplémentaire (décision)
Si FR + EN déjà couverts, envisager **ES** (marché espagnol + LatAm) ou **DE** (marché allemand haut revenus, appétence pour les apps payantes).

Coût : 2–3h de traduction + 2h pour les screenshots localisés.

---

### Sprint 11 — Rétention (semaines 6–12 post-launch)

**Objectif central** : traiter le **kill risk n°1 = one-shot use**. Transformer un utilisateur « un projet » en utilisateur « plusieurs projets ».

Tiré directement du backlog Epic 5.

#### 11.1 — Notification « budget à 80 % »
Déclencheur : le projet atteint 80 % de son budget.

Permission requise : `UNUserNotificationCenter.requestAuthorization`.

Demande non-bloquante au **2ᵉ ajout de dépense du premier projet** (pas au premier lancement).

Commit : `feat: notification budget à 80%`.

#### 11.2 — Archivage projet terminé
Quand un projet est marqué « terminé » (action utilisateur explicite ou budget atteint à 100 %) :

- Le projet passe dans un onglet « Archivés ».
- Impossible d'y ajouter des dépenses.
- Toujours consultable en lecture.
- CTA clair : **« Créer un nouveau projet »** avec suggestions de templates.

Commit : `feat: archivage de projet terminé`.

#### 11.3 — Templates de projets (v1.1)
Déclaré « nice to have » dans le backlog discovery mais **transformé en levier de rétention**.

Templates à implémenter :
- **Voyage** (catégories : transport, hébergement, activités, restaurants)
- **Mariage** (traiteur, lieu, tenue, faire-part)
- **Rénovation** (matériaux, artisans, déco)
- **Bébé** (matériel, chambre, achats premiers mois)
- **Emménagement** (caution, meubles, électroménager)

Chaque template = nom par défaut + emoji + budget suggéré + (optionnel) liste de catégories pré-remplies.

Commit : `feat: templates de projets v1.1`.

#### 11.4 — Widget iOS (si Pro activé)
Déjà prévu. Rappel : **gated derrière l'achat** (conforme à ta mémoire projet).

Widget small = balance du projet actif + progress bar budget.

---

### Sprint 12 — Décision « v2.0 ou kill » (mois 3 post-launch)

**Objectif** : décision explicite, basée sur données, pas sur intuition.

#### 12.1 — Tableau de bord décisionnel

À remplir au 90ᵉ jour post-launch dans `docs/DECISIONS.md` :

| Métrique | Objectif 3 mois | Observé | Statut |
|---|---|---|---|
| Téléchargements totaux | 500 | | |
| Téléchargements dernier mois | 200 | | |
| Rétention J7 | > 40 % | | |
| Rétention J30 | > 20 % | | |
| Taux de création 2ème projet | > 30 % | | |
| Conversion free → Pro | > 5 % | | |
| Revenus cumulés | 100 € | | |
| Note App Store | > 4,3 / 5 | | |

#### 12.2 — Branches décisionnelles

**Branche A — Tout vert ou majoritairement vert → v1.2 croissance**
Investir Sprint 13+ dans : ASO avancé, contenu TikTok/Reels, partenariats influenceurs finance perso, éventuelle version web readonly.

**Branche B — Mitigé (rétention < 20 % mais téléchargements OK) → v1.2 rétention**
Doubler l'investissement sur templates, notifications, archivage, engagement. Reporter la croissance.

**Branche C — Rouge (< 100 téléchargements/mois OU < 50 € de revenus OU rétention < 15 %) → pivot ou maintenance**

Options de pivot documentées dans le verdict :
- **Pivot A — Budget projet solo** : supprimer la contrainte couple, viser les voyageurs solos et groupes d'amis. Plus grand TAM, pas de double adoption.
- **Pivot B — Budget mariage** : niche WTP très forte, durée de vie courte mais intense. Prix à 9,99 €.
- **Pivot C — Budget rénovation** : forte WTP, montants importants. Spécialisation possible dans DuoSpend.

**Branche D — Catastrophique (< 50 téléchargements total à 3 mois)**
Mettre l'app en maintenance silencieuse, réinvestir l'énergie sur une nouvelle app. Ne pas se sentir obligé de persister : l'expérience acquise vaut plus que l'échec.

---

## 6. Backlog structuré post-launch (tiré du backlog discovery)

Organisé par priorité stratégique post-launch. Chaque epic a un lien explicite avec un objectif de verdict.

### Critiques (Sprint 8 → 11)
- **Demande d'avis in-app contextuelle** (`Epic 6-6`) — levier note App Store.
- **Templates projets** (`Epic 7-4`) — levier rétention, transforme discovery nice-to-have en KPI lever.
- **Archivage + suggestion nouveau projet** (`Epic 5-2`, `5-3`) — traitement kill risk n°1.
- **Notifications budget** (`Epic 5-1`) — levier engagement.
- **Analytics privacy-first** — prérequis Sprint 12.

### Importantes (Sprint 12 → 13)
- **Widget iOS Pro** (`Epic 5-4`) — déjà gated, à peaufiner.
- **Export PDF amélioré** (`Epic 7-1`) — argument Pro + partage social = viralité.
- **Partage snapshot projet** (`Epic 7-3`) — viralité pair-à-pair.
- **iCloud sync même compte** (v1.1 de ta mémoire) — retour confiance utilisateur.

### Optionnelles (v2.0+)
- **Multi-devises** (`Epic 7-5`) — segment voyage international.
- **Scan de reçu Vision framework** (`PRD N1`) — effet « waouh » marketing.
- **Graphiques par catégorie** (`PRD N3`) — pour power users.
- **CloudKit Sharing entre 2 Apple IDs** (v2.0 de ta mémoire) — vraie expérience duo.
- **Apple Watch** — explicitement reporté post v1.1 iCloud sync.

### Hors scope (décisions actées à garder)
- Synchronisation bancaire (Plaid, Open Banking) — **invariant produit**.
- Plus de 2 partenaires — **invariant produit**.
- Version web, Android — **décision budget solo**.

---

## 7. Plan de validation à lancer post-launch (issu de discovery §6)

Trois tests concrets à exécuter dans les 8 semaines qui suivent la publication.

### Test 1 — Enquête utilisateurs existants (semaines 2–4)
- Envoi Typeform préparé en Sprint 7bis.2.
- Cible : tous les utilisateurs actifs qui ont créé au moins un projet.
- Canal : notification push douce + email si récupéré.
- **Critère de succès** : ≥ 20 réponses, ≥ 60 % mentionnent un projet spécifique (pas « budget mensuel »).

### Test 2 — A/B screenshots via Product Page Optimization (semaines 4–8)
Outil Apple natif, gratuit.

Hypothèse : le screenshot qui met en avant la balance « qui doit combien à qui » convertit mieux que celui montrant la liste de projets.

**Critère de succès** : variante gagnante avec > 10 % de conversion supérieure au control.

### Test 3 — Interview 5 non-utilisateurs (semaines 6–10)
- Recruter via Reddit avec compensation symbolique (10 € cadeau).
- Objectif : comprendre pourquoi l'app n'a pas été installée ou a été désinstallée.
- **Critère de succès** : identifier 2–3 frictions communes actionnables.

---

## 8. KPIs de pilotage (baseline + objectifs)

À reporter chaque semaine dans un doc dédié `docs/METRICS.md` (à créer au lancement).

### Acquisition
| KPI | Baseline | J+30 | J+60 | J+90 |
|---|---|---|---|---|
| Impressions App Store | — | 500 | 2 000 | 5 000 |
| Téléchargements | — | 50 | 150 | 500 |
| Taux de conversion page produit | — | 3 % | 5 % | 7 % |

### Activation
| KPI | Baseline | Objectif |
|---|---|---|
| % users qui complètent l'onboarding | — | > 90 % |
| % users qui créent un projet | — | > 80 % |
| % users qui ajoutent une dépense | — | > 70 % |

### Rétention
| KPI | Baseline | Objectif 3 mois |
|---|---|---|
| Rétention J7 | — | > 40 % |
| Rétention J30 | — | > 20 % |
| Users qui créent un 2ème projet | — | > 30 % |

### Monétisation
| KPI | Baseline | Objectif 3 mois |
|---|---|---|
| Paywall views | — | 100 / mois |
| Taux de conversion paywall | — | > 5 % |
| Revenus cumulés | 0 € | 100 € |

### Qualité
| KPI | Baseline | Objectif |
|---|---|---|
| Note App Store | — | > 4,3 / 5 |
| Nombre d'avis | 0 | > 10 |
| Crashes / 1000 sessions | — | < 5 |

---

## 9. Signaux d'alerte — kill switch

Ces seuils déclenchent une revue stratégique immédiate, pas une attente jusqu'au check 3 mois.

- **Taux de crash > 1 %** → hot fix prioritaire sur tout autre travail.
- **Un avis moyen < 3,5 / 5 sur ≥ 10 avis** → revoir le produit en urgence.
- **Taux de conversion paywall < 2 % après 30 jours** → le paywall ou le pricing est cassé.
- **Aucun téléchargement pendant 7 jours consécutifs post-launch** → problème d'indexation ou catégorie App Store.
- **100 % des utilisateurs abandonnent après 1er projet** → proposition de valeur cassée, one-shot confirmé.

---

## 10. Principes de décision

Pour rester aligné malgré la fatigue ou les déceptions éventuelles :

- **Pas de nouvelle feature avant les données.** Les sprints 1 à 10 sont soit prévus, soit réactifs à un feedback mesuré.
- **Un commit = une décision réversible.** Si ça ne marche pas, on revert.
- **La rétention prime sur l'acquisition tant que la rétention est < 20 % à J30.** Pas la peine d'amener des gens dans un seau troué.
- **Le temps de dev est le coût le plus cher.** Chaque heure passée sur une feature doit avoir un levier explicite (acquisition, rétention, monétisation, qualité).
- **Le plan est vivant.** Ce fichier est relu et mis à jour à chaque fin de sprint.

---

## Récap des sprints

| Sprint | Phase | Objectif | Statut |
|---|---|---|---|
| 1 — Stabilisation | Pré-launch | Zéro bug, zéro warning | Plan V1 |
| 2 — Polish UI | Pré-launch | Design propre partout | Plan V1 |
| 3 — Amélioration graphique | Pré-launch (optionnel) | Identité renforcée | Plan V1 |
| 4 — Prépa soumission non-code | Pré-launch | Légal + marketing | Plan V1 |
| 5 — Config Xcode Release | Pré-launch | Archive propre | Plan V1 |
| 6 — TestFlight | Pré-launch | Beta testé | Plan V1 |
| **7bis — Amorce stratégique** | **Pré-launch** | **Mesurable** | **V2 nouveau** |
| 7 — Soumission | Pré-launch | Review Apple | Plan V1 |
| **8 — Launch + communication** | **Launch** | **Fenêtre Honeydue captée** | **V2 amélioré** |
| **9 — Itération feedback** | **Post-launch** | **v1.0.1 bugs** | **V2 nouveau** |
| **10 — ASO itératif** | **Post-launch** | **A/B screenshots** | **V2 nouveau** |
| **11 — Rétention** | **Post-launch** | **Templates + notifs** | **V2 nouveau** |
| **12 — Décision kill / v2** | **M+3 post-launch** | **Go / pivot / kill** | **V2 nouveau** |

---

*Document vivant. Mis à jour après chaque fin de sprint.*
*Dernière révision : avril 2026.*
