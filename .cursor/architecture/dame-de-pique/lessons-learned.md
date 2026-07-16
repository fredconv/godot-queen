# Lessons learned — Dame de pique

Journal des erreurs rencontrées et **fixes validés**. Consulter **avant** de réinventer une solution.

Format : symptôme → cause → fix → fichiers / tests.

---

## Réseau — `Identifier not found: NetworkService` (compile)

**Symptôme** : `Compile Error: Identifier not found: NetworkService` dans `network_match_relay.gd` (ou autoload qui référence un autre autoload).

**Cause** : dépendance circulaire entre autoloads (`NetworkService` appelle `NetworkMatchRelay` et inversement). Godot ne résout pas l'identifiant global au parse.

**Fix** : dans **un** des deux scripts, ne plus utiliser l'identifiant global direct ; accès différé :

```gdscript
func _network() -> Node:
    return get_node("/root/NetworkService")
```

Puis `_network().is_host()` au lieu de `NetworkService.is_host()`.

**Fichiers** : `scripts/network/network_match_relay.gd`  
**Référence** : ADR-024, skill `dame-de-pique-multiplayer/reference.md` → Dépannage

---

## IA — `Assertion failed` dans `create_for_opponent_seat`

**Symptôme** : crash au démarrage de partie en ligne (ou après remplacement IA) : `ai_personality_catalog.gd:93` — `assert(opponent_seat_index >= 1 ...)`.

**Cause** : `SeatSetup.apply_ai_to_match_manager()` appelait `create_for_opponent_seat()` qui n'accepte que les sièges **1–3**. Le siège **0** peut être une IA (online, déconnexion, shuffle).

**Fix** : utiliser `AiPersonalityCatalog.create_for_seat(seat_index)` (sièges 0–3).

**Fichiers** : `scripts/network/seat_setup.gd`  
**Tests** : `test_seat_setup`, `test_ai_personalities`

---

## UI table — `_discard_banner` : previously freed

**Symptôme** : `Invalid type in function '_discard_banner'. The Object-derived class of argument 1 (previously freed) is not a subclass of the expected argument class.` (souvent `table_hand_start.gd` après timer ou sortie de scène).

**Cause** : la bannière est déjà `queue_free()` (ou détruite avec la scène) mais le code la repasse en paramètre **typé** `Control`.

**Fix** :

```gdscript
static func _discard_banner(banner: Variant) -> void:
    if banner is Control and is_instance_valid(banner):
        (banner as Control).queue_free()
```

Appliquer à tout helper `_discard_banner` (ex. `table_ai_announcement.gd`).

**Pattern global** : ne jamais typer strictement un nœud UI après un `await` sans `is_instance_valid`.

---

## Hot seat — IA ou main décalée en bas

**Symptôme** : le bas de table montre une IA, ou la rangée de dos de cartes est collée à gauche (siège ~124 px).

**Cause** :
1. Pivot `active_human_seat_index == -1` retombait sur siège logique 0 (parfois IA après shuffle).
2. Main cachée affichée dans `SeatBottom` (étroit) au lieu de `HumanHandArea` (pleine largeur).

**Fix** :
1. `TableSeatDisplayMap.get_pivot_seat()` → premier humain si non assigné ; bas = toujours humain (`show_hand_back = false` sur pivot).
2. `TableHumanHand.build_hidden_face_down()` pour la distribution / main cachée dans `HumanHandArea`.

**Fichiers** : `table_seat_display_map.gd`, `table_human_hand.gd`, `table_dealing.gd`  
**ADR** : ADR-026  
**Tests** : `test_table_seat_display_map`, `test_table_hot_seat`

---

## Hot seat — plis qui ne tournent pas / contexte perdu après handoff

**Symptôme** : les cartes du pli restent aux slots fixes (bas/gauche/…) après rotation ; après l'écran noir le centre est vide.

**Cause** :
1. Cartes du pli positionnées une fois à l'animation ; pas de resync quand le pivot change.
2. `resolve_trick_sequence` collectait le pli **avant** le handoff hot seat.

**Fix** :
1. `TableTrickDisplay.sync_card_positions(ctx)` après changement de pivot (`perform_handoff`).
2. Si `TableHotSeat.should_defer_trick_collection(ctx)` → reporter le ramassage ; après handoff, surbrillance vainqueur + `HANDOFF_TRICK_VISIBLE_DURATION_SEC` puis collecte.

**Fichiers** : `table_trick_display.gd`, `table_hot_seat.gd`, `table_play_flow.gd`, `table_context.gd` (`pending_trick_collection_winner`)

**UX handoff** : reconstruire la main (`TableHumanHand.rebuild`) **avant** `_reveal_pending_trick_after_handoff`, pas après le délai de 2 s — sinon le bas de table reste vide pendant l'affichage du pli précédent.

---

## UI table — `Out of bounds get index '0'` sur `Array[CardModel]`

**Symptôme** : crash dans `table_display.gd` → `refresh_human_hand_legality` après distribution hot seat (`unlock_turn` depuis `table_dealing.gd`).

**Cause** : `build_hidden_face_down()` remplit `hand_card_views` (dos) mais laisse `hand_cards` vide ; `refresh_human_hand_legality` indexait les deux tableaux en parallèle.

**Fix** : `_can_apply_hand_legality()` — ne pas appliquer la légalité si main non révélée (`hands_revealed_for_active_human`) ou si tailles `hand_cards` / `hand_card_views` divergent.

**Fichiers** : `scripts/ui/table/table_display.gd`

---

## UI — bandeau Lune soupçonnée trop zoomé / avatar géant

**Symptôme** : `suspicious-moon.png` recadré (yeux seulement), grand `avatar_adv` sur le côté.

**Cause** : hauteur fixe 120 px sur texture large ; zoom `Camera2D` 1.35 + shake de toute la table ; `SpecialAvatarPaths` (images HD).

**Fix** : largeur 96 % viewport + hauteur proportionnelle ; bandeau sur `UILayer` ; assombrissement sans zoom caméra ; `PlayerAvatar` (`Char_XXX`) 64 px sous le bandeau.

**Fichiers** : `moon_suspicion_banner.gd`, `moon_suspicion_banner.tscn`, `moon_suspicion_manager.gd`

---

## Godot — nouveau `class_name` non reconnu

**Symptôme** : type inconnu en headless / tests alors que le script existe.

**Fix** : une fois après ajout de `class_name` :

```powershell
& "...\Godot_v4.7-stable_win64.exe" --headless --editor --quit --path .
```

---

## Simulation — stats polluées (~24k parties)

**Symptôme** : écran Scores affiche des dizaines de milliers de parties après un batch headless.

**Cause** : `MatchManager` émet `GameEvents.match_ended` ; `StatsService` (autoload) enregistre chaque fin de partie UI **et** simulation.

**Fix** : `MatchManager.emit_game_events = false` dans le simulateur batch (`MatchSimulator` / `simulation/`). Bouton « Réinitialiser stats » en Configuration pour nettoyer une save déjà polluée.

**Vigilance** : tout chemin headless / batch doit couper les side-effects autoload (stats, audio, session) avant de boucler des milliers de matchs.

**Fichiers** : `scripts/match/match_manager.gd`, `simulation/lib/match_simulator.gd`, `simulation/README.md`

---

## MCP — `find_unused_resources` faux positifs (deck / audio / UI)

**Symptôme** : scan MCP liste ~170 « unused » dont le deck principal et les SFX.

**Cause** : chargement dynamique (`CardTexturePaths.load()`, `AudioPaths` + `AudioService`, `UiBundleCatalog`) — le grep MCP ne voit pas les références string.

**Fix** : n’archiver que les assets **vraiment** morts (voir `assets/_archive/`). Ne pas supprimer le deck / audio listés dans les paths.

**Vigilance** : croiser toujours avec `AudioPaths` / `CardTexturePaths` / catalogues UI avant quarantine.

---

## Autoload / MCP — `StatsStore` via `preload`, pas seulement `class_name`

**Symptôme** : `Identifier not found: StatsStore` (ou type manquant) dans un autoload précoce ou un script MCP exécuté avant cache global.

**Cause** : `class_name` dépend du cache global Godot ; les autoloads très tôt (et certains `execute_*_script` MCP) peuvent parser avant résolution.

**Fix** : pattern `const StatsStoreClass = preload("res://scripts/core/stats_store.gd")` (comme `StatsService`) ; régénérer le cache `class_name` après ajout (`--headless --editor --quit`).

**Fichiers** : `scripts/services/stats_service.gd`, `scripts/core/stats_store.gd`

---

## UI MCP — NinePatchButton ≠ Button

**Symptôme** : `runtime ui --type_filter Button` ne trouve pas « NOUVELLE PARTIE ».

**Cause** : boutons menu = `NinePatchButton` (pas `Button` Godot).

**Fix** : chercher le **Label** enfant ou `call('_on_btn_…')` / `click_button_by_text`. Détail : skill `dame-de-pique-mcp-playtest`.

---

*Dernière mise à jour : 2026-07-17 — pre-1.0 S0–S4 merge `main`, DOC_OK (sim stats, MCP unused, StatsStore preload, NinePatch).*
