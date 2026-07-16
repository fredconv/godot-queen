# Audit pré-version 1.0 — Dame de Pique

**Date :** 2026-07-16  
**Branche :** `feat/simulation-batch`  
**Chemin :** `C:/Users/fredc/Projects/CreativeOS/projects/Games/DameDePique/`  
**Outils :** Godot MCP Pro (stats, complexité scènes, unused, cycles, signaux, perf éditeur) + lecture code + screenshots live  

---

## Synthèse exécutive

Le projet est **jouable bout-en-bout** (solo / hot seat / LAN), avec une architecture globalement saine (règles pures, `MatchManager` non-autoload, pas de cycles de scènes).  
Pour une **1.0 store-ready**, les priorités sont : bugs UI Configuration, pollution stats, clutter TopMenuBar, docs STATUS obsolètes, nettoyage assets/debug, et quelques gros scripts à découper.

| Indicateur MCP | Valeur | Lecture |
|----------------|--------|---------|
| Scripts `.gd` | 198 | ~17,6 k LOC |
| Scènes `.tscn` | 27 | OK |
| Autoloads | 13 (+3 MCP) | Réseau + services OK |
| Cycles scènes | **0** | ✅ |
| `table.tscn` | 206 nœuds, profondeur 8 | Dense mais gérable |
| `main_menu.tscn` | 209 nœuds, profondeur 7 | Overlays tous embarqués |
| Unused (scan MCP) | 170 | **Beaucoup de faux positifs** (cartes `load()` dynamique) |
| Perf éditeur | ~623 Mo RAM, **721 orphan nodes**, 23k nœuds | Session éditeur + MCP chargée |

---

## 1. Architecture générale

### Points forts
- Séparation `rules/` (pur) ↔ `match/` ↔ `ui/table/*` claire.
- Multijoueur : host autoritaire, `TableSeatDisplayMap`, snapshots, phases A–D documentées.
- Autoloads métier cohérents ; MCP isolé dans 3 autoloads addon.

### Faiblesses
- `main_menu.tscn` **embarque tous les overlays** (settings, scores, crédits, game mode, hot seat, multi, help) → scène lourde, duplication partielle avec les mêmes overlays sous `table.tscn` (`ScoresScreen`, `SettingsScreen`, `HelpScreen`).
- Scripts « god object » : `network_service.gd` (~470), `multiplayer_lobby_screen.gd` (~395), `player_seat.gd` (~383), `ai_telemetry_collector.gd` (~482).
- Docs `STATUS.md` / `PROJECT_STATUS.md` **en retard** (MCP absent, ENet « non implémenté » alors que phase C est livrée).

---

## 2. Scènes et hiérarchie

| Scène | Nœuds | Profondeur | Verdict |
|-------|-------|------------|---------|
| `table.tscn` | 206 | 8 | OK — CanvasLayers UI / HotSeat séparés |
| `main_menu.tscn` | 209 | 7 | Trop d’overlays enfants ; candidats à instanciation à la demande |
| `multiplayer_lobby_screen.tscn` | 48 | 6 | OK mais UX dense |
| `main.tscn` | — | — | **Orphelin** (main = `bootstrap.tscn`) |
| `pixel_button.tscn` / `dialog_template.tscn` | — | — | Templates non référencés (dead scenes) |
| `simulation/simulation_main.tscn` | — | — | Hors livrable — OK si exclu export |

**Signaux table (MCP `find_signal_connections`) :** TopMenuBar correctement câblé (9 `pressed` → handlers internes).  
**Signaux runtime (`table.gd`) :** menu / scores / tricks / new / help / settings / moon / dialogs / network — pattern clair.

---

## 3. Findings priorisés

### CRITIQUE — bloquant ou trompeur pour 1.0

#### C1 — Configuration : crash OptionButton (thème / langue)
**Preuve MCP :** debugger `settings_screen.gd:115` / `:126` — `Index p_which = 0 is out of bounds (item_count = 0)`.  
**Cause :** `_before_open()` appelle `_load_from_config()` **avant** `_refresh_locale()` qui peuplent les `OptionButton`.  
**Correction :**

```gdscript
func _before_open() -> void:
	_refresh_locale()       # build options d'abord
	_load_from_config()     # puis select
```

Ou protéger `_select_*` avec `if item_count == 0: return`.

#### C2 — Stats joueur polluées (~24k parties)
**Preuve live :** Scores → « Parties terminées : 23798 ».  
**Cause probable :** batch `simulation/` ou runs headless qui émettent `GameEvents.match_ended` alors que `StatsService` écoute en autoload.  
**Correction :**
- Ne pas connecter `StatsService` pendant simulation (flag `DebugService` / `OS.has_feature("dedicated_server")` / env).
- Ou reset stats + bouton « Réinitialiser » en Configuration.
- Documenter : stats = parties **UI humaines** uniquement.

#### C3 — Docs statut obsolètes (risque d’erreurs de reprise)
`STATUS.md` dit addon MCP absent ; `PROJECT_STATUS` dit ENet non implémenté.  
**Correction :** mettre à jour STATUS / PROJECT_STATUS / NEXT avant merge 1.0 (une passe doc).

---

### IMPORTANT — qualité 1.0 / UX store

#### I1 — Bouton « LUNE SOUPÇONNÉE » visible dès le début de manche — ✅ S1
**Preuve screenshot table :** panneau bas-droite dès « jouez le 2 de Trèfle ».  
`MoonSuspicionActionButton.reset_for_new_hand()` fait `show()` + `disabled = true` ; `is_moon_declarable` = vrai dès `PLAYING`.  
**Correction appliquée :** `should_show_button()` — visible seulement si `trick_number >= 3` ou `hearts_broken` ; `reset_for_new_hand()` masque.

#### I2 — TopMenuBar trop chargée — ✅ S1
Boutons : RÈGLES, SCORES, PLIS, NOUVEAU, MUSIQUE, SUIVANT, MENU (+ hamburger / settings).  
**Correction appliquée :** `BtnToggleMusic` / `BtnNextMusic` masqués ; audio dans Configuration.

#### I3 — Lobby multijoueur : contraste & double « Rejoindre » — ✅ S1
**Preuve screenshot :** liste « Parties trouvées » illisible ; deux actions Rejoindre (code + bouton principal).  
**Correction appliquée :** labels « Rejoindre par code » / « Rejoindre (IP) » ; contraste ItemList ; champs code/recherche masqués si registry online indisponible.

#### I4 — Overlays : fuite visuelle du menu derrière — ✅ S1
Settings/Help : boutons du menu encore visibles sous le modal.  
**Correction appliquée :** backdrop α 0,78 ; reset `bullet_time_dim` après handoff hot-seat.

#### I5 — Double titre menu — ✅ S1
Art splash « LA DAME DE PIQUE » + Label UI « Dame de pique ».  
**Correction appliquée :** `TitleLabel` masqué (branding splash seul).

#### I6 — Settings : ordre `_load` / `_build` + appel static — ✅ S0
Warning `STATIC_CALLED_ON_INSTANCE` sur `normalize_language()`.  
**Correction :** `ConfigService.normalize_language(...)` + fix C1.

#### I7 — Scènes / assets morts à exclure de l’export
- `main.tscn`, `pixel_button.tscn`, `dialog_template.tscn`
- `assets/sprites/ui/medieval/_debug_*.png`
- Packs UIBundleFree non utilisés (sauf slices réellement référencés)
- `reports/` (déjà gitignore — vérifier non inclus dans export)
- Cartes `*_alt.png`, jokers, `card_back_blue` (vrai unused ; le reste du deck est **faux positif** MCP car `CardTexturePaths.load()`)

**Correction :** dossier `assets/_archive/` ou filtre export ; ne pas supprimer le deck principal.

#### I8 — Warnings GDScript (debugger 37+)
Shadow : `player_profile.is_connected`, `rule_engine.can_lead_suit(hearts_broken)`, `nine_patch_button.size`, `ui_offset_anim.ease`.  
Unused params dans `ai_telemetry_collector`, `table_disconnect_flow`.  
**Correction :** renommer (`peer_connected`, `_hearts_broken`, `_size`, `_ease`) ; préfixer `_` les params unused. Passe « zero warning » avant 1.0.

---

### AMÉLIORATION — post-1.0 ou polish

#### A1 — Factoriser gros scripts
| Fichier | LOC | Proposition |
|---------|-----|-------------|
| `network_service.gd` | ~470 | Extraire host/client session, disconnect, lobby peers |
| `multiplayer_lobby_screen.gd` | ~395 | Panels Join / Host / Advanced en sous-scripts |
| `player_seat.gd` | ~383 | Affichage main vs infos vs highlight |
| `ai_telemetry_collector.gd` | ~482 | Hors chemin critique UI — OK à laisser si simulation only |
| `match_manager.gd` | ~375 | Déjà découpé Trick/Score — OK |

#### A2 — Overlays à la demande
Instancier `SettingsScreen` / `HelpScreen` via `PackedScene` au `open()` au lieu de les garder dans `main_menu` **et** `table`.  
Réduit nœuds et risque de double état.

#### A3 — Terminologie i18n
« Hot seat » en FR → « Partage d’appareil » / « À tour de rôle » (garder Hot seat en EN).

#### A4 — Responsive / mobile (ROADMAP étape 8)
Viewport 1280×720 fixe ; tester safe area Android ; TopMenuBar déjà hauteur 56 (OK).

#### A5 — Audio polish
Scan MCP liste WAV/MP3 « unused » — vérifier `AudioService` charge dynamique ; finir volumes/transitions (ROADMAP).

#### A6 — Perf runtime
Mesurer **en play** (`get_performance_monitors`) : orphelins 721 = surtout **éditeur**.  
En jeu : surveiller instanciation `CardView` / tweens ; pool éventuel.

#### A7 — Tests UI MCP
Ajouter recettes skill `dame-de-pique-mcp-playtest` : settings open sans erreur OptionButton ; scores non aberrants ; moon button policy.

---

## 4. Références fragiles (`@onready` / NodePath)

- Pattern dominant : `@onready var x = $Path/...` — **bon** si scènes stables.
- Zones sensibles : `multiplayer_lobby_screen.gd` (nombreux champs), `table.gd` (26 refs), `player_seat.gd` (9).
- Pas de `get_node("chemin dynamique")` massif observé hors MCP audit scripts.
- **Risque :** duplication overlays menu/table — un rename de nœud casse deux scènes.

**Correction :** unique scene pack `res://scenes/menus/overlays/*.tscn` partagé ; unique script.

---

## 5. Conventions GDScript / nommage

| OK | À corriger |
|----|------------|
| `class_name`, snake_case fichiers | Shadow `is_connected` vs `Object.is_connected` |
| Pas de `print()` jeu (DebugService) | Paramètres shadow (`hearts_broken`, `size`, `ease`) |
| ADR documentés | Docs STATUS pas à jour |

---

## 6. Plan de correction suggéré (ordre)

| Sprint | Items | Effort |
|--------|-------|--------|
| **S0 — Blockers** | C1 settings, C2 stats, C3 docs | ✅ fait 2026-07-16 |
| **S1 — UX table/menu** | I1 moon, I2 TopMenuBar, I4 overlay dim, I5 titre (+ I3 absorbé) | ✅ fait 2026-07-16 |
| **S2 — Multi lobby** | I3 contraste + labels | ✅ absorbé dans S1 |
| **S3 — Hygiene** | I7 archive assets, I8 zero-warnings | 1 j |
| **S4 — Soft** | A1–A7 selon capacité | post-1.0 OK |

---

## 7. Ce qui est déjà « 1.0 ready »

- Règles Hearts + tests GdUnit (base solide).
- Solo jouable + hints (« 2 de Trèfle »).
- Hot seat + overlay SPACE 1,5 s (validé MCP).
- Pas de dépendances circulaires scènes.
- Splash `accueil-bg.png` cohérent avec direction artistique.
- Architecture multi documentée (ADR-024+).

---

## 8. Preuves MCP

Screenshots UX : `.mcp_audit/ux_01_*.png` … `ux_09_table_solo.png`  
Audit splash/hot-seat : `docs/MCP-AUDIT-SPLASH-HOTSEAT-2026-07-16.md`  
Exploitation MCP : `docs/GODOT-MCP-PRO-EXPLOITATION.md`

---

*Prochaine étape recommandée après validation de ce rapport : sprint S0 (C1+C2+C3), puis phase roadmap suivante (polish audio / export).*
