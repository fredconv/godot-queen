# Composants UI

## Implémentés

| Composant | Scène / script | Rôle |
|-----------|----------------|------|
| **PixelButton** | `scenes/components/ui/pixel_button.tscn` | Bouton NinePatch médiéval 32×32, 192×48 |
| **ButtonTemplate** | `scenes/menus/button_template.tscn` | Bouton 9-slice générique 15×15 (`NinePatchButton`) |
| **DialogTemplate** | `scenes/menus/dialog_template.tscn` | Panneau dialog 9-slice (`NinePatchPanel`) |
| **UiOffsetAnim** | `scripts/core/ui/ui_offset_anim.gd` | Entrée/sortie via `offset_transform_scale` (Godot 4.7) |
| Menu principal | `scenes/menus/main_menu.tscn` | Titre + `button_template` orange (NinePatchButton) |
| Overlays menu | `settings_screen`, `scores_screen`, `credits_screen`, `profile_setup_screen` | Modales ; thème `pixel_theme` |
| Barre table | `scenes/components/top_menu_bar.tscn` | Infos tour + actions |
| Dialogs table | `confirm_dialog`, `hand_end_dialog`, `match_end_dialog` | Confirmation / fin manche / fin partie |
| Siège joueur | `player_seat.tscn` | Main + avatar + score |
| Carte | `card_view.tscn` | Affichage carte |

## Services code

| Classe | Rôle |
|--------|------|
| `UiPalette` | Couleurs |
| `UiBundleCatalog` | Chemins sprites bundle |
| `UiStyleFactory` | StyleBoxTexture médiéval |
| `UiFocusNav` | Focus chain + Échap |
| `LocaleFonts` | Tailles par contexte |

## À créer (prochaines itérations)

| Composant | Description |
|-----------|-------------|
| `medieval_panel.tscn` | NinePatch corners + fond bois pour overlays |
| `medieval_button.tscn` | Bouton avec styles factory pré-appliqués |
| `icon_button.tscn` | 16×16 bundle + tooltip |
| `medieval_slider.tscn` | HSlider + `progress_track` |

## Variantes bouton

| Variante | Style |
|----------|--------|
| `primary` | `btn_light_*` — action principale |
| `secondary` | `btn_dark_*` — retour, annuler |
| `icon` | Texture icône seule + hitbox 36×36 |

## Documentation des slices

Toute nouvelle découpe doit être ajoutée dans `UiBundleCatalog` + `assets/sprites/ui/<theme>/` + une ligne dans `StyleGuide.md`.
