# Multijoueur — référence détaillée (Dame de pique)

Complément de [SKILL.md](SKILL.md). Lire uniquement si hot seat UI, soupçon Lune ou RPC social.

---

## Hot seat — rotation UI (ADR-025)

**Principe** : le moteur garde les sièges logiques `0–3` inchangés (`MatchManager`). Seule l'UI tourne.

| Concept | Fichier / champ |
|---------|-----------------|
| Pivot (joueur en bas) | `MatchLaunchConfig.active_human_seat_index` |
| Mapping logique → visuel | `TableSeatDisplayMap` |
| Mains cachées avant handoff | `hands_revealed_for_active_human` |
| Overlay passage | `HotSeatPrivacyOverlay` — maintien ESPACE 3 s |
| Shuffle places début partie | `SeatSetup.shuffle_human_seats()` |

Formules :

```gdscript
visual = (logical_seat - pivot + 4) % 4
logical  = (visual + pivot) % 4
```

**Ne jamais** utiliser `ctx.seats[player_index]` quand `player_index` est un siège logique en hot seat multi-humain — utiliser `TableSeatDisplayMap.get_seat_node(ctx, logical_seat)`.

Handoff : `TableHotSeat.perform_handoff()` → après validation overlay → `TableSeatDisplayMap.apply()` → `TableHumanHand.rebuild()` → `MoonSuspicionManager.flush_pending_alerts()`.

---

## Lune soupçonnée — événement social (ADR-025)

**Pas de gameplay** : scores, cartes, IA inchangés. Signal social entre humains.

| Couche | Fichier |
|--------|---------|
| Données | `scripts/match/moon_suspicion_event.gd` |
| Logique + file hot seat | `scripts/ui/table/moon_suspicion_manager.gd` |
| Bandeau | `scenes/table/moon_suspicion_banner.tscn` |
| RPC en ligne | `NetworkMatchRelay.rpc_request_moon_suspicion` / `rpc_apply_moon_suspicion` |

Disponibilité : `MatchLaunchConfig.is_multiplayer_social()` — hot seat ≥ 2 humains ou online. **Masqué en solo.**

Anti-spam : **1 soupçon / joueur / manche** (`_used_suspector_seats`, reset dans `on_new_hand`).

Hot seat :

1. Le soupçonneur voit le bandeau immédiatement.
2. Événement en file `_pending_events` avec `seen_by_seats`.
3. Chaque autre humain voit l'alerte **après** handoff (mains déjà révélées pour lui).

En ligne : host valide → `broadcast_moon_suspicion_from_host` → tous les clients `rpc_apply_moon_suspicion`.

---

## Tests après modification

```powershell
& "...\Godot_v4.7-stable_win64.exe" --headless --path . `
  -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode `
  -a res://tests/unit/test_seat_setup.gd `
  -a res://tests/unit/test_match_launch_config.gd `
  -a res://tests/unit/test_table_hot_seat.gd `
  -a res://tests/unit/test_table_seat_display_map.gd `
  -a res://tests/unit/test_moon_suspicion_manager.gd `
  -a res://tests/unit/test_lobby_service.gd
```

Cache `class_name` : `--headless --editor --quit` une fois après nouveau `class_name`.
