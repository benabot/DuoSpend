# Screenshots App Store

## Dimensions obligatoires Apple (2026)

| Dossier | Device | Dimensions portrait | Notes |
|---|---|---|---|
| `6.9/` | iPhone 16 Pro Max (ou Plus) | 1320 × 2868 px | **Obligatoire** pour iPhone moderne |
| `5.5/` | iPhone 8 Plus | 1242 × 2208 px | **Obligatoire** pour iPhone legacy |

## Série recommandée (6 captures par langue et par taille)

1. `01-projects-list.png` — Liste de projets peuplée (3–4 projets)
2. `02-project-detail.png` — Détail d'un projet avec dépenses et balance
3. `03-add-expense.png` — Formulaire d'ajout de dépense
4. `04-balance-banner.png` — Vue avec balance « X doit Y à Z »
5. `05-settings-pro.png` — Écran Settings avec section Pro
6. `06-onboarding.png` — Onboarding ou Paywall

## Commandes de capture

```bash
# Booter un device précis
xcrun simctl list devices | grep "iPhone 16 Pro Max"
xcrun simctl boot <UUID>

# Ouvrir l'app sur ce simulateur
open -a Simulator
xcrun simctl install booted /path/to/DuoSpend.app
xcrun simctl launch booted fr.beabot.DuoSpend

# Capturer l'écran courant
xcrun simctl io booted screenshot ~/Desktop/screen.png
```

## Bascule langue du simulateur

```bash
# Passer en anglais
xcrun simctl spawn booted defaults write -g AppleLanguages -array en
xcrun simctl spawn booted defaults write -g AppleLocale en_US

# Retour en français
xcrun simctl spawn booted defaults write -g AppleLanguages -array fr
xcrun simctl spawn booted defaults write -g AppleLocale fr_FR

# Puis relancer le simulateur
```

## Règles qualité

- Pas d'écrans vides (tous les projets et dépenses peuplés).
- Prénoms crédibles : Léa & Tom (FR), Emma & Jack (EN).
- Montants réalistes (ex. Voyage Italie 847,50 €).
- Pas de barre de statut du simulateur visible — activer `xcrun simctl status_bar booted override --time "9:41"` pour un rendu propre.
- Heure affichée uniforme sur tous les screenshots : 9h41 (convention Apple).

## Status bar propre

```bash
# Forcer 9h41, batterie à 100 %, Wi-Fi plein
xcrun simctl status_bar booted override \
  --time "9:41" \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100

# Réinitialiser
xcrun simctl status_bar booted clear
```
