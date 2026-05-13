# Configuration StoreKit pour les tests Xcode

Le fichier de test local est versionné dans `DuoSpend/Resources/DuoSpendStore.storekit`.
Si ce fichier doit être recréé, le faire manuellement dans Xcode puis vérifier qu'il reste référencé par le scheme `DuoSpend`.

## Vérifier ou recréer la configuration StoreKit de test

1. Dans Xcode : **File > New > File > StoreKit Configuration File**
2. Nom : `DuoSpendStore.storekit`
3. Emplacement : `DuoSpend/Resources/`
4. **NE PAS** cocher "Sync this file with an app in App Store Connect"
5. Ajouter un produit :
   - Type : **Non-Consumable**
   - Reference Name : `DuoSpend Pro`
   - Product ID : `fr.beabot.DuoSpend.unlimitedprojects`
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

### Procédure manuelle issue #26

1. Ouvrir le scheme `DuoSpend`.
2. Vérifier **Edit Scheme > Run > Options > StoreKit Configuration** : `DuoSpendStore.storekit`.
3. Lancer l'app sur le simulateur de référence `874C77C4-CF94-4FC1-8279-EF7D97D2A90D`.
4. Créer un premier projet gratuit.
5. Tenter de créer un second projet.
6. Vérifier l'ouverture du paywall.
7. Vérifier que le produit local est chargé et que le prix local s'affiche.
8. Lancer un achat et choisir **Approve** dans la feuille StoreKit locale.
9. Vérifier que l'état Pro est actif.
10. Quitter puis relancer l'app.
11. Vérifier que l'état Pro persiste.
12. Tester **Restaurer mes achats**.
13. Réinitialiser les transactions via **Debug > StoreKit > Manage Transactions**.
14. Relancer l'app et vérifier que l'état gratuit revient sans transaction valide.

Limite CLI connue : l'audit automatisé vérifie le fichier `.storekit`, le Product ID, le type `NonConsumable`, le prix local et la référence du scheme. L'achat programmatique `SKTestSession.buyProduct` peut échouer en environnement CLI avec `.notEntitled` / `SKInternalErrorDomain Code=3`; la validation achat/restauration/reset reste donc un smoke test Xcode manuel.

## Notes

- Product ID utilisé dans le code : `fr.beabot.DuoSpend.unlimitedprojects`
- En production, créer le même produit dans App Store Connect avec le même Product ID.
- L'entitlement est vérifié via `Transaction.currentEntitlements` au lancement.
