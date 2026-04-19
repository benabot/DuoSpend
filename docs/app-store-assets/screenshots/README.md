# Screenshots App Store

Guide simple pour produire les captures FR / EN de la v1.0.

## Arborescence

```text
screenshots/
├── fr/
│   ├── 6.9/
│   └── 5.5/
└── en/
    ├── 6.9/
    └── 5.5/
```

## Devices à utiliser

| Dossier | Device | Résolution portrait |
|---|---|---|
| `6.9/` | iPhone 16 Pro Max | `1320 × 2868` |
| `5.5/` | iPhone 8 Plus | `1242 × 2208` |

Si le simulateur `iPhone 8 Plus` n'est pas disponible dans les runtimes installés, capturer sur un iPhone SE récent puis exporter en `1242 × 2208` avant dépôt final dans `5.5/`.

## Série à produire

1. `01-project-list.png` — liste des projets avec 3 à 4 projets crédibles
2. `02-project-detail.png` — détail d'un projet avec plusieurs dépenses et une balance lisible
3. `03-add-expense.png` — formulaire d'ajout de dépense
4. `04-balance.png` — focus sur la balance "qui doit combien à qui"
5. `05-settings-pro.png` — `SettingsView` avec la section Pro visible
6. `06-onboarding-or-paywall.png` — onboarding ou paywall selon le rendu le plus fort

## Règles de cohérence

- Pas d'écran vide dans la série finale.
- Garder les mêmes données de démonstration sur toute une langue.
- FR : prénoms `Léa` et `Tom`.
- EN : prénoms `Emma` et `Jack`.
- Exemples de projets : `Voyage Italie`, `Mariage`, `Travaux salon`.
- Exemples de montants : `847,50 €`, `129,90 €`, `42,00 €`.
- Pricing visible et cohérent partout : `1 projet gratuit`, puis `6,99 €` en achat unique.
- Ne jamais laisser penser que la sync iCloud est active en v1.0.

## Status bar

- Heure uniforme : `9:41`
- Batterie : `100 %`
- Réseau : Wi-Fi plein

```bash
xcrun simctl status_bar booted override \
  --time "9:41" \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100
```

## Capture rapide

```bash
xcrun simctl io booted screenshot /tmp/duospend-screen.png
```

## Bascule de langue

```bash
# English
xcrun simctl spawn booted defaults write -g AppleLanguages -array en
xcrun simctl spawn booted defaults write -g AppleLocale en_US

# Français
xcrun simctl spawn booted defaults write -g AppleLanguages -array fr
xcrun simctl spawn booted defaults write -g AppleLocale fr_FR
```
