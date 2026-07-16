# Assets archivés (hors livrable)

Dossier de quarantine pour les ressources **réellement inutilisées** au runtime.
Exclu de l’export Windows via `export_presets.cfg` (`exclude_filter`).

## Contenu

| Sous-dossier | Contenu |
|--------------|---------|
| `cards/` | Dos bleu, blanks, jokers, variantes `*_alt.png` |
| `sprites/ui/medieval/` | PNG `_debug_*` |
| `sprites/UIBundleFree/` | Feuilles demo (FreeUI, Pastel, etc.) — sheets actifs `MediavelFree` / `freecasinoui` restent en place |
| `sprites/` | One-shots (`super_attaque`, `bouton_9patch`, …) |
| `scenes/` | Scènes mortes (`main.tscn`, `pixel_button.tscn`, `dialog_template.tscn`) |
| `fonts/` / `references/` | Police / refs non branchées |

## Faux positifs MCP — ne pas archiver

- Deck principal `assets/cards/kerenel_Cards_seperated/*.png` → chargé via `CardTexturePaths.load()`
- SFX / musiques listés dans `AudioPaths` → chargés via `AudioService` (A5 — confirmé préload dynamique)
- Slices médiévales / casino référencées dans `UiBundleCatalog` + `UiStyleFactory`

Script `pixel_button.gd` (`class_name PixelButton`) reste actif ; seule la scène template est archivée.
