# COMMERCIAL.md — DuoSpend

Ce document regroupe le positionnement marché, la monétisation, la roadmap business et l’ASO.
Il ne doit pas contenir de détails techniques de code ou d’architecture.

## 1. Positionnement

DuoSpend est une app iOS centrée sur un cas simple : gérer les dépenses d’un projet commun à deux et répondre clairement à la question : **"Qui doit combien à qui ?"**

## 2. Public cible

Cible prioritaire : couples qui organisent un projet commun, par exemple :
- voyage ;
- mariage ;
- emménagement ;
- travaux ;
- projet bébé.

## 3. Promesse produit

- compréhension immédiate du solde ;
- moins de friction dans les comptes à deux ;
- usage simple ;
- confidentialité forte ;
- fonctionnement hors ligne.

## 4. Différenciation

- focus strict sur 2 partenaires ;
- pas de logique groupe ;
- interface plus simple qu’un outil de budget générique ;
- approche Apple-native ;
- aucune dépendance externe ;
- pas de pub, pas de tracking.

## 5. Roadmap business & pricing

### v1.0 — Lancement
- **Modèle** : freemium — 1 projet gratuit + achat unique 6,99 € (projets illimités à vie).
- **Product ID StoreKit 2** : `com.duospend.unlimitedprojects` (Non-Consumable).
- Sans publicité, sans abonnement.
- Fonctionnalités gratuites : toutes les features core (widgets, export PDF, balance, budget).
- Paywall déclenché à la création du 2e projet.
- **Prix de lancement (optionnel)** : 4,99 € les 2 premières semaines, puis retour à 6,99 €.

### v1.1 — iCloud sync (même compte Apple)
- Maintien du prix à 6,99 €.
- Mention "iCloud sync incluse" dans la fiche App Store.

### v2.0 — CloudKit Sharing (2 comptes Apple séparés)
- Remontée du prix à **9,99 €** — c'est LA feature qui justifie le premium, car elle transforme l'app d'un outil solo en un vrai outil couple.
- Ajout possible de templates projets et fonctions avancées.

### Justification du pricing
- Splitwise Pro = ~60 €/an en abonnement. DuoSpend à 6,99 € one-time = prix d'1,5 mois de Splitwise.
- Tricount = gratuit (monétisé via bunq). DuoSpend se différencie par le focus couple, la privacy et l'approche Apple-native.
- 4,99 € sur l'App Store FR = perception "app qui s'excuse". 6,99 € = produit sérieux sans être intimidant.
- Marge promo : possibilité de lancer à 4,99 € puis remonter. Impossible dans l'autre sens.

## 6. Backlog commercial / produit non-MVP

Fonctionnalités mentionnées dans le document source :
- templates projets ;
- export PDF ;
- catégories ;
- widgets ;
- charts ;
- recherche dans les dépenses ;
- paywall StoreKit 2. fileciteturn2file0

Ce backlog doit être arbitré selon :
- impact utilisateur ;
- simplicité produit ;
- coût de maintenance ;
- cohérence avec la promesse initiale.

## 7. ASO de travail

Cette section sert de brouillon stratégique. Les métadonnées finales partent ensuite dans `docs/RELEASE.md` au moment de la soumission.

### Axe sémantique principal
- budget couple
- dépenses partagées
- partage des frais
- remboursement
- projet commun

### Variantes d’usage
- budget mariage
- budget voyage
- budget travaux
- budget emménagement

### Règles
- éviter les formulations vagues ;
- garder une promesse lisible ;
- ne pas survendre ;
- aligner captures, sous-titre et description.

## 8. Hypothèses à valider

- gratuit complet ou gratuit limité ;
- intérêt réel pour un achat unique ;
- utilité perçue des templates ;
- utilité réelle de l’export PDF ;
- sensibilité des utilisateurs au positionnement privacy/local-first.

## 9. Ce qui ne doit pas vivre ici

Ne pas remettre ici :
- conventions Swift ;
- détails de CloudKit ;
- structure MVVM ;
- checklist de build ;
- tâches du sprint courant.
