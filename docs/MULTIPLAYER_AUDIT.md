# Audit multijoueur — Phase 0

Note produite avant l'introduction du réseau. Aucune modification de gameplay requise à ce stade.

## Où une carte est jouée

| Couche | Fichier | Rôle |
|--------|---------|------|
| UI | `scripts/ui/table/table_play_flow.gd` | Sélection humaine / tours IA, animations |
| Contrôleur | `scripts/match/local_match_controller.gd` | Reçoit `PlayCardAction`, produit événements |
| Moteur | `scripts/match/match_manager.gd` | `play_card()` : validation + état officiel |

## Où le coup est validé

- `RuleEngine.validate_play()` (règles pures)
- `MatchManager.play_card()` (tour, phase, possession de la carte)

## Où l'IA décide

- `AiPlayer.choose_card()` via `HeuristicStrategy`
- Appelée depuis `table_play_flow.gd` (UI) ou `LocalMatchController.play_ai_turn()`

## Où l'UI lit le MatchManager

- `table_display.gd`, `table_play_flow.gd`, `table_match_flow.gd`, `table_fx.gd`
- Migration progressive vers `LocalMatchController` + snapshots (phase 4)

## État officiel

- `MatchManager` + `TrickManager` + `ScoreManager` + `RuleEngine`
- Signaux `GameEvents` pour découplage audio / stats locales

## Prêt pour le multijoueur

- Règles et scoring purs (`scripts/rules/`)
- `PlayCardAction` / `ActionResult` (intentions explicites)
- Événements sérialisables (`scripts/game_events/`)
- Snapshots public/privé (`GameSnapshotBuilder`)
- Identités siège (`PlayerProfile`, `SeatAssignment`, `LobbyService`)
- `player_id` local stable distinct du pseudo (`LocalPlayerProfile`)

## Couplé au solo aujourd'hui

- `table_play_flow` enchaîne IA + animations + `MatchManager` dans le même flux
- Noms de sièges via `TableLocale` / `PlayerProfileService`
- `StatsService` écoute `match_ended` (stats locales uniquement)

## Risques de désynchronisation futurs

- UI qui lit `MatchManager` avant confirmation host → atténué par contrôleur autoritaire
- Fuites de mains adverses dans snapshots → tests `test_game_snapshot_builder.gd`
- Confusion `player_index` / `peer_id` / `seat_index` → modèle `PlayerConnection`
- Stats client vs serveur → stats locales séparées, pas de confiance client en multi

## Prochaines étapes (non implémentées)

- Phase 7 : `NetworkService` ENet, host autoritaire
- Phase 8-9 : synchro manche complète, reconnexion
- Phase 10-11 : UX multi, validation stricte des messages

Voir `docs/MULTIPLAYER_DESIGN.md`.
