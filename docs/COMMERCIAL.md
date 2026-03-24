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

## 5. Roadmap business

### MVP v1
- gratuit ;
- sans publicité ;
- sans abonnement ;
- sans limitation artificielle dans la première version publique si ce choix est maintenu.

### Piste v2 Premium
Ancienne hypothèse issue du document source :
- achat unique autour de 6,99 € ;
- projets illimités si la v1 impose ensuite une limite ;
- templates projets ;
- export PDF ;
- fonctions avancées éventuelles.

Décision à prendre explicitement avant implémentation StoreKit 2.

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
