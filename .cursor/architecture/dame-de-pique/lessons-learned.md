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

---

## Godot — nouveau `class_name` non reconnu

**Symptôme** : type inconnu en headless / tests alors que le script existe.

**Fix** : une fois après ajout de `class_name` :

```powershell
& "...\Godot_v4.7-stable_win64.exe" --headless --editor --quit --path .
```

---

*Dernière mise à jour : juillet 2026 — Phase D déconnexion, hot seat illusion complète, fixes autoload / banner / IA siège 0.*
