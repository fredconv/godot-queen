# Style Guide

## Palette (UiPalette)

| Token | Usage |
|-------|--------|
| `CREAM` | Texte corps |
| `GOLD` / `GOLD_BRIGHT` | Titres, scores, hover |
| `PANEL_BG` + bordure or | Overlays (transition vers bois) |
| `BTN_BG*` | Fallback StyleBoxFlat |
| Fond tapis | `#072612` + texture feutre |

## Typographie

| Contexte | Police | Taille |
|----------|--------|--------|
| Titre menu | Press Start 2P | 12px |
| Boutons menu | Press Start 2P | 9px (`MENU_BUTTON_FONT_SIZE`) |
| Barre table | Press Start 2P | 7–10px |
| Sièges | Press Start 2P | 8px |

Règle : pas plus de 2 lignes de texte sur un bouton 260×36.

## Espacements

| Élément | Valeur |
|---------|--------|
| Séparation boutons menu | 14px |
| Marge intérieure enseigne | 28 / 52 / 28 / 24 |
| Marges overlay | 20px (thème) |
| Zone tactile minimale | 36px hauteur |

## Sprites

- Filtre : **Nearest** (project.godot)
- Export slices : `(left, top, right, bottom)` depuis feuille source — voir `UiBundleCatalog.REGIONS_MEDIEVAL`
- Ne pas étirer les icônes 16×16 au-delà de 32×32 sans StyleBox margins

## États interactifs

| État | Rendu |
|------|--------|
| Normal | `btn_light_normal` |
| Hover | modulate +1.12 luminosité |
| Pressed | `btn_light_pressed` |
| Focus | bordure or 2px (StyleBoxFlat) |

## Thèmes à ne pas mélanger

Medieval + Casino accents : **oui**  
Medieval + Horror / Cyber / Pastel : **non** sur un même écran
