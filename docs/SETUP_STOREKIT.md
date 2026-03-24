# Configuration StoreKit pour les tests Xcode

Le fichier `.storekit` doit être créé manuellement dans Xcode (il n'est pas versionnable automatiquement).

## Créer la configuration StoreKit de test

1. Dans Xcode : **File > New > File > StoreKit Configuration File**
2. Nom : `DuoSpendStore.storekit`
3. Emplacement : `DuoSpend/Resources/`
4. **NE PAS** cocher "Sync this file with an app in App Store Connect"
5. Ajouter un produit :
   - Type : **Non-Consumable**
   - Reference Name : `DuoSpend Pro`
   - Product ID : `com.duospend.unlimitedprojects`
   - Price : `6.99`
   - Display Name (fr) : `DuoSpend Pro`
   - Description (fr) : `Débloquer les projets illimités`
   - Display Name (en) : `DuoSpend Pro`
   - Description (en) : `Unlock unlimited projects`

## Activer la configuration dans le scheme

1. Dans Xcode : **Edit Scheme > Run > Options**
2. **StoreKit Configuration** : sélectionner `DuoSpendStore.storekit`

## Tester les achats en simulateur

- Le simulateur utilise la configuration locale, pas App Store Connect.
- Lors du `product.purchase()`, une feuille Apple fictive apparaît.
- Utiliser "Approve" pour simuler un achat réussi.
- Utiliser le menu **Debug > StoreKit > Manage Transactions** dans Xcode pour refund / réinitialiser.

## Notes

- Product ID utilisé dans le code : `com.duospend.unlimitedprojects`
- En production, créer le même produit dans App Store Connect avec le même Product ID.
- L'entitlement est vérifié via `Transaction.currentEntitlements` au lancement.
