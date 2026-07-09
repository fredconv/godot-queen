# Conception multijoueur — Dame de Pique

> **Dernière mise à jour :** juillet 2026 — ADR-024  
> Références : `docs/MULTIPLAYER_AUDIT.md`, `docs/DECISIONS.md`, `docs/godot multiplayer steam.md`, `docs/Multiplayer basics in godot.md`

## Principe réseau

**Serveur autoritaire (host = joueur)** : le host valide chaque intention (`PlayCardAction`), applique `MatchManager`, diffuse événements et snapshots. Les clients n'appliquent jamais un coup non confirmé.

**Pas de réplication haute niveau Godot** (MultiplayerSynchronizer / spawn joueurs 2D) : jeu **tour par tour** — transport ENet + messages custom + snapshots (phases 0–6).

---

## Modes de jeu

| Mode | Humains | Réseau | Sièges vides |
|------|---------|--------|--------------|
| **Solo** | 1 | Non | 3 IA |
| **Hot seat** | 1–4 (même machine) | Non | `(4 − N)` IA |
| **En ligne** | 1–4 (LAN P2P) | ENet | `(4 − N)` IA |

Règle : **chaque siège sans humain actif = IA** (`SeatSetup` / `LobbyService.assign_ai_to_empty_seats()`).

### Hot seat (même machine)

Passage de manette / écran entre joueurs locaux :

1. Joueur actif voit sa main et joue.
2. Après son coup (ou fin de tour) → overlay plein écran : « Passez l'appareil au joueur {nom} » + « Appuyez sur Espace / Entrée ».
3. Aucune main visible pendant le passage.
4. Pli en cours et scores restent publics.

**Phase B** : overlay confidentialité (`HotSeatPrivacyOverlay`) — livré.  
**Futur (hors MVP)** : mains sur téléphone via navigateur (QR code) — complexité élevée.

### En ligne (LAN P2P)

- Transport : **ENetMultiplayerPeer** (Godot natif), host relaie les messages.
- **Windows LAN** puis **Android LAN** (téléphone peut être host sur Wi‑Fi local).
- **Steam** (GodotSteam, lobby + relay) — phase ultérieure, même couche messages.
- Pas de serveur dédié headless en MVP.

---

## Déconnexion et reconnexion (en ligne)

Par joueur humain déconnecté (timers **indépendants**, cumulables) :

1. Message table : « {display_name} déconnecté ».
2. Siège en état `DISCONNECTED_PENDING` — pas de coup tant que décompte actif si c'est son tour.
3. **Décompte 30 s** visible pour tous.
4. **Reconnexion** : même `local_player_id` + même `seat_index` → snapshot public + privé, reprise.
5. **Expiration** : siège remplacé par **IA** (main conservée côté host) + « {display_name} remplacé par l'IA ».

Implémentation : phase D (`DisconnectState`, messages `peer_disconnected`, `seat_reconnect_countdown`, `seat_replaced_by_ai`).

---

## Phases d'implémentation

| Phase | Statut | Livrable |
|-------|--------|----------|
| 0 | ✅ | `docs/MULTIPLAYER_AUDIT.md` |
| 1 | ✅ | `scripts/game_actions/` |
| 2 | ✅ | `scripts/game_events/` |
| 3 | ✅ | `GameSnapshotBuilder`, snapshots |
| 4 | ✅ | `LocalMatchController`, branchement table |
| 5 | ✅ | `PlayerProfile`, `SeatAssignment`, `SoloSeatSetup` |
| 5.5 | ✅ | `LocalPlayerProfile`, sauvegarde v1 |
| 6 | ✅ | `LobbyState`, `LobbyService` (local simulé) |
| **A** | ✅ | `MatchMode`, `MatchLaunchConfig`, menu modes, `SeatSetup` |
| **B** | ✅ | Hot seat : overlay passage + `active_human_seat` |
| **C** | ✅ | ENet : `NetworkService`, host/client controllers, lobby IP:port |
| **D** | ⏳ | Déconnexion 30 s, reconnexion, remplacement IA |
| **E** | ⏳ | Android LAN (host/client, IP locale) |
| **F** | ⏳ | Steam (GodotSteam) |
| **G** | 📋 | Navigateur mobile (QR) — post-MVP |

---

## Messages réseau

Constantes dans `scripts/network/network_messages.gd` :

| Message | Direction | Rôle |
|---------|-----------|------|
| `request_play_card` | client → host | Intention |
| `server_card_played` | host → all | Événement confirmé |
| `server_snapshot` | host → all | État public |
| `request_private_snapshot` | client → host | Main + coups légaux (siège vérifié) |
| `server_error` | host → client | Coup refusé |
| `peer_disconnected` | host → all | Déconnexion (phase D) |
| `peer_reconnected` | host → all | Reconnexion (phase D) |
| `seat_reconnect_countdown` | host → all | Sync décompte 30 s (phase D) |
| `seat_replaced_by_ai` | host → all | Remplacement IA (phase D) |

---

## Données publiques vs privées

**Public** (`PublicGameSnapshot`) : joueur actif, pli, scores, tailles de mains, phase, cœurs défoncés.

**Privé** (`PrivatePlayerSnapshot`) : cartes en main + coups légaux du demandeur uniquement.

---

## Architecture cible

```
Menu → GameModeScreen → (Solo | HotSeatLobby | MultiplayerLobby)
                              ↓
                    MatchLaunchConfig → GameSession
                              ↓
                         table.tscn
                              ↓
              HostMatchController / ClientMatchController / LocalMatchController
                              ↓
                        MatchManager (host only en ligne)
```

Fichiers prévus :

- `scripts/match/match_mode.gd`, `match_launch_config.gd`, `seat_setup.gd`
- `scripts/network/network_service.gd`, `host_match_controller.gd`, `client_match_controller.gd`
- `scripts/network/disconnect_state.gd` (phase D)
- `scripts/ui/game_mode_screen.gd`, `hot_seat_lobby_screen.gd`, `multiplayer_lobby_screen.gd`
- `scripts/ui/table/hot_seat_privacy_overlay.gd` (phase B)
- `scripts/ui/table/table_network_sync.gd` (phase C)

---

## Profil joueur

- `player_id` / `local_player_id` : stable, **≠** pseudo — reconnexion.
- `display_name` : affichage lobby / messages déconnexion.
- Stats multijoueur officielles : **host uniquement** (futur).

---

## Limites MVP réseau

- Pas de prédiction visuelle client.
- Pas de backend compte / OAuth.
- Pas de matchmaking Internet (LAN / Steam relay plus tard).
- `NetworkService` stub jusqu'à phase C — **phase C livrée** (ENet LAN).

Voir `docs/MULTIPLAYER_AUDIT.md` pour l'audit phase 0.

---

## Références externes

### `docs/Multiplayer basics in godot.md` (workshop Godot Days)

Transcription du tutoriel **ENet P2P, host autoritaire, RPC, MultiplayerSpawner/Synchronizer**.

| Sujet tutoriel | Notre choix (ADR-024) | Phase |
|----------------|----------------------|-------|
| ENet host + client (`ENetMultiplayerPeer`) | ✅ `NetworkService` | C |
| Host = vérité du jeu | ✅ `MatchManager` côté host uniquement | C |
| Clients envoient inputs / messages | ✅ `request_play_card` → validation host | C |
| `peer_connected` / déconnexion | ✅ spec phase D (30 s, reconnexion) | D |
| Debug 2 instances Godot (localhost) | ✅ tests LAN locaux | C |
| `MultiplayerSpawner` (spawn joueurs) | ❌ 4 sièges fixes, pas de spawn scène | — |
| `MultiplayerSynchronizer` (sync continue) | ❌ snapshots + événements discrets | — |
| `@rpc any_peer call_local` sur gameplay | ❌ host valide ; pas de double application | C |
| `is_multiplayer_authority` sur input | ≈ `submit_action` + siège actif hot seat | B/C |
| Serveur headless dédié | ❌ P2P host-joueur en MVP | — |

**Usage agent :** skill projet `dame-de-pique-multiplayer` + skill global `godot-multiplayer-turn-based`.

### `docs/godot multiplayer steam.md`

Notes Steam / GodotSteam — phase F, même couche messages que ENet.
