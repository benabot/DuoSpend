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

Travaux déjà livrés dans la préparation v1.0 : localisation FR/EN, StoreKit 2, widgets Pro, `SettingsView`, onboarding et splash stabilisés, tests automatiques du Debug Paywall, clarification de la balance dans le détail projet, convention visuelle rose/bleu corrigée dans la création de projet, correction de la localisation EN du paywall et des widgets avec couverture de tests sur les catalogues de chaînes, retrait du raccourci `Debug Paywall` des Réglages avec procédure de récupération documentée.

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

- [x] Signing Release/TestFlight validé avec `Apple Distribution: Benoît Abot (3Q33594A3N)`
- [x] Tests simulateur validés sur `id=874C77C4-CF94-4FC1-8279-EF7D97D2A90D`
- [x] Archive Distribution validée localement
- [x] Entitlements Release vérifiés : `get-task-allow=false`, `beta-reports-active=true`, App Group `group.fr.beabot.DuoSpend`
- [ ] Exporter l'IPA / uploader le build TestFlight (`#8`) — utiliser `uploadSymbols=false` si le bug `rsync` persiste
- [ ] Tester achat/restauration StoreKit local avec `DuoSpendStore.storekit` (`#26`)
- [ ] Valider le paywall sans configuration StoreKit active (`#27`) — code durci : produit absent = achat indisponible, bouton désactivé, aucun déverrouillage sans entitlement ; smoke test manuel restant
- [ ] Configurer l'IAP `fr.beabot.DuoSpend.unlimitedprojects` dans App Store Connect (`#28`)
- [ ] Compléter Privacy URL, Support URL et App Privacy / nutrition labels dans App Store Connect (`#29`)
- [ ] Finaliser la fiche App Store Connect pour TestFlight interne (`#30`)
- [ ] Ouvrir la bêta TestFlight (`#9`)

### Soumission

- [ ] Soumettre l'app sur l'App Store (`#10`)

## 3. Frontière TestFlight / App Store / post-launch

### Validé avant TestFlight

- Signing Release manuel dans `DuoSpend.xcodeproj`, Team `3Q33594A3N`.
- Archive Distribution signée avec `Apple Distribution: Benoît Abot (3Q33594A3N)`.
- `application-identifier = 3Q33594A3N.fr.beabot.DuoSpend`.
- `get-task-allow=false`, `beta-reports-active=true`.
- App Group `group.fr.beabot.DuoSpend`.
- `PrivacyInfo.xcprivacy` présent, sans tracking ni collecte déclarée, avec `UserDefaults` déclaré.

### À faire avant TestFlight

- Uploader le build via Xcode Organizer / App Store Connect.
- Tester StoreKit local achat/restauration (`#26`).
- Valider le comportement du paywall sans StoreKit (`#27`) ; le fallback produit absent est sécurisé, il reste à faire le smoke test manuel.
- Préparer l'IAP, la fiche App Store Connect, les URLs privacy/support et les infos TestFlight (`#28`, `#29`, `#30`).

### À faire avant soumission App Store

- Attacher l'IAP `fr.beabot.DuoSpend.unlimitedprojects` à la version App Store.
- Finaliser prix, disponibilité et localisations de l'achat unique.
- Finaliser catégorie, classification d'âge, compliance chiffrement, captures et notes de review.

## 4. Post-launch immédiat — Mesure, stabilité, rétention

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

## 5. Roadmap produit après validation

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

## Vision produit — plus tard (v2+)

- [ ] Ajouter une **vue récapitulative par membre du couple**, agrégée sur l’ensemble des projets
  - afficher pour chaque membre :
    - total payé
    - total à charge / devait payer
    - solde global
    - projets actifs associés
  - permettre à terme une **identité visuelle configurable par membre** :
    - couleur choisie
    - cohérence d’affichage dans toute l’app
  - ne pas traiter maintenant : évolution structurante à garder pour **v2+**

### Plus tard / optionnel

- [ ] Sync locale MultipeerConnectivity
- [ ] App Clip ou partage de projet
- [ ] Apple Watch
- [ ] Multi-devises
- [ ] Nice-to-have non validés terrain
