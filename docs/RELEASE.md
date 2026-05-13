# RELEASE.md — DuoSpend

Ce document contient uniquement ce qui concerne la mise en production, TestFlight et l’App Store.
Il ne doit pas contenir de règles de code, de détails d’architecture, ni de backlog produit hors release.

## 1. Objectif de release

Version ciblée : **1.0.0**

Positionnement du MVP :
- app iPhone uniquement ;
- usage couple uniquement ;
- local-first ;
- sync iCloud/CloudKit comme confort utilisateur, pas comme dépendance fonctionnelle ;
- aucune publicité ;
- aucun tracking ;
- aucune collecte tierce de données.

## 2. Préparation avant soumission

### Produit
- Vérifier que le scope MVP est gelé.
- Écarter toute fonctionnalité post-MVP non indispensable.
- Vérifier que le wording produit reste cohérent avec la promesse : **"Qui doit combien à qui ?"**

### Build
- Vérifier le `Bundle Identifier`.
- Vérifier la version marketing et le numéro de build.
- Générer une archive Release propre.
- Corriger tous les warnings bloquants avant archive.
- Vérifier la signature et les capabilities.

### CloudKit / iCloud
- Vérifier que les entitlements sont activés.
- Vérifier le comportement hors ligne.
- Vérifier le premier lancement sur appareil réel.
- Vérifier un cas de synchronisation minimal entre deux appareils du même compte.
- Vérifier qu’un échec iCloud ne casse jamais l’usage local.

### Privacy
- Vérifier le fichier `PrivacyInfo.xcprivacy`.
- Vérifier que la description App Store n’annonce rien de contraire au fonctionnement réel.
- Préparer une URL de politique de confidentialité.
- Préparer une URL de support.

## 3. Checklist de validation fonctionnelle

### Parcours critiques
- Création d’un projet.
- Modification d’un projet.
- Suppression d’un projet.
- Ajout d’une dépense.
- Modification d’une dépense.
- Suppression d’une dépense.
- Calcul du solde correct.
- Affichage correct des montants en `Decimal`.
- Fonctionnement sans réseau.

### Qualité UX
- Aucune chaîne cassée (FR et EN).
- Aucun texte tronqué sur petits écrans pris en charge (FR et EN).
- Mode sombre vérifié (FR et EN).
- États vides cohérents (FR et EN).
- Formulaires validés (FR et EN).
- Pas de crash sur navigation standard (FR et EN).
- Localisation : tous les écrans, widgets et formulaires traduits en français et anglais via String Catalog xcstrings.

### Technique
- Pas de `print()` résiduel.
- Pas de force unwrap hors previews.
- Pas de logique métier dans les vues.
- Pas de régression SwiftData sur les relations.
- Vérifier que `LocalizedStringKey` est utilisé correctement (jamais de ternaires pour du texte localisé).
- Widgets bundlés correctement avec xcstrings pour traduction complète.

## 4. TestFlight

### Préparation
- Créer une archive Release.
- Uploader le build.
- Remplir les informations minimales de test avec les textes prêts à coller dans `docs/APP_STORE_CONNECT.md`.
- Rédiger des notes de version courtes et factuelles.

### Validation recommandée
- Test interne sur appareil réel.
- Vérification installation / mise à jour.
- Vérification création de données réelles.
- Vérification persistance après relance.
- Vérification comportement iCloud si activé.

### Points à observer
- stabilité générale ;
- cohérence du calcul des balances ;
- qualité de l’onboarding et de la première création de projet ;
- lisibilité des cartes, bannières et lignes de dépense.

## 5. Métadonnées App Store

À finaliser au moment de la soumission pour éviter les divergences.

### Nom
- DuoSpend

### Sous-titre
- À définir juste avant soumission, en cohérence avec le positionnement retenu.

### Description courte de référence
DuoSpend aide un couple à suivre les dépenses d’un projet commun et à savoir en permanence qui doit combien à qui.

### Description longue — trame
- problème : suivre des dépenses à deux devient vite confus ;
- promesse : une vue claire du budget et du solde entre partenaires ;
- bénéfices : simplicité, fonctionnement hors ligne, confidentialité ;
- cas d’usage : voyage, mariage, emménagement, projet bébé, travaux.

### Mots-clés
Les mots-clés finaux doivent être validés dans `docs/COMMERCIAL.md` avant publication.

## 6. Captures et visuels

Ce document ne fixe pas les tailles officielles ni les contraintes Apple détaillées.
Ces éléments doivent être revalidés juste avant la soumission.

### Série minimale de captures
1. Liste des projets
2. Détail d’un projet
3. Ajout d’une dépense
4. Balance / répartition
5. Vue avec budget

### Règles internes
- Montrer immédiatement le bénéfice produit.
- Éviter les écrans vides si possible pour les captures finales.
- Utiliser un jeu de données crédible et cohérent.
- Garder une terminologie simple.
- Préparer FR puis EN si nécessaire.

## 7. Données légales et support

À avoir prêtes avant soumission :
- URL de politique de confidentialité ;
- URL de support ;
- adresse de contact support ;
- catégorie App Store ;
- classification d’âge ;
- réponses de conformité si demandées.

Les brouillons App Privacy / nutrition labels et les checklists humaines App Store Connect vivent dans `docs/APP_STORE_CONNECT.md`.

## 8. Notes de version

### 1.0.0
Première version publique de DuoSpend.
Suivi simple des dépenses par projet pour couples, avec calcul clair du solde entre deux partenaires.

## 9. Points explicitement exclus de ce document

Ne pas remettre ici :
- conventions Swift / SwiftUI ;
- architecture MVVM détaillée ;
- backlog post-MVP ;
- stratégie ASO détaillée ;
- monétisation long terme.

Ces éléments vivent ailleurs :
- `docs/ARCHITECTURE.md`
- `docs/DESIGN.md`
- `docs/COMMERCIAL.md`
- `docs/MVP.md`
