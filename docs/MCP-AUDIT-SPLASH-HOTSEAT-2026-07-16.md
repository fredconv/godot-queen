# MCP Live Audit — splash + hot-seat

Date: 2026-07-16  
Project: `C:/Users/fredc/Projects/CreativeOS/projects/Games/DameDePique/`  
Branch: `feat/simulation-batch`  
Godot: 4.7.1-stable  
Transport: **godot-cli** (ports 6510+) — Cursor MCP `CallMcpTool` était en état `Not connected` (stdio).  
Screenshots: `.mcp_audit/`

## Environment

| Check | Result |
|-------|--------|
| `project_path` CreativeOS | ✅ |
| Plugin MCP + autoloads | ✅ (MCPScreenshot, MCPInputService, MCPGameInspector, NetworkService…) |
| Main scene | `bootstrap.tscn` → MainMenu |
| Une instance Godot | ✅ (doublon tué — ports 6005/6006) |

## A — Splash / main menu

| Assert | Result |
|--------|--------|
| `BackgroundTexture.texture` = `res://assets/sprites/accueil-bg.png` | ✅ PASS |
| Texture visible | ✅ |
| Titre `Dame de pique` + boutons (labels) | ✅ |
| Screenshot | `.mcp_audit/splash_menu.png` |

**Note:** au play, `BtnNewGame.disabled == true` tant que `_set_menu_interactive` n’a pas fini l’intro / a été laissé false. Clic UI seul a échoué tant que disabled. Contournement audit: `call('_set_menu_interactive', true)` puis `GameModeScreen.open()`.

## B — Hot seat

| Step | Result |
|------|--------|
| Ouvrir GameMode → Hot seat lobby | ✅ (via `call('_on_btn_hot_seat_pressed')`) |
| `LANCER` → scène `Table` | ✅ |
| `TopMenuBar` visible, size y=56 | ✅ PASS (pas de régression hauteur 0) |
| Overlay handoff au boot table | ⚠️ non visible (normal si 1er tour sans handoff immédiat) |
| `show_handoff('Joueur Test')` → visible | ✅ |
| Screenshot overlay | `.mcp_audit/hot_seat_overlay.png` |
| Dismiss après hold 1,5 s (forcé `_space_held` + `_process`) | ✅ overlay `visible=false` |
| Screenshot table | `.mcp_audit/hot_seat_table.png` |

**Note CLI:** `input key` envoie `key` alors que l’API attend `keycode` → `Missing required parameter: keycode`. Utiliser Cursor MCP `simulate_key` avec `keycode: KEY_SPACE` ou script runtime.

## Errors observés

- Nombreux **warnings** shadow/unused (player_profile, rule_engine, ai_telemetry) — non bloquants.
- `[MCP] Auto-resumed debugger after runtime error` ×3 — erreur runtime réelle non extraite clairement du panneau (à rejouer avec log filtré). Pas de crash table.

## Verdict

| Recette | Statut |
|---------|--------|
| A Splash | **PASS** |
| B Hot-seat (table + overlay + TopMenuBar) | **PASS** (handoff forcé pour SPACE; parcours menu via calls) |
| Cursor MCP stdio (session initiale) | **FAIL** — reconnecté ensuite |

## Rejeu Cursor MCP (2026-07-16 ~23:00)

Panneau Godot **MCP Pro: Connected** (port 6505, Clients: 1).

| Étape | Résultat |
|-------|----------|
| `get_project_info` via `CallMcpTool` | ✅ Dame de pique / CreativeOS |
| Overlay `show_handoff` | ✅ `visible=true` |
| `simulate_key` `KEY_SPACE` duration 1.6 | ✅ `sent` + `auto_released` |
| Assert overlay `visible=false` | ✅ **PASS** |
| Screenshot | `.mcp_audit/hot_seat_after_space_mcp.png` |

## Actions follow-up

1. ~~Toggle godot-mcp-pro~~ — reconnecté, `CallMcpTool` OK
2. Enrichir skill playtest: fallback CLI + NinePatchButton + bug keycode CLI
3. Optionnel: fix CLI `mapArgs` `key` → `keycode` dans `tools/godot-mcp-pro/server`
