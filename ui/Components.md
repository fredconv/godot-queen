# Composants UI

## Implémentés

| Composant | Scène / script | Rôle |
|-----------|----------------|------|
| **NinePatchButton** (vivant) | `scenes/menus/button_template.tscn` + `nine_patch_button.gd` | Bouton 9-slice menus/dialogs — **pipeline par défaut** |
| **PixelButton** (legacy) | `pixel_button.gd` ; scène **archivée** | Wood 32×32 — ne plus utiliser pour nouveaux écrans (IDEA-00018) |
| **DialogTemplate** | `assets/_archive/scenes/menus/dialog_template.tscn` (hors export) | Panneau dialog 9-slice (`NinePatchPanel`) — pas de copie live |
| **ModalOverlayScreen** | `scripts/components/ui/modal_overlay_screen.gd` | Base overlays menu (Pack A = anim open/close) |
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
