---
name: dame-de-pique-multiplayer
description: >-
  Multijoueur Dame de Pique : modes solo/hot seat/LAN, host autoritaire,
  snapshots, SeatSetup, phases A–G. Utiliser pour toute tâche réseau, hot seat,
  lobby, NetworkService ou messages custom.
---

# Dame de pique — multijoueur

## Docs obligatoires

1. `docs/MULTIPLAYER_DESIGN.md` — spec phases, messages, modes
2. `docs/DECISIONS.md` — **ADR-024**
3. `docs/MULTIPLAYER_AUDIT.md` — couplage solo / risques
4. `docs/Multiplayer basics in godot.md` — tutoriel Godot (ENet, authority) ; **ne pas** copier Spawner/Synchronizer

## Architecture

| Couche | Rôle |
|--------|------|
| `MatchLaunchConfig` / `GameSession` | Config lancement (solo, hot seat, online) |
| `SeatSetup` | N humains + (4−N) IA |
| `LocalMatchController` | Solo / hot seat local |
| `HostMatchController` / `ClientMatchController` | Phase C+ |
| `NetworkService` | ENet P2P (stub → phase C) |
| `NetworkMessages` | Constantes messages |
| `GameSnapshotBuilder` | Public / privé |

## Règles non négociables (ADR-024)

- Host valide chaque `PlayCardAction` ; client n'applique jamais un coup non confirmé
- **Pas** de `MultiplayerSynchronizer` pour le gameplay Hearts
- **Pas** de spawn joueurs 2D — 4 sièges fixes
- Sièges vides = IA
- `MatchManager` **n'est pas** un autoload
- `NetworkService` pas autoload tant que phase C incomplète

## Phases

| Phase | Contenu |
|-------|---------|
| A ✅ | Menu modes, `SeatSetup`, `MatchLaunchConfig` |
| B | Hot seat : `active_human_seat`, `HotSeatPrivacyOverlay` |
| C | ENet, host/client controllers, lobby IP:port |
| D | Déconnexion 30 s, reconnexion, IA de remplacement |
| E–G | Android LAN, Steam, navigateur mobile |

## Fichiers clés

```
scripts/match/match_mode.gd
scripts/match/match_launch_config.gd
scripts/network/seat_setup.gd
scripts/network/network_service.gd
scripts/network/network_messages.gd
scripts/ui/table/table_hot_seat.gd
scripts/ui/table/hot_seat_privacy_overlay.gd
```

## Tests à lancer après modification

```powershell
& "...\Godot_v4.7-stable_win64_console.exe" --headless --path . `
  -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode `
  -a res://tests/unit/test_seat_setup.gd `
  -a res://tests/unit/test_match_launch_config.gd `
  -a res://tests/unit/test_table_hot_seat.gd `
  -a res://tests/unit/test_lobby_service.gd
```

## Tutoriel Godot — ce qu'on reprend / évite

| Reprendre (phase C) | Éviter |
|---------------------|--------|
| `ENetMultiplayerPeer`, host/join | `MultiplayerSpawner` |
| `multiplayer.peer_connected` | `MultiplayerSynchronizer` sync frame |
| `get_remote_sender_id()` pour valider l'expéditeur | `@rpc call_local` sur gameplay |
| Profiler réseau, 2 instances debug | Serveur headless MVP |

## i18n

Clés menu : `MenuKeys.*` (`translations/menu.csv`)  
Clés table hot seat : `TableKeys.HOT_SEAT_*` (`translations/table.csv`)
