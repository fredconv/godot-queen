# QUALITY-AUDIT — Dame de Pique

```
Version : V01
Created : 2026-07-21
Type : Audit complet + plan d'amélioration + polish (sans assets externes)
Godot : 4.7-stable · Renderer : gl_compatibility
Verdict global : JAUNE / VERT — base saine, polish UI & découpe réseau à gagner
```

**Objectif :** qualité / maintenabilité / polish **premium pixel-art** — **pas** de nouvelles features gameplay.

**Sources croisées :** inventaire MCP (`get_project_statistics`), exploration `scripts/`+`scenes/`, [`AUDIT-PRE-1.0.md`](AUDIT-PRE-1.0.md), [`AUDIT_CONFORMITE_optimisation_DDP.md`](AUDIT_CONFORMITE_optimisation_DDP.md), skills `godot-pixel-ui-button` / `godot-performance-dame-de-pique` / `godot-pre-release-audit`.

**Backlog opérationnel :** [`00_INBOX/INBOX.md`](00_INBOX/INBOX.md) (IDEA-00001…).

---

## 1. Synthèse exécutive

| Axe | Score /10 | Commentaire |
|-----|----------:|-------------|
| Architecture | 8.5 | Séparation rules / match / UI exemplaire ; MatchManager non-autoload |
| Qualité code | 8.5 | 0 `print`, 0 TODO, typage fort ; hotspots taille réseau/lobby |
| Modularité | 8 | Table déjà découpée ; network_service + lobby encore denses |
| Godot 4.x | 8 | Scene-first, Theme, Tween, offset_transform 4.7 ; pas de shader UI |
| Robustesse | 8 | `_turn_locked`, validation avant mutation ; tweens UI à durcir |
| UX / polish visuel | 6.5 | Bonne base ; modales sans entrée ; top bar ≠ boutons menu |
| Docs / gouvernance | 7 → **9** | ADR riches ; **inbox/backlog manquait** → créé ce jour |

**Verdict :** le projet est **déjà plus discipliné** que beaucoup de prototypes Godot (tests, i18n 6 langues, ADR). Le levier 1.0 « premium » est surtout **cohérence visuelle + micro-animations** (sans toucher règles/IA), puis **découpe réseau** post-1.0.

---

## 2. Inventaire

| Métrique | Valeur |
|----------|--------|
| Scripts `.gd` (hors addons stats MCP) | 198 |
| Lignes scripts (MCP, hors addons) | ~17 822 |
| Scènes live | ~24–29 |
| Ressources `.tres` | 2 (`pixel_theme` + …) |
| Autoloads produit | 10 (+ 3 MCP) |
| Suites tests | ~42 (GdUnit4) |

### Autoloads (produit)

Services transverses OK : `GameEvents`, `Save/Config/Audio/Debug/Stats/PlayerProfile`, `GameSession` (léger).

À surveiller :
- `NetworkService` — transport + lobby + seats + discovery (588 L) — **split candidat**
- `NetworkMatchRelay` — autoload tenant refs table/host pendant match — couplage assumé multi

`MatchManager` : **correctement hors autoload**.

---

## 3. Architecture

### Points forts

- `scripts/rules/` purs (`RefCounted`) vs `scripts/match/` vs `scripts/ui/`
- Table = assembleur mince (`table.gd` ~192 L) + modules `scripts/ui/table/*`
- Signaux via `GameEvents` ; résultats typés (`PlayResult`, etc.)
- Conformité optimisation GD ~95 % (audit 2026-07-20)

### Dettes / opportunités

| ID | Constat | Fichiers | Priorité |
|----|---------|----------|----------|
| A1 | God-ish network | `network_service.gd` (588) | Moyenne (post-1.0) |
| A2 | Lobby UI multi-modes | `multiplayer_lobby_screen.gd` (525) | Moyenne |
| A3 | Seat layout dense | `player_seat.gd` (432) | Faible–Moyenne |
| A4 | Skill bouton obsolète | skill pointe `pixel_button.tscn` archivé ; live = `NinePatchButton` | **Haute (doc)** |
| A5 | Doublon `dialog_template.tscn` live + archive | `scenes/menus/` | **Haute (hygiene)** |
| A6 | Overlays show/hide brut | `modal_overlay_screen.gd` | Haute (polish) |
| A7 | Top bar StyleBoxFlat ≠ NinePatch menu | `top_menu_bar.tscn` | Haute (polish) |

### Scènes

Densité OK (pas de monolithe 1000+ nœuds). `table.tscn` / `main_menu.tscn` / lobby = plus denses — acceptables.

---

## 4. Qualité du code

| Check | Résultat |
|-------|----------|
| `print(` | **0** (DebugService OK) |
| TODO/FIXME/HACK | **0** |
| `_physics_process` | **0** |
| `_process` | 2 (network **gaté** ; hot-seat early-return — à `set_process(false)`) |
| `preload` / `load` | 26 / 11 — `load` = assets dynamiques (OK) |
| Duplication | StyleBoxFlat backdrop × overlays ; banners table couleurs ad hoc |
| Code mort | `PixelButton` script vivant / scène archivée ; `dialog_template` live orphelin |

---

## 5. Modularité & couplage

- UI table **découplée** de `RuleEngine` (consomme résultats) — bon
- Lobbie/network encore **UI + transport** mélangés dans de gros fichiers
- Composants réutilisables existants : `NinePatchButton`, `NinePatchPanel`, `UiOffsetAnim`, `UiPalette`, `ModalOverlayScreen`
- Manque : panneau modal partagé animé ; factory StyleBox banners

---

## 6. Bonnes pratiques Godot

| Pratique | État |
|----------|------|
| Signals / bus | ✅ |
| Resources / Theme | ✅ 1 thème ; peu de `.tres` data |
| Composition scènes | ✅ |
| Typed GDScript | ✅ |
| `@export` bornés | ⚠️ quelques numériques libres |
| AnimationPlayer | ❌ inutilisé — tout Tween (OK) |
| Shaders UI | ❌ aucun — levier polish |
| Groups | peu utilisés (opportunité faible) |

---

## 7. Robustesse

- Risque LOW : tweens carte non `kill()` sur retarget (`table_animations`) — atténué par `_turn_locked`
- `get_node("/root/…")` rare (autoload circular) — acceptable
- Pas de null-spam TLD-style

---

## 8. UX / polish (état)

| Zone | État actuel | Écart « premium » |
|------|-------------|-------------------|
| Menu principal | Stagger `UiOffsetAnim` OK | Boutons hover = modulate seulement |
| Overlays (settings/help/scores…) | `show()`/`hide()` | Pas de fade/scale |
| MatchEndDialog | Tween scale+fade | Référence à généraliser |
| HandEnd / Confirm | Instantané | Alignement MatchEnd |
| Top menu bar | Boutons thème plats | Incohérent vs menu NinePatch |
| Table | Anims riches (deal, QS, petals) | Sobriété déjà bonne ; micro polish OK |
| Textes | Press Start 2P | Hiérarchie / ombres perfectibles |

**Identité à préserver :** taverne, feutre vert, or, Nearest, pas néon/blur fort.

---

## 9. Plan d’amélioration priorisé

Légende : **P** = priorité · **D** = difficulté (S/M/L) · **B** = bénéfice · **R** = risque

### Priorité Haute — gains élevés, risque faible

| IDEA | Amélioration | P | D | B | R | Fichiers |
|------|--------------|---|---|---|---|----------|
| 00001 | Gouvernance inbox/backlog/index | Haute | S | Pilotage | Nul | `docs/00_INBOX/*`, WORKFLOW |
| 00002 | Corriger skill + Components (NinePatch live) | Haute | S | Agents futurs | Nul | skill, `ui/Components.md` |
| 00003 | Retirer `dialog_template` live orphelin | Haute | S | Hygiene | Nul | `scenes/menus/dialog_template.tscn` |
| 00004 | `set_process(false)` hot-seat overlay | Haute | S | Perf micro | Nul | `hot_seat_privacy_overlay.gd` |
| 00005 | Anim open/close `ModalOverlayScreen` via `UiOffsetAnim` | Haute | S | Premium menus | Faible | `modal_overlay_screen.gd` |
| 00006 | Même entrée pour HandEnd + Confirm | Haute | S | Cohérence | Faible | `hand_end_dialog.gd`, `confirm_dialog.gd` |
| 00007 | Harmoniser top bar (StyleBox/thème or pixel) | Haute | M | Cohérence HUD | Moyen | `top_menu_bar.*`, `pixel_theme.tres` |
| 00008 | Hover/focus NinePatchButton (scale ≤1.05 + contrast) | Haute | S | Feel boutons | Faible | `nine_patch_button.gd` |

### Priorité Moyenne — structure

| IDEA | Amélioration | D | Notes |
|------|--------------|---|-------|
| 00009 | Factoriser `network_service` (transport / lobby / discovery) | L | Différé A1 audit pré-1.0 — **proposer avant** |
| 00010 | Découper `multiplayer_lobby_screen` par mode | M | UI only |
| 00011 | Factory StyleBox banners table | S | DRY couleurs |
| 00012 | Corner radius 0 / borders pixel sur overlays | S | Identité pixel |
| 00013 | `@export_range` bornes numériques | S | Conformité GD-VALIDATION-001 |
| 00014 | kill() tweens carte sur retarget | S | LIFECYCLE-001 |

### Priorité Faible — polish / later

| IDEA | Amélioration |
|------|--------------|
| 00015 | Vignette shader ColorRect (menu/dim) — tester GL Compatibility |
| 00016 | Score pop modulation discrète |
| 00017 | Extraire helpers layout `player_seat` |
| 00018 | Fusion doc PixelButton vs NinePatch (déprécier script mort) |
| 00019 | Mobile / safe area (ROADMAP 8 / A4) |
| 00020 | Particles discrètes (moon / last trick) — sobriété |

---

## 10. Implémentation — règles de session

### Fait dans cette session (SAFE)

- Création gouvernance docs (INBOX, KANBAN, BACKLOG, WORKFLOW, INDEX, cet audit)
- IDEA-00002 / 00003 / 00004 (hygiene + skill + process)

### **À valider avant code** (proposé)

1. **Pack Polish Modales** — IDEA-00005 + 00006  
2. **Pack Boutons Premium** — IDEA-00007 + 00008  
3. **Pack Table sobre** — 00011 + 00012 + 00016 (après packs 1–2)

### Interdit sans OK explicite

- Règles Hearts, IA, Lune, équilibrage
- Refactor réseau large (00009)
- Nouveaux assets graphiques externes
- Glow/blur agressif

---

## 11. Proposition visuelle (avant implémentation)

### Pack A — Modales (recommandé en premier)

- `ModalOverlayScreen.open()` : fade backdrop + `UiOffsetAnim` scale panel 0→1 (TRANS_BACK, ~0.18s)
- `close()` : reverse court (~0.12s) puis `hide` + `closed`
- Bloquer Échap pendant tween sortie
- Répliquer pattern MatchEnd sur HandEnd / Confirm

### Pack B — Boutons

- `NinePatchButton` : hover scale 1.04 + modulate légèrement plus clair ; pressed scale 0.97 ; focus bordure or via modulate/corner
- Top bar : renforcer StyleBoxFlat thème (bordure 2px or, coins 0) plutôt que migration NinePatch 48px (trop haute)

### Pack C — Écrans

Parcours menu / mode / lobby / settings / help / scores : aérer marges (multiples de 8), unifier backdrop α, titres hiérarchie (taille + ombre douce Label).

### Pack D — Table

Garder anims existantes ; ajouter uniquement : entrée banners scale légère ; flash score or discret ; pas de particles par pli.

---

## 12. Skills / rules utilisés pour cet audit

| Artefact | Usage |
|----------|--------|
| `AGENTS.md` | Routage |
| `godot-pre-release-audit` | Grille livrable |
| `godot-pixel-ui-button` | Écart skill ↔ réalité |
| `godot-performance-dame-de-pique` | Pas d’optim prématurée |
| MCP Godot Pro | Stats projet |
| Subagents explore | Hotspots code + UI |
| Patterns TLD `docs/00_INBOX` | Gouvernance adaptée |

---

## 13. Prochaine action utilisateur

Répondre par un choix :

1. **`implémente: Pack A`** (modales)  
2. **`implémente: Pack B`** (boutons)  
3. **`implémente: Pack A+B`**  
4. **Priorise seulement** — rester en backlog  
5. **Autre** (ex. A1 réseau)

Sans réponse : aucun polish gameplay/UI code au-delà de l’hygiene déjà faite.
