# DuoSpend — Decisions Log

Format :
```
### [DATE] — [TITRE]
**Contexte** : pourquoi la question se posait
**Décision** : ce qui a été choisi
**Alternatives rejetées** : options écartées et pourquoi
```

---

### 2025-02-10 — SwiftData comme couche de persistance

**Contexte** : Choix de la solution de stockage local avec sync iCloud possible.
**Décision** : SwiftData. Intégration native SwiftUI, sync iCloud automatique via CloudKit, moins de boilerplate que Core Data, modern Swift API.
**Alternatives rejetées** :
- Core Data → verbeux, intégration SwiftUI moins naturelle
- Realm → dépendance tierce (contraire au principe zéro dépendance)
- SQLite/GRDB → trop bas niveau, pas de sync iCloud gratuite

---

### 2025-02-10 — MVVM avec Observation framework

**Contexte** : Choix d'architecture.
**Décision** : MVVM avec `@Observable` (iOS 17+). Simple, adapté à SwiftUI, pas de boilerplate `ObservableObject` / `@Published`.
**Alternatives rejetées** :
- TCA → trop complexe pour la taille du projet + dépendance tierce
- MV (sans ViewModel) → insuffisant pour la logique de calcul de balance
- VIPER → overkill pour une app indie solo

---

### 2025-02-10 — Decimal pour les montants financiers

**Contexte** : Quel type pour stocker les montants d'argent.
**Décision** : `Decimal` (Foundation). Précision exacte, pas d'erreur d'arrondi.
**Alternatives rejetées** :
- `Double` → 0.1 + 0.2 ≠ 0.3, inacceptable pour de l'argent
- `Int` (centimes) → fonctionnel mais moins lisible, conversion nécessaire partout

---

### 2025-02-10 — Zéro dépendance tierce

**Contexte** : Utiliser ou non des librairies externes (Charts, Lottie, etc.).
**Décision** : Aucune. Apple frameworks uniquement.
**Raisons** : pas de maintenance deps, pas de breaking changes, app plus légère, apprentissage Swift natif.

---

### 2025-02-10 — MVP tout gratuit, paywall en v2

**Contexte** : Implémenter le freemium dès le départ ?
**Décision** : Non. Tout gratuit dans le MVP. StoreKit 2 + paywall ajoutés en v2 après validation de l'UX.
**Raison** : Se concentrer sur la valeur produit, pas la monétisation. Pas de friction utilisateur pendant la phase de validation.

---

### 2025-02-10 — Euro uniquement au MVP

**Contexte** : Supporter plusieurs devises ?
**Décision** : Non. Euro (€) uniquement. Multi-devises en v3 éventuel.
**Raison** : Cible initiale = France. Ajouter le multi-devises complexifie les calculs (taux de change) et l'UX pour un gain marginal au lancement.

---

### 2025-02-10 — Maximum 2 partenaires par projet (jamais plus)

**Contexte** : Permettre 3+ personnes ?
**Décision** : Non, jamais. DuoSpend est pour les **couples**. 2 partenaires max, c'est le concept.
**Raison** : 3+ personnes = Splitwise/Tricount. La contrainte à 2 simplifie radicalement l'UX, le calcul de balance, et le positionnement marketing.

---

### 2025-02-11 — Budget obligatoire par projet (pas optionnel)

**Contexte** : Le budget était optionnel à la création du projet.
**Décision** : Le budget devient **obligatoire**. `Project.budget` passe de `Decimal?` à `Decimal`.
**Raison** : Le budget par projet est le cœur du concept DuoSpend ("budget projets pour couples"). Sans budget, l'app n'est qu'un tracker de dépenses classique. La barre de progression budget/dépensé est le visuel clé qui différencie l'app.

---

### 2025-02-11 — Monétisation : 1 projet gratuit + achat unique 3,99 €

**Contexte** : Comment monétiser l'app ?
**Décision** : Freemium avec 1 projet gratuit. Achat unique (non-consommable) à 3,99 € pour débloquer les projets illimités à vie. StoreKit 2, product ID `com.duospend.unlimitedprojects`.
**Raison** : Pas d'abonnement (trop agressif pour une app utilitaire). Pas de pubs (ruine l'UX). 3,99 € est le sweet spot App Store FR pour ce type d'app. 1 projet gratuit permet de tester vraiment l'app avant de payer. Conversion estimée : 3-5% des users actifs.


---

### 2026-03-14 — Stratégie de sync couple : CloudKit Sharing en v2

**Contexte** : Comment permettre aux deux partenaires d'utiliser DuoSpend chacun sur leur iPhone, avec leurs propres comptes Apple ?

**Décision** : Approche progressive en 3 étapes.

- **v1.0 (MVP)** : mono-appareil. Une seule personne saisit toutes les dépenses. Suffisant pour valider le concept et lancer sur l'App Store.
- **v1.1** : iCloud sync automatique via SwiftData. Fonctionne si les deux iPhones partagent le même compte Apple (couple sur le même Apple ID). Quasi gratuit en développement — activer `cloudKitDatabase: .automatic` dans `ModelConfiguration`.
- **v2.0** : CloudKit Sharing (`CKShare`). Chaque partenaire a son propre compte Apple. Marie crée un projet → génère un lien d'invitation (QR code ou lien partageable via iMessage/WhatsApp) → Thomas ouvre le lien → le projet apparaît dans son app. Les deux ajoutent des dépenses, la sync est bidirectionnelle et automatique.

**Détails techniques v2.0** :
- SwiftData + `NSPersistentCloudKitContainer` supporte les zones partagées CloudKit
- `UICloudSharingController` pour l'invitation (ou custom avec `CKShare.URL`)
- Chaque projet partagé vit dans une `CKRecordZone` dédiée
- Le propriétaire du projet (créateur) contrôle les permissions (lecture/écriture)
- Fonctionne hors ligne grâce au store local SwiftData — sync au retour du réseau
- Zéro backend custom, zéro serveur, zéro coût infra — Apple gère tout

**Alternatives rejetées** :
- Firebase/Supabase → dépendance tierce, coût serveur, complexité RGPD, contre les principes du projet
- Serveur custom (API REST) → overkill pour 2 users par projet, coût de maintenance
- Bluetooth/peer-to-peer → portée limitée, UX fragile, pas de sync asynchrone
- Partage par export/import JSON → pas de sync temps réel, UX laborieuse

---

### 2026-03-18 — MultipeerConnectivity pour la sync locale entre 2 iPhones

**Contexte** : Permettre à un couple (2 Apple ID différents) de synchroniser un projet quand ils sont à proximité, sans attendre CloudKit Sharing (v2.0).

**Décision** : Implémenter une sync peer-to-peer via MultipeerConnectivity (framework Apple natif). Le host envoie un `SyncPayload` JSON contenant le projet + toutes ses dépenses. Le receveur fusionne les données dans son SwiftData local avec dédoublonnage (titre + montant + date à la seconde).

**Détails techniques** :
- Service type : `duospend-sync` (Bonjour/Bluetooth/WiFi local)
- Chiffrement : `MCEncryptionPreference.required` (DTLS)
- Transfert : `MCSession.send()` pour les payloads < 90 KB, `sendResource()` au-delà
- Résolution de conflits : dédoublonnage sur `title + amount + date`, pas de last-write-wins destructif
- Sync manuelle uniquement (pas de sync en arrière-plan) — économie batterie + clarté UX
- Architecture : `PeerSyncService` (MC) → `PeerSyncViewModel` (coordination) → `SyncMergeService` (fusion pure, testable)
- Swift 6 strict concurrency : delegates MC isolés via `nonisolated(unsafe)` + `Task { @MainActor in }`

**Alternatives rejetées** :
- Attendre CloudKit Sharing v2.0 → trop long, les utilisateurs veulent syncer dès le lancement
- WebSocket/serveur custom → dépendance tierce, coût infra, contre le principe zéro dépendance
- Partage via AirDrop/fichier → pas intégré dans l'app, UX fragmentée

**Complémentarité** : MultipeerConnectivity = sync ponctuelle à proximité. CloudKit Sharing (v2.0) = sync continue à distance. Les deux coexisteront.
