# DuoSpend — Decisions Log

Format recommandé :

```text
### [DATE] — [TITRE]
**Contexte** : pourquoi la question se posait
**Décision** : ce qui a été choisi
**Alternatives rejetées** : options écartées et pourquoi
**Impact** : conséquence pratique dans le code ou le produit
```

---

### 2025-02-10 — SwiftUI comme couche UI principale

**Contexte** : choix de la technologie d’interface pour le MVP.

**Décision** : utiliser SwiftUI comme couche UI principale de l’app.

**Alternatives rejetées** :
- UIKit majoritaire → plus verbeux, moins cohérent avec Observation et SwiftData
- architecture hybride UIKit/SwiftUI → complexité inutile pour un produit de cette taille

**Impact** : les écrans sont conçus en SwiftUI ; UIKit reste éventuellement limité à des points d’intégration système.

---

### 2025-02-10 — SwiftData comme persistance principale

**Contexte** : choix de la solution de stockage local avec possibilité d’évolution vers iCloud.

**Décision** : SwiftData comme couche de persistance principale.

**Alternatives rejetées** :
- Core Data → plus verbeux, intégration moins directe pour ce scope
- Realm → dépendance tierce
- SQLite / GRDB → trop bas niveau pour le MVP

**Impact** : modèles annotés `@Model`, lectures simples via `@Query`, mutations via `ModelContext`.

---

### 2025-02-10 — Architecture MVVM avec Observation framework

**Contexte** : choix d’architecture pour séparer UI, orchestration et logique métier.

**Décision** : MVVM avec `@Observable`.

**Alternatives rejetées** :
- TCA → trop complexe pour la taille du projet + dépendance tierce
- MV sans ViewModel → insuffisant pour la logique d’écran
- VIPER → disproportionné pour une app indie solo

**Impact** : `@Observable` remplace `ObservableObject` ; les vues gardent une responsabilité d’affichage.

---

### 2025-02-10 — Tous les montants métier en Decimal

**Contexte** : quel type utiliser pour représenter l’argent.

**Décision** : `Decimal` pour tous les montants métier.

**Alternatives rejetées** :
- `Double` → imprécisions d’arrondi inacceptables
- `Int` en centimes → viable mais moins lisible pour l’état actuel du produit

**Impact** : `Double` est exclu des montants fonctionnels et des calculs de balance.

---

### 2025-02-10 — Aucune dépendance tierce

**Contexte** : utiliser ou non des bibliothèques externes.

**Décision** : frameworks Apple uniquement.

**Alternatives rejetées** :
- librairies UI / persistance / analytics externes → maintenance accrue, surface de rupture plus large

**Impact** : pas de dépendance tierce pour l’UI, la persistance, la sync ou la monétisation.

---

### 2025-02-10 — Produit limité à deux partenaires

**Contexte** : faut-il supporter 3+ personnes par projet.

**Décision** : non. DuoSpend est strictement conçu pour deux partenaires.

**Alternatives rejetées** :
- nombre variable de participants → change le produit et rapproche l’app de Splitwise / Tricount

**Impact** : l’UX, les modèles et le calcul de balance restent optimisés pour 2 personnes uniquement.

---

### 2025-02-10 — Euro comme devise de départ

**Contexte** : faut-il supporter plusieurs devises dès la première version.

**Décision** : centrer le MVP sur l’euro.

**Alternatives rejetées** :
- multi-devises immédiat → complexité produit et UX trop élevée pour le lancement

**Impact** : le MVP peut rester simple ; le multi-devises reste une évolution éventuelle.

---

### 2025-02-11 — Budget obligatoire par projet

**Contexte** : le budget était initialement traité comme optionnel.

**Décision** : le budget devient obligatoire par projet.

**Alternatives rejetées** :
- budget optionnel → rend le produit plus proche d’un simple tracker de dépenses

**Impact** : la création de projet doit exiger un budget ; si le code stocke encore `Decimal?`, il faut corriger cet écart.

---

### 2025-02-11 — Monétisation : achat unique plutôt qu’abonnement

**Contexte** : choisir un modèle économique compatible avec une app utilitaire simple.

**Décision** : privilégier un achat unique pour débloquer les projets illimités plutôt qu’un abonnement.

**Alternatives rejetées** :
- abonnement → trop agressif pour ce type d’usage
- publicité → détériore l’UX

**Impact** : la structure freemium peut être conservée, mais le prix exact et les métadonnées commerciales doivent vivre dans `docs/COMMERCIAL.md`, pas ici.

---

### 2026-03-14 — Stratégie de sync couple progressive

**Contexte** : permettre l’usage par deux partenaires avec des comptes Apple distincts sans casser la simplicité du MVP.

**Décision** : progression en étapes.
- v1.0 : usage local / mono-appareil pour valider le produit
- v1.1 : synchronisation iCloud basique si même compte Apple
- v2.0 : partage CloudKit entre deux comptes Apple distincts

**Alternatives rejetées** :
- backend custom → coût et complexité inutiles
- Firebase / Supabase → dépendance tierce et charge RGPD
- export/import manuel → UX médiocre

**Impact** : la sync existe comme trajectoire produit, mais le MVP ne doit pas en dépendre.

---

### 2026-03-18 — Sync locale ponctuelle via MultipeerConnectivity

**Contexte** : offrir un mode de synchronisation à proximité avant un vrai partage CloudKit complet.

**Décision** : autoriser une sync locale ponctuelle via MultipeerConnectivity comme piste v2.

**Alternatives rejetées** :
- attendre uniquement CloudKit Sharing → trop tardif si un besoin terrain apparaît plus tôt
- AirDrop / fichier manuel → UX fragmentée
- serveur temps réel → surdimensionné

**Impact** : cette piste reste complémentaire de CloudKit Sharing et n’appartient pas au MVP 1.0.
