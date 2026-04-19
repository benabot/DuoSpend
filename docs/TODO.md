# DuoSpend — TODO

Ce fichier doit répondre rapidement à deux questions :
- qu'est-ce qui bloque encore la sortie de la v1.0 ;
- qu'est-ce qui vient juste après si la v1 est validée terrain.

## 1. Historique des phases terminées

- [x] Phase 1 — Setup projet Xcode
- [x] Phase 2 — Écrans principaux
- [x] Phase 3 — Logique métier
- [x] Phase 4 — Polish UX
- [x] Phase 6 — Design & identité visuelle

Travaux déjà livrés dans la préparation v1.0 : localisation FR/EN, StoreKit 2, widgets Pro, `SettingsView`, onboarding et splash stabilisés.

Notes d'organisation :
- La Phase 7 n'est pas terminée : elle est détaillée ci-dessous comme priorité actuelle.
- L'ancienne Phase 5 n'est plus suivie comme phase autonome : ses reliquats de validation sont absorbés dans la release v1.0 ou dans la stabilisation post-launch.

## 2. Priorité actuelle — Finaliser la v1.0

Ne garder ici que les tâches encore ouvertes et réellement bloquantes avant mise en ligne.

### Assets & metadata

- [x] Finaliser les screenshots App Store FR et EN pour grand iPhone + format 5.5"
- [x] Finaliser les métadonnées App Store FR + EN

### Release compliance

- [x] Vérifier que `PrivacyInfo.xcprivacy` est complet
- [x] Passer l'app en version `1.0.0` / build `1`

### Distribution

- [ ] Créer le compte Apple Developer
- [ ] Générer l'archive Release puis exécuter `Validate` / `Upload`
- [ ] Ouvrir la bêta TestFlight

### Soumission

- [ ] Soumettre l'app sur l'App Store

## 3. Post-launch immédiat — Mesure, stabilité, rétention

À démarrer après la mise en ligne ou pendant la fenêtre de retours initiaux, sans réouvrir le scope de la v1.0.

### Mesure minimale

- [ ] Ajouter une analytics privacy-first minimale
- [ ] Créer `docs/METRICS.md`
- [ ] Suivre les événements minimum : `app_launched`, `project_created`, `expense_added`, `paywall_shown`, `purchase_completed`, `second_project_created`
- [ ] Préparer un questionnaire feedback utilisateur
- [ ] Centraliser les retours dans un document scratch post-launch

### Stabilisation post-launch

- [ ] Corriger les bugs critiques remontés par TestFlight / premiers utilisateurs
- [ ] Publier une `v1.0.1` si des bugs bloquants sont confirmés
- [ ] Revalider la persistance, les edge cases, les tests device physique et les performances sur des cas réels

### Rétention primaire

- [ ] Ajouter une demande d'avis in-app contextuelle
- [ ] Ajouter une notification `budget à 80 %`
- [ ] Ajouter l'archivage de projet terminé
- [ ] Ajouter un CTA / une suggestion `Créer un nouveau projet` après clôture ou archivage

### ASO itératif

- [ ] Lancer la première itération ASO post-launch
- [ ] Tester une première variation de screenshots App Store
- [ ] Itérer les keywords et la copy à partir des premiers signaux

## 4. Roadmap produit après validation

À prioriser seulement si la v1.0 montre des signaux réels d'adoption et de rétention.

### v1.1

- [ ] iCloud sync même compte Apple
- [ ] Templates de projets
- [ ] Recherche dans les dépenses
- [ ] Améliorer l'export / partage utile si les retours terrain le justifient
- [ ] Tester la sync offline → online et les conflits simples sur un même compte Apple

### v1.2

- [ ] Catégories de dépenses avec icônes SF Symbols
- [ ] Graphiques de répartition
- [ ] Amélioration des widgets

### v2.0

- [ ] CloudKit Sharing entre 2 comptes Apple
- [ ] UI d'invitation partenaire
- [ ] Gestion de l'acceptation du partage
- [ ] Projets perso / projets partagés
- [ ] Indicateur de sync
- [ ] Révocation du partage
- [ ] Tester avec 2 comptes Apple sur 2 devices
- [ ] Gérer les permissions et les cas offline du partage

### Plus tard / optionnel

- [ ] Sync locale MultipeerConnectivity
- [ ] App Clip ou partage de projet
- [ ] Apple Watch
- [ ] Multi-devises
- [ ] Nice-to-have non validés terrain
