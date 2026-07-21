# Polish visuel natif Godot — plan & audit

```
Version : V01
Created : 2026-07-21
Status : IN_PROGRESS / LOTS L1–L9 livrés — IDEA-00021
Linked : docs/00_INBOX/INBOX.md · docs/QUALITY-AUDIT.md · Packs A–C déjà livrés
```

**Contrainte absolue :** aucun PNG/sprite/texture externe. Theme, StyleBoxFlat, Tween, shaders légers, `_draw`, particules sans texture.

**Identité :** cartes pixel-art sombre/chaleureux — anthracite, vert tapis, brun bois, or sombre, jaune accents, rouge sombre (danger), blanc cassé (texte). Nearest filter. Pas néon / soft UI / flou.

---

## 0. Déjà livré (ne pas refaire)

| Pack | Contenu | Fichiers clés |
|------|---------|---------------|
| A | Modales fade/scale open-close | `modal_overlay_screen.gd`, `UiOffsetAnim` |
| B | NinePatchButton hover/focus ; top bar pixel | `nine_patch_button.gd`, `top_menu_bar.gd` |
| C | Factory StyleBox banners/overlays coins 0 ; score pop | `ui_style_factory.gd`, banners table, `player_seat` |
| 00009 | Split NetworkService | hors scope visuel |
| **00021 L1–L9** | Theme catalog + polish écrans | `ui_theme_catalog.gd`, menus, HUD, cartes, `PixelNotification`, vignette |

**IDEA-00021** = **système Theme centralisé + polish restant** (menu panneau boutons, config sections, HUD, cartes, notifications, ambiance) — au-delà des Packs A–C.

---

## Livraison 2026-07-21 (lots)

| Lot | Statut | Preuve |
|-----|--------|--------|
| L1 Theme | ✅ | `UiThemeCatalog` + tests GdUnit 4/4 |
| L2 Boutons/variations | ✅ | variations Theme + SmallHud sur top bar |
| L3 Menu | ✅ | `ButtonStackPanel` + vignette |
| L4 Mode/Config | ✅ | descriptions + sections i18n |
| L5 HUD | ✅ | séparateurs + pulse tour |
| L6 Scores | ✅ | barres animées + séparateurs |
| L7 Cartes | ✅ | ombre lift-only en main (pas de step éventail), rim, shake, land flash |
| L8 Notifs | ✅ | `PixelNotification` + hand start |
| L9 Ambiance | ✅ | `ui_vignette.gdshader` (comment `//` only) |

**Gate MCP :** `reload_project` → play `main_menu` → vignette material OK → settings sections OK → `get_editor_errors` = 0.

---

## 1. Audit visuel (Étape 1) — inventaire écrans

### 1.1 Menu principal — `main_menu.tscn`

| Constat | Détail |
|---------|--------|
| Hiérarchie | Boutons NinePatch OK ; peu de séparation vs illustration splash |
| Espace | Colonne centrée ; fond personnage peut concurrencer le texte |
| Platitude | Pas de panneau sombre semi-transparent derrière la colonne |
| Feedback | Hover Pack B OK ; sélection clavier à renforcer |
| Uniformité | NinePatch ≠ Theme Button (volontaire) |

**Opportunités 00021 :** panneau sombre transparent derrière stack ; espacement 8px ; focus contour or ; ne pas masquer le personnage central.

### 1.2 Mode de jeu — `game_mode_screen.tscn`

| Constat | Détail |
|---------|--------|
| Vide | Panel large, options peu densifiées |
| Titre | Peu séparé du contenu |
| Retour | Pas de séparateur avant Retour |
| Descriptions | Absentes sous Solo / Hot seat / En ligne |

**Opportunités :** titres + short descriptions i18n ; spacer avant Retour ; disabled clair (modes futurs).

### 1.3 Configuration — `settings_screen.tscn`

| Constat | Détail |
|---------|--------|
| Sections | Flat list (SFX, musique, langue…) — pas de groupes Audio / Affichage / Profil / Données |
| Alignement | Labels largeurs variables |
| Contrôles | Theme HSlider/OptionButton basiques ; pas de « PixelSlider » dédié |

**Opportunités :** sections + `theme_type_variation` ; largeurs fixes grille 8 ; toggle musique cohérent.

### 1.4 Règles / Scores / Crédits — overlays

| Constat | Détail |
|---------|--------|
| Style | Pack C overlay StyleBox appliqué au Panel |
| Contenu | Scores : liste simple, peu de hiérarchie joueur local |
| Marges | À harmoniser (content_margin factory) |

### 1.5 HUD table — `top_menu_bar.tscn` + sièges

| Constat | Détail |
|---------|--------|
| Barre | Pack B StyleBoxFlat coins 0 — OK base |
| Tour / score | Ombres labels OK ; peu de feedback « à vous » |
| Séparateurs | Absents gauche/centre/droite |
| Score pop | Pack C sur `PlayerSeat` — OK |

**Opportunités :** séparateurs 1–2px or ; anim courte « À vous de jouer » ; bordure bas barre.

### 1.6 Tableau de score (scores overlay + match scoreboard)

| Constat | Détail |
|---------|--------|
| Lignes | Peu séparées |
| Humain | Pas de highlight dédié |
| Barres | `score_bar_row` — à vérifier anim progression |

### 1.7 Zone pli / main joueur

| Constat | Détail |
|---------|--------|
| Cartes | Sprites inchangés (contrainte) |
| Hover | `card_view` lift existant |
| Jouables | Feedback perfectible (atténuer invalides, shake court invalide) |
| Pose | Tweens `table_animations` OK ; ombre carte absente (via modulate/duplicate Control, pas texture) |
| Emplacements | Zones centrales peu matérialisées |

### 1.8 Notifications

| Constat | Détail |
|---------|--------|
| Bannières | hand_start / AI / lead-suit / moon — styles Pack C unifiés |
| Composant | Pas de `NotificationPanel` unique typé (couleur demandée, cœurs brisés, pli…) |

**Opportunités :** un composant + enum type ; position fixe non bloquante.

### 1.9 Boutons secondaires / Theme

| Constat | Détail |
|---------|--------|
| `pixel_theme.tres` | Button/Panel/Slider/LineEdit — **pas** de `theme_type_variation` (Primary/Secondary/Danger/SmallHud) |
| Double pipeline | NinePatch menus vs Theme HUD |

---

## 2. Direction artistique (rappel)

| Token | Usage |
|-------|--------|
| Anthracite / noir | Fonds panneaux |
| Vert tapis | Table (existant) |
| Brun bois | Accents (NinePatch existant) |
| Or sombre / jaune | Bordures, focus, accents |
| Rouge sombre | Danger / quitter |
| Blanc cassé (`UiPalette.CREAM`) | Texte |

Pixel : nearest, offsets entiers, bordures 1–4 px, scale hover ≤ ~1.05, pas de blur.

---

## 3. Plan d’implémentation (lots)

| Lot | Contenu | Fichiers / scènes | Bénéfice | Risque | Rollback |
|-----|---------|-------------------|----------|--------|----------|
| **L0** | Audit figé (ce doc) | `docs/ui/VISUAL_POLISH_NATIVE_PLAN.md` | Scope clair | Nul | — |
| **L1** | Theme central + type variations | `resources/themes/pixel_theme.tres`, `UiPalette`, éventuellement `ui_theme_catalog.gd` | Uniformité | Moyen (HUD/menus) | Restaurer `.tres` git |
| **L2** | Primary/Secondary/Danger/SmallHud + panels | Theme + `NinePatchButton` bridge | Boutons premium | Moyen | Feature flag / revert theme |
| **L3** | Menu principal panneau colonne | `main_menu.tscn/.gd` | Lisibilité vs splash | Faible | Retirer ColorRect/panel |
| **L4** | Mode + Config sections | `game_mode_screen`, `settings_screen` | Aération | Faible | Revert scènes |
| **L5** | HUD + « à vous » | `top_menu_bar`, table turn banner | Feedback tour | Faible | Retirer tween |
| **L6** | Scores highlight + barres | `scores_screen`, `match_scoreboard`, `score_bar_row` | Lisibilité | Faible | — |
| **L7** | Cartes feedback (sans sprites) | `card_view`, `table_animations`, play flow | Feel | Moyen (input) | Gardes `_turn_locked` |
| **L8** | NotificationPanel unifié | nouveau composant + migration banners | DRY | Moyen | Garder banners legacy |
| **L9** | Ambiance (vignette/gradient léger) | ColorRect + shader Compatibility | Profondeur | Moyen (GL Compat) | Désactiver nœud |

**Ordre imposé :** L0 → L1 → L2 → … ; MCP gate après chaque lot (`reload_project`, play, erreurs, pas de nouveaux assets).

---

## 4. Theme — variations cibles (Étape 2)

À ajouter dans `pixel_theme.tres` (ou Theme dérivé) :

`PrimaryButton` · `SecondaryButton` · `DangerButton` · `SmallHudButton` · `PixelPanel` · `ModalPanel` · `SectionPanel` · `TitleLabel` · `SectionTitle` · `BodyLabel` · `MutedLabel` · `PixelLineEdit` · `PixelOptionButton` · `PixelSlider` · `PixelToggle` · `ScorePanel` · `NotificationPanel`

Mapping actuel :

| Variation | Base aujourd’hui |
|-----------|------------------|
| Primary | `NinePatchButton` + fill opaque |
| SmallHud | `top_menu_bar` StyleBoxFlat |
| ModalPanel | `UiStyleFactory.pixel_overlay_panel_style` |
| NotificationPanel | banners Pack C |

---

## 5. Hors scope / interdits

- Modifier règles Hearts / IA / équilibrage
- Nouveaux fichiers image
- Bloom / blur fort / scale élastique
- Refactor réseau (déjà 00009)
- Masquer davantage le personnage du splash

---

## 6. Next action

1. Utilisateur : `implémente: IDEA-00021` ou `implémente: Lot L1` (Theme).
2. Agent : ne pas coder tant que non demandé (rule idée-capture).
3. Après L1 : valider MCP + souris/clavier + 1280×720.

---

## 7. Lien Packs A–C

Les Packs A–C sont des **fondations**. IDEA-00021 les **étend** (Theme type variations, menu panneau, config sections, cartes, notifications unifiées, ambiance) sans les annuler.
