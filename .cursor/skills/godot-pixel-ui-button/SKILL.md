---
name: godot-pixel-ui-button
description: >-
  Builds pixel-art UI buttons in Godot 4 using fixed sizes, 32×32 NinePatch
  backgrounds, centered labels, optional HBox icons, 8px grid, Nearest filter,
  and Pixel Snap. Use when creating or fixing buttons, menus, HUD controls,
  or pixel UI in the Dame de Pique Godot project.
---

# Godot Pixel UI Button (Dame de Pique)

## Règles (ne pas raccourcir)

1. **Crée le bouton à une taille fixe**

Par exemple :

160 × 48 px

ou

192 × 64 px

Évite les tailles "au hasard".

2. **Le fond doit être un NinePatch**

Au lieu de dessiner un bouton entier de 200 px de large, dessine seulement un petit bouton, par exemple :

32 × 32

avec :

les 4 coins
les bords
le centre

Ensuite utilise un NinePatchRect (ou le style NinePatch des boutons) pour l'étirer.

Ainsi :

les coins restent parfaits
seuls les bords s'allongent
le centre se répète ou s'étire

C'est la méthode utilisée dans la plupart des jeux pixel art.

3. **Le texte est centré automatiquement**

Ne dessine jamais le texte dans le sprite.

Le bouton contient uniquement :

```
█████████████
█           █
█           █
█           █
█████████████
```

Puis Godot affiche le texte par-dessus.

Dans les propriétés :

Horizontal Alignment = Center
Vertical Alignment = Center

Le texte sera toujours parfaitement centré.

4. **Si tu veux une icône**

Ne la dessine pas dans le fond.

Fais :

```
+----------------------+
| 🗡  Nouvelle partie  |
+----------------------+
```

avec :

HBoxContainer

├── TextureRect
└── Label

Godot s'occupe de l'alignement.

5. **Garde toujours une grille**

Par exemple :

1 pixel = 1 unité

ou

16 px

ou

8 px

Tous les éléments doivent tomber sur cette grille.

Par exemple :

Bouton

160×48

Marge gauche 16

Icône 16×16

Espace 8

Texte

Tout est multiple de 8.

6. **Désactive le filtrage**

Dans Godot :

Texture Filter = Nearest

Sinon le pixel art devient flou.

7. **Active le Pixel Snap**

Dans les paramètres du projet :

Rendering
    2D
        Snap
            ✓ Pixel Snap

Ainsi, le texte et les sprites restent nets.

## Structure projet (référence)

```
Button
│
├── NinePatchRect
│
└── MarginContainer
      │
      └── HBoxContainer
            │
            ├── TextureRect (optionnel)
            └── Label
```

### Pipeline **vivant** (menus, dialogs, lobbies)

| Élément | Chemin |
|---------|--------|
| Scène | `scenes/menus/button_template.tscn` |
| Script | `scripts/components/ui/nine_patch_button.gd` (`class_name NinePatchButton`) |
| Patch | `assets/sprites/9_grid_rounded_patch.png` (hover = modulate, pas texture dédiée) |

### Legacy **PixelButton** (ne plus utiliser pour nouveaux écrans)

| Élément | Chemin |
|---------|--------|
| Script | `scripts/components/ui/pixel_button.gd` (`class_name PixelButton`) |
| Scène | **archivée** → `assets/_archive/scenes/` (`pixel_button.tscn`) |
| Textures wood 32×32 | `assets/sprites/ui/ninepatch/btn_wood_32*.png` |

Constantes layout : `scripts/core/ui/ui_button_layout.gd` (`UiButtonLayout`).

HUD table (`top_menu_bar`) : boutons **Theme** `pixel_theme.tres` (StyleBoxFlat) — pas NinePatch 48 px (hauteur barre).

## Tailles standard (ce projet)

| Preset | Taille | Usage |
|--------|--------|-------|
| `MENU` | 192×64 | Menu principal — marges 24×12, air hors bordure or |
| `COMPACT` | 160×64 | Actions secondaires |

Grille : **8 px** (`UiButtonLayout.GRID`).

## Workflow agent

1. **Réutiliser** `button_template.tscn` (`NinePatchButton`) — ne pas recréer un bouton ad hoc.
2. Instancier dans la scène ; connecter le signal `pressed`.
3. Texte via `set_button_text()` (i18n) — jamais dans le PNG.
   Après refresh locale d’un **groupe** de boutons : `NinePatchButton.uniform_fit_group([...])`
   (élargit sur grille 8 pour que le label le plus long ne dépasse pas).
   Overlay centré : `sync_centered_panel_half_width(panel, buttons)`.
4. Icône : HBox + TextureRect dans le template si besoin — jamais dans le fond NinePatch.
5. Nouveau skin NinePatch : préférer patch existant ; **pas** d’asset externe sans validation. Hover/pressed via modulate + `UiOffsetAnim` (scale ≤ 1.05).
6. Vérifier `project.godot` : `default_texture_filter=0`, snap 2D activé.
7. Documenter dans `ui/Components.md` si nouveau preset ou variante.
8. **Ne pas** réintroduire `pixel_button.tscn` hors archive sans décision explicite (IDEA-00018).

## Anti-patterns (ce projet)

- ❌ `StyleBoxTexture` étiré sur une texture 16×16 avec icône
- ❌ Texte incrusté dans le sprite
- ❌ Tailles type 260×40 ou 34 px de hauteur
- ❌ Mélanger thèmes bundle (medieval + casino) sur un même écran sans raison

## Fichiers liés

- `ui/StyleGuide.md` — palette et typo
- `ui/DesignSystem.md` — choix thème UIBundleFree
- `scripts/core/ui/ui_style_factory.gd` — AtlasTexture `region` (icônes / panneaux, pas fond bouton)
- `scripts/core/ui/ui_offset_anim.gd` — tweens `offset_transform_*` (Godot 4.7)

---

## Nine-slice (`NinePatchRect`) — référence Godot 4.4+

### Grille 3×3

```
+-----+-----------+-----+
|  A  |     B     |  C  |  coins A,C,G,I : jamais étirés
+-----+-----------+-----+  bords B,D,F,H : une direction
|  D  |     E     |  F  |  centre E       : les deux axes
+-----+-----------+-----+
|  G  |     H     |  I  |
+-----+-----------+-----+
```

### Image source (pixel art)

| Format | Marges patch | Usage |
|--------|--------------|-------|
| **32×32**, bordure **8 px** | L/R/T/B = **8** | Boutons menu (`btn_wood_32.png`) |
| **48×48**, bordure **4 px** | L/R/T/B = **4** | Variante détaillée |

- Centre **plat et répétable** (bois uniforme).
- **Jamais de texte** dans le PNG.
- Générer via `python tools/generate_ui_ninepatch.py` si la planche source change.

### Propriétés Godot obligatoires

```gdscript
nine_patch.patch_margin_left = 8   # = largeur coin
nine_patch.patch_margin_right = 8
nine_patch.patch_margin_top = 8
nine_patch.patch_margin_bottom = 8
nine_patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
nine_patch.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
nine_patch.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
```

| `AxisStretchMode` | Quand |
|-------------------|-------|
| `STRETCH` (0) | Déforme — éviter sur pixel art |
| `TILE` (1) | **Recommandé** — centre répété sans artefacts |
| `TILE_FIT` (2) | Tuile + ajustement (léger stretch) |

`region_rect` : utiliser si atlas ; sinon texture dédiée 32×32.

### Anti-patterns NinePatch (ce projet)

- ❌ Utiliser `btn_plank_normal.png` (80×16) directement sur un bouton 192×48 — étire verticalement + expose les rivets
- ❌ `panel_hanging` découpé trop large (122 px) — inclut icônes + barre de progression de l’atlas
- ❌ Marges patch incorrectes — pierre/rivet dupliquée au centre
- ❌ `axis_stretch_* = STRETCH` sur pixel art sans test visuel

### Panneau enseigne menu

- Découpe atlas : `Rect2i(2, 1, 72, 91)` — enseigne **seule**
- Affichage ×2 : **144×182** px (`MENU_PANEL_DISPLAY_SIZE`)
- Titre sur l’enseigne ; boutons **en dessous** dans `ButtonStack`

---

## Nine-slice (rappel court)

1. Canvas source **divisible par 3** (ex. 15×15 → grille 5 px, ou 32×32 → marge 8 px).
2. Dessiner coins + bords + centre ; **jamais** le texte.
3. Dans Godot : `NinePatchRect` avec `patch_margin_*` = taille d’un coin (ici 8 px sur texture 32×32).
4. Étirer le nœud à la taille fixe du bouton (192×48) — seuls bords et centre s’adaptent.

---

## Animations UI — Godot 4.7 `offset_transform`

### Problème résolu

Les `Container` recalculent position/scale/rotation des enfants → impossible d’animer proprement avec `scale` classique au moment d’un ajout/retrait, ou sans nœud dummy intermédiaire.

### Solution

`offset_transform_*` s’applique **par-dessus** le layout ; le container ne l’écrase pas.

| Propriété | Usage typique |
|-----------|----------------|
| `offset_transform_enabled` | Activer avant toute animation |
| `offset_transform_scale` | Apparition (0→1), hover léger |
| `offset_transform_position_ratio` | Décalage relatif (0 = origine, 1 = taille du control) |
| `offset_transform_rotation` | Cartes en éventail, look « déstructuré » |
| `offset_transform_visual_only` | `true` par défaut — clic à la position layout (recommandé hover) |

### Quand utiliser quoi

| Cas | Approche |
|-----|----------|
| Hover / press dans un VBox stable | `offset_transform_scale` ou tween `scale` (si pas de recalcul) |
| Show/hide boutons dans un container | `offset_transform_scale` 0↔1 (pas de flash frame 0) |
| Cartes qui se chevauchent (main joueur) | Dummy `Control` + tween `custom_minimum_size` (container calcule l’espacement) |
| UI style Persona / décalée | `offset_transform_position_ratio` + rotation |

### Helper projet

```gdscript
# Entrée menu décalée (main_menu.gd)
for button in _menu_buttons:
    UiOffsetAnim.prepare_hidden(button)
UiOffsetAnim.stagger_scale_in(_menu_buttons)  # TRANS_BACK, 0.05 s entre chaque

# Hover ponctuel
UiOffsetAnim.tween_scale(button, Vector2(1.04, 1.04), 0.1)
```

### Pré-4.7 (legacy)

- Tween `scale` OK si le container ne recalcule pas.
- Show/hide : attendre 1 frame ou `modulate.a = 0` (pas `visible`, qui recalcule le container).
- Dummy node entre container et contenu animé.

### Input

Si tu déplaces visuellement un bouton (`offset_transform_position`), vérifie `offset_transform_visual_only` : décocher pour que les clics suivent le visuel.
