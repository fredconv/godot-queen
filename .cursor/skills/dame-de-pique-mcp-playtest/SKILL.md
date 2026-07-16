---
name: dame-de-pique-mcp-playtest
description: >-
  Playtests MCP Dame de Pique : splash accueil, hot seat handoff, lobby, table.
  Charger avant audit live UI/runtime via Godot MCP Pro (play_scene, screenshots,
  simulate_key, click_button_by_text).
---

# Dame de pique — MCP playtest

Complète `dame-de-pique-multiplayer` (règles ADR) et `godot-mcp` (setup addon).  
Référence produit : `docs/GODOT-MCP-PRO-EXPLOITATION.md`.

## Prérequis session

1. Branche : `main` (historique pre-1.0 aussi sur `feat/simulation-batch`)
2. Chemin Godot : `C:\Users\fredc\Projects\CreativeOS\projects\Games\DameDePique`
3. **Une seule** instance éditeur Godot (ports 6005/6006 + MCP 6505–6509)
4. Plugin **Godot MCP Pro** activé ; panneau MCP Pro = client connecté
5. Vérifier : `get_project_info` → projet Dame de Pique / Hearts

Si MCP « editor not connected » / `Not connected` :

1. Une seule instance Godot sur ce chemin (tuer les doublons — ports 6005/6006).
2. Toggle **godot-mcp-pro** dans Cursor Settings → MCP, ou restart Cursor.
3. **Fallback audit** (WebSocket CLI, ports 6510–6514) :

```powershell
$cli = "C:\Users\fredc\Projects\CreativeOS\tools\godot-mcp-pro\server\build\cli.js"
node $cli project info
node $cli scene play --mode main
node $cli runtime get --node_path /root/MainMenu/BackgroundTexture --properties texture,visible
node $cli editor screenshot   # décoder image_base64 → .mcp_audit/*.png
```

Pièges connus :

- Boutons menu = **NinePatchButton** (≠ `Button`) : `runtime ui --type_filter Button` les rate ; chercher le **Label** enfant (`NOUVELLE PARTIE`) ou `call('_on_btn_…')`.
- CLI `input key` envoie `key` au lieu de `keycode` → erreur Godot. Préférer MCP `simulate_key` (`keycode: KEY_SPACE`, `duration: 1.6`) ou forcer l’overlay via `runtime exec` + `_mcp_print`.
- Après intro, si `BtnNewGame.disabled` : `call('_set_menu_interactive', true)` avant clic.
- `find_unused_resources` : deck / audio / slices UI = **faux positifs** (load dynamique) — ne pas archiver ; voir `assets/_archive/README.md`.
- Scripts MCP / autoloads précoces : préférer `preload("…/stats_store.gd")` si `StatsStore` (`class_name`) n’est pas encore résolu.
- Batch simulation : `MatchManager.emit_game_events = false` sinon StatsService pollue l’écran SCORES.

## Textes UI (locale FR par défaut)

| Écran | Texte bouton / label |
|-------|----------------------|
| Main menu | `NOUVELLE PARTIE`, `RÈGLES`, `SCORES`, … |
| Mode | `Solo`, `Partage d'appareil` (EN: `Hot seat`), `En ligne` |
| Lobby hot seat | `LANCER` |
| Overlay handoff | maintien `KEY_SPACE` **1,5 s** (`HotSeatPrivacyOverlay.HOLD_DURATION_SEC`) |
| Configuration | `CONFIGURATION` / overlay Settings (lazy A2) |
| Stats | `SCORES` → overlay Stats |

## Recette A — Splash / main menu

1. `stop_scene` si déjà en play
2. `play_scene` mode `main` (`bootstrap.tscn` → menu)
3. Attendre ~3 s (intro BG 2,4 s + fade)
4. `get_game_screenshot` → `res://.mcp_audit/splash_menu.png`
5. `get_node_properties` sur `BackgroundTexture` (ou chemin runtime via `get_game_scene_tree`)
6. Assert : texture pointe vers `accueil-bg.png` (ou propriété `texture` non vide)
7. `find_ui_elements` type Button — présence `NOUVELLE PARTIE`
8. `get_output_log` / `get_editor_errors` — pas d’erreur bloquante

**Pass si :** fond splash visible, menu interactif, pas d’erreur critique.

## Recette B — Hot seat (lobby → table → overlay)

1. Depuis menu (après A) : `click_button_by_text` `NOUVELLE PARTIE`
2. `click_button_by_text` `Partage d'appareil` (locale FR ; EN: `Hot seat`)
3. Optionnel : régler nombre de joueurs UI si besoin (défaut OK)
4. `click_button_by_text` `LANCER`
5. Attendre chargement table (~1–2 s)
6. `get_game_scene_tree` filtre `HotSeat` / `player_seat`
7. Si overlay visible : `assert_node_state` overlay `visible` = true
8. `get_game_screenshot` → `res://.mcp_audit/hot_seat_table.png`
9. Handoff : `simulate_key` `KEY_SPACE` `duration` **1.6**
10. Screenshot after → overlay fermé, main révélée (siège bas)
11. `get_output_log` — pas de `previously freed` / NetworkService crash

**Pass si :** table chargée, rotation/`TableSeatDisplayMap` cohérente (humain actif en bas), overlay handoff OK, SPACE 1,5 s ferme l’overlay.

## Recette C — Smoke TopMenuBar (régression export)

En play sur table : propriétés `TopMenuBar` / hauteur `size.y` > 0.  
Assert : pas de boutons MUSIQUE / SUIVANT visibles (I2 — audio dans Configuration).

## Recette D — Configuration OptionButton (C1 / A7)

1. Menu principal interactif (après A)
2. `click_button_by_text` `CONFIGURATION` (ou `call('_on_btn_settings_pressed')`)
3. Attendre 0,3 s — SettingsScreen lazy-instancié (A2)
4. `get_output_log` / debugger : **aucune** erreur `item_count = 0` / OptionButton
5. `get_game_screenshot` → `res://.mcp_audit/settings_open.png`
6. Fermer (RETOUR / Échap)

**Pass si :** overlay ouvert, thèmes/langues peuplés, pas d’erreur OptionButton.

## Recette E — Scores non aberrants (C2 / A7)

1. Menu : `click_button_by_text` `SCORES`
2. Lire le label « Parties terminées : N »
3. Assert : N raisonnable pour un joueur humain (pas des dizaines de milliers post-reset)
4. Si N aberrant : Configuration → `RÉINITIALISER STATS`, re-vérifier
5. Screenshot → `res://.mcp_audit/scores_stats.png`

**Pass si :** compteur cohérent avec parties UI (simulation isolée via `emit_game_events = false`).

## Recette F — Bouton Lune soupçonnée (I1 / A7)

1. Solo → table (ou hot seat après handoff)
2. Début de manche (pli 1–2, Cœurs non défoncés) :
   - `MoonSuspicionButton.visible` = **false** (ou `should_show_button()` faux)
3. Après pli ≥ 3 **ou** Cœurs défoncés : bouton peut apparaître (disabled tant que non déclarable)
4. Screenshot early → `res://.mcp_audit/moon_hidden_early.png`

**Pass si :** pas de panneau « LUNE SOUPÇONNÉE » dès le premier pli.

## Rapport obligatoire

```
MCP Playtest — [A splash | B hot-seat | C bar | D settings | E scores | F moon]
- project_path: …
- branch attendue: main
- connected: oui/non
- résultats: PASS/FAIL par assert
- screenshots: chemins res://.mcp_audit/…
- errors: extrait log
- next: …
```

## Limites

- Un seul runtime : pas de host+client LAN simultanés via MCP
- Règles Hearts / scoring → GdUnit (`tests/unit`), pas MCP
- Ne pas committer `.mcp_audit/*.png` sauf demande explicite

## Après fix UI/table

Appliquer la rule `dame-de-pique-mcp-loop` : rejouer la recette touchée avant de déclarer OK.
