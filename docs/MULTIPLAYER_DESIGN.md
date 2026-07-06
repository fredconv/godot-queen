# Conception multijoueur — Dame de Pique

## Principe

**Serveur autoritaire** : le host valide chaque intention (`PlayerAction`), applique `MatchManager`, diffuse événements et snapshots. Les clients n'appliquent jamais un coup non confirmé.

## Phases livrées (0-6 + 5.5)

| Phase | Statut | Livrable |
|-------|--------|----------|
| 0 | ✅ | `docs/MULTIPLAYER_AUDIT.md` |
| 1 | ✅ | `scripts/game_actions/` |
| 2 | ✅ | `scripts/game_events/` |
| 3 | ✅ | `GameSnapshotBuilder`, snapshots |
| 4 | ✅ | `LocalMatchController`, branchement table |
| 5 | ✅ | `PlayerProfile`, `SeatAssignment`, `SoloSeatSetup` |
| 5.5 | ✅ | `LocalPlayerProfile`, sauvegarde v1, pseudo |
| 6 | ✅ | `LobbyState`, `LobbyService` (local) |
| 7+ | ⏳ | Réseau ENet, synchro manche, reconnexion |

## Messages réseau (prévus)

Constantes dans `scripts/network/network_messages.gd` :

- `request_play_card` — intention client
- `server_card_played` — événement public confirmé
- `server_snapshot` — état public
- `request_private_snapshot` — main du joueur (siège vérifié)

## Données publiques vs privées

**Public** (`PublicGameSnapshot`) : joueur actif, pli en cours (cartes posées), scores, tailles de mains, phase, cœurs défoncés.

**Privé** (`PrivatePlayerSnapshot`) : cartes en main + coups légaux du joueur demandeur uniquement.

## Profil joueur local

- `player_id` : identifiant stable (`local_*`), **pas** le pseudo
- `display_name` : pseudo affiché / proposé au lobby
- Champs futurs auth/newsletter présents mais désactivés (`auth_provider = "local"`)

Sauvegarde versionnée : `GameSaveStore` v1 dans `user://savegame.json`.

## Reconnexion (futur)

Client reconnecté reçoit snapshot public + privé de son siège si `local_player_id` correspond. Host conserve l'état officiel.

## Limites connues

- Pas de prédiction visuelle client
- Pas de backend compte / OAuth
- `NetworkService` = stub
- Stats multijoueur officielles = côté host uniquement (à implémenter phase 7+)
