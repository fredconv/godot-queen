---
name: dame-de-pique-multiplayer
description: >-
  Multijoueur Dame de Pique : solo/hot seat/LAN, rotation UI hot seat,
  soupçon Lune social, host autoritaire, snapshots, phases A–G. Utiliser pour
  réseau, hot seat, lobby, NetworkService, RPC ou messages custom.
---

# Dame de pique — multijoueur

## Docs obligatoires

1. `docs/MULTIPLAYER_DESIGN.md` — spec phases, messages, modes
2. `docs/DECISIONS.md` — **ADR-024**, **ADR-025**
3. `docs/MULTIPLAYER_AUDIT.md` — couplage solo / risques
4. `docs/Multiplayer basics in godot.md` — tutoriel Godot (ENet) ; **ne pas** copier Spawner/Synchronizer

Détail hot seat UI + Lune soupçonnée : [reference.md](reference.md)

## Architecture

| Couche | Rôle |
|--------|------|
| `MatchLaunchConfig` / `GameSession` | Config lancement ; `is_multiplayer_social()` |
| `SeatSetup` | N humains + (4−N) IA ; `shuffle_human_seats()` |
| `TableSeatDisplayMap` | Rotation UI hot seat (siège logique → visuel) |
| `TableHotSeat` / `HotSeatPrivacyOverlay` | Handoff + maintien ESPACE 3 s |
| `MoonSuspicionManager` | Soupçon Lune social (bouton, file, RPC) |
| `LocalMatchController` | Solo / hot seat local |
| `HostMatchController` / `ClientMatchController` | En ligne |
| `NetworkMatchRelay` | RPC coups + soupçon Lune |

## Règles non négociables (ADR-024 / ADR-025)

- Host valide chaque `PlayCardAction` ; client n'applique jamais un coup non confirmé
- **Pas** de `MultiplayerSynchronizer` pour le gameplay Hearts
- **Pas** de spawn joueurs 2D — 4 sièges fixes
- Hot seat : **ne jamais** mélanger siège logique et slot visuel sans `TableSeatDisplayMap`
- Soupçon Lune : **aucun** effet sur scores / cartes / IA
- `MatchManager` **n'est pas** un autoload

## Phases

| Phase | Statut | Livrable |
|-------|--------|----------|
| A ✅ | Menu modes, `SeatSetup`, `MatchLaunchConfig` |
| B ✅ | Hot seat : rotation UI, shuffle, overlay 3 s, mains cachées |
| C ✅ | ENet, host/client, lobby IP:port |
| — ✅ | Lune soupçonnée (social, hot seat + online) |
| D ✅ | Déconnexion 30 s, reconnexion, IA de remplacement |
| E–G | Android LAN, Steam, navigateur mobile |

## Fichiers clés

```
scripts/match/match_launch_config.gd
scripts/match/moon_suspicion_event.gd
scripts/network/seat_setup.gd
scripts/network/disconnect_state.gd
scripts/network/network_match_relay.gd
scripts/ui/table/table_disconnect_flow.gd
scripts/ui/table/table_seat_display_map.gd
scripts/ui/table/table_hot_seat.gd
scripts/ui/table/hot_seat_privacy_overlay.gd
scripts/ui/table/moon_suspicion_manager.gd
scripts/ui/table/moon_suspicion_banner.gd
scenes/table/moon_suspicion_banner.tscn
assets/sprites/suspicious-moon.png
```

## Tests (voir reference.md pour commande complète)

`test_seat_setup`, `test_match_launch_config`, `test_table_hot_seat`, `test_table_seat_display_map`, `test_moon_suspicion_manager`, `test_lobby_service`

## i18n

`TableKeys.HOT_SEAT_*`, `TableKeys.MOON_SUSPICION_*`, `TableKeys.TOP_MOON_SUSPICION` → `translations/table.csv`

## Après une feature multijoueur

Quand l'utilisateur dit **doc ok** : skill global `agent-workflow` + mettre à jour ce SKILL, `docs/MULTIPLAYER_DESIGN.md`, ADR si décision d'architecture, hook `after-multiplayer-edit.ps1` si nouveaux chemins.
