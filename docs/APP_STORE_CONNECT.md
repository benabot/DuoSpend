# App Store Connect / TestFlight — DuoSpend v1.0

Document opérationnel pour préparer App Store Connect, l'achat intégré DuoSpend Pro et TestFlight.

Ne pas confondre avec une validation App Store Connect terminée : les actions ci-dessous restent à effectuer manuellement dans l'interface Apple.

## Références

| Champ | Valeur |
|---|---|
| App Bundle ID | `fr.beabot.DuoSpend` |
| Widget Bundle ID | `fr.beabot.DuoSpend.Widget` |
| Product ID IAP | `fr.beabot.DuoSpend.unlimitedprojects` |
| Type IAP | Non-Consumable |
| Prix cible | 6,99 € |
| App Group | `group.fr.beabot.DuoSpend` |
| Team ID | `3Q33594A3N` |
| Support URL | `https://beabot.fr/apps/duo-spend/` |
| Privacy Policy URL | `https://beabot.fr/apps/duo-spend#policy` |

## TestFlight — Beta App Description FR

```text
DuoSpend aide les couples à suivre les dépenses d'un projet commun.

Chaque partenaire ajoute ses dépenses, puis l'app calcule clairement qui doit combien à qui.

L'app fonctionne localement, sans compte, sans publicité et sans tracking.

Pendant ce test, merci de vérifier la création de projet, l'ajout de dépenses, le calcul de la balance, le paywall Pro et, si disponible, l'achat/restauration StoreKit.
```

## TestFlight — What to Test FR

```text
À tester :

- Créer un projet avec deux partenaires.
- Ajouter plusieurs dépenses.
- Tester une répartition 50/50.
- Tester une répartition personnalisée.
- Vérifier que le solde indique clairement qui doit combien à qui.
- Modifier et supprimer une dépense si disponible.
- Modifier et supprimer un projet si disponible.
- Tenter de créer un second projet.
- Vérifier l'ouverture du paywall DuoSpend Pro.
- Tester l'achat et la restauration si StoreKit/TestFlight le permet.
- Vérifier le widget si disponible sur l'écran d'accueil.
- Vérifier l'export PDF si disponible.
- Vérifier les textes en français et en anglais.
- Signaler tout crash, calcul incohérent, texte tronqué ou problème d'affichage.

Merci d'indiquer le modèle d'iPhone, la version iOS et les étapes suivies en cas de bug.
```

## TestFlight — Beta App Description EN

```text
DuoSpend helps couples track the expenses of a shared project.

Each partner adds their expenses, and the app clearly calculates who owes what to whom.

The app is local-first, with no account, no ads, and no tracking.

For this test, please check project creation, expense entry, balance calculation, the Pro paywall, and StoreKit purchase/restore if available.
```

## TestFlight — What to Test EN

```text
Please test:

- Create a project with two partners.
- Add several expenses.
- Test a 50/50 split.
- Test a custom split.
- Check that the balance clearly shows who owes what to whom.
- Edit and delete an expense if available.
- Edit and delete a project if available.
- Try to create a second project.
- Check that the DuoSpend Pro paywall appears.
- Test purchase and restore if StoreKit/TestFlight allows it.
- Check the Home Screen widget if available.
- Check PDF export if available.
- Check French and English copy.
- Report any crash, incorrect calculation, truncated text, or display issue.

Please include your iPhone model, iOS version, and steps followed when reporting a bug.
```

## IAP App Store Connect — DuoSpend Pro

| Champ | Valeur |
|---|---|
| Reference Name | `DuoSpend Pro` |
| Product ID | `fr.beabot.DuoSpend.unlimitedprojects` |
| Type | Non-Consumable |
| Prix cible | 6,99 € |

### Localisation FR

Nom :

```text
DuoSpend Pro
```

Description :

```text
Déverrouillez les projets illimités dans DuoSpend avec un achat unique.
```

### Localisation EN

Name:

```text
DuoSpend Pro
```

Description:

```text
Unlock unlimited projects in DuoSpend with a one-time purchase.
```

## App Privacy / Nutrition Labels — brouillon de déclaration

État produit attendu pour v1.0 :

- Pas de tracking.
- Pas de publicité.
- Pas de compte utilisateur.
- Pas de backend propriétaire.
- Pas de serveur tiers.
- Données financières saisies localement par l'utilisateur.
- Persistance locale SwiftData sur l'iPhone.
- App Group local `group.fr.beabot.DuoSpend` utilisé pour partager un état réduit avec le widget.
- StoreKit / achat intégré géré par Apple.
- Support et politique de confidentialité via site public :
  - Support : `https://beabot.fr/apps/duo-spend/`
  - Privacy : `https://beabot.fr/apps/duo-spend#policy`

Déclaration recommandée côté éditeur : ne pas déclarer de collecte par l'éditeur si aucune donnée ne remonte à l'éditeur.

Note : Apple peut avoir ses propres catégories pour les achats, diagnostics ou données gérées par Apple. Vérifier les libellés exacts dans App Store Connect avant validation finale.

## Checklist humaine restante

### `#26` StoreKit local

- Faire le smoke test achat approuvé dans Xcode avec `DuoSpendStore.storekit`.
- Tester la restauration.
- Quitter et relancer l'app.
- Vérifier que l'état Pro persiste après achat valide.
- Réinitialiser les transactions StoreKit locales.
- Vérifier le retour à l'état gratuit sans transaction valide.

### `#28` IAP App Store Connect

- Créer l'IAP non-consommable.
- Vérifier le Product ID `fr.beabot.DuoSpend.unlimitedprojects`.
- Renseigner le prix cible 6,99 €.
- Vérifier disponibilité et territoires.
- Ajouter les localisations FR/EN.
- Vérifier que le statut est prêt pour la suite de soumission Apple.

### `#29` Privacy / Support / App Privacy

- Renseigner la Privacy Policy URL `https://beabot.fr/apps/duo-spend#policy`.
- Renseigner la Support URL `https://beabot.fr/apps/duo-spend/`.
- Compléter App Privacy / nutrition labels.
- Vérifier la cohérence avec `DuoSpend/Resources/PrivacyInfo.xcprivacy`.
- Vérifier que la déclaration ne mentionne pas de collecte éditeur si aucune donnée ne remonte à l'éditeur.

### `#30` App Store Connect / TestFlight

- Créer ou vérifier la fiche app DuoSpend.
- Vérifier Bundle ID `fr.beabot.DuoSpend`.
- Recommandation : Primary Language `French`.
- Prévoir localisations French + English.
- Renseigner catégorie, age rating, compliance chiffrement et informations de contact.
- Créer un groupe de test interne.
- Renseigner Beta App Description FR/EN.
- Renseigner What to Test FR/EN.
- Vérifier Feedback Email.
- Vérifier le build number après upload.
- Ne pas ouvrir de bêta externe avant validation interne.

