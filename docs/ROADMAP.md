# Roadmap — Dame de Pique

Suivi des étapes de développement. Chaque étape doit être validée avant de passer à la suivante.

## Étape 1 — Scaffolding ✅ (en cours de validation)

- Arborescence complète du projet (`scenes/`, `scripts/`, `resources/`, `assets/`, `tests/`, `docs/`).
- `project.godot` : scène principale (`bootstrap.tscn`), viewport 1280x720, autoloads déclarés.
- Autoloads stubs : `GameEvents`, `SaveService`, `AudioService`, `ConfigService`, `DebugService`.
- Scène `Bootstrap` minimale (vérifie le chargement des autoloads, affiche un statut).
- Documentation initiale (`GDD`, `TECHNICAL_DESIGN`, `ROADMAP`, `DECISIONS`, `TEST_PLAN`).

## Étape 2 — Fondations de test & modèle de données ✅ (en cours de validation)

- Installation de **GdUnit4** (`addons/gdUnit4/`, v6.2.0-rc2, branche `master` — seule version compatible Godot 4.7 stable au moment de l'intégration, voir `docs/DECISIONS.md` ADR-012).
- Types de base : `Suit` (`scripts/core/suit.gd`), `Rank` (`scripts/core/rank.gd`), `CardModel` (`scripts/gameplay/cards/card_model.gd`).
- `Deck` (`scripts/gameplay/cards/deck.gd`) : génération de 52 cartes uniques, mélange (déterministe via seed optionnel), distribution (`deal`), pioche (`draw`/`peek`).
- `PlayerHand` (`scripts/gameplay/cards/player_hand.gd`) : ajout/retrait de carte, contenu trié par couleur puis rang.
- Premiers tests unitaires (`tests/unit/test_card_model.gd`, `test_deck.gd`, `test_player_hand.gd`), 24 cas, tous verts (voir `docs/TEST_PLAN.md`).
- Pas de règles de jeu à cette étape (validation de coup, résolution de pli, scoring) : réservé à l'étape 3.

## Étape 3 — Règles du jeu (moteur pur) ✅ (en cours de validation)

- `HeartsRules` (`scripts/rules/hearts_rules.gd`) : constantes (points, tailles) et requêtes pures sans état (carte à points, 2 de Trèfle, main 100% Cœurs/cartes à points).
- `RuleEngine` (`scripts/rules/rule_engine.gd`) : état de manche (`hearts_broken`, `trick_number`, `is_first_trick`), coups légaux et validation (`get_legal_plays`, `validate_play`), résolution de pli (`get_trick_winner`), calcul du score de manche avec détection du « shoot the moon » (`score_hand`) — variante retenue documentée en `docs/DECISIONS.md` (ADR-016).
- Règles couvertes : 2 de Trèfle obligatoire au premier pli, suivi de couleur obligatoire, interdiction d'entamer un pli avec un Cœur avant qu'il soit défoncé (sauf main 100% Cœurs), interdiction de jouer une carte à points au premier pli (sauf main 100% cartes à points), Cœurs défoncés par un Cœur ou la Dame de Pique.
- Tests unitaires (`tests/unit/test_rule_engine.gd`), 33 cas, tous verts (57 au total avec l'étape 2, voir `docs/TEST_PLAN.md`).
- Pas de gestion de la passe de cartes (3 cartes) ni d'orchestration de manche à cette étape : réservé à l'étape 4 (`MatchManager`).

## Étape 4 — Orchestration de partie (`MatchManager`) ✅ (en cours de validation)

- `TrickManager` (`scripts/match/trick_manager.gd`) : état du pli en cours (cartes posées, couleur demandée), délègue la résolution du vainqueur à `RuleEngine.get_trick_winner()`.
- `ScoreManager` (`scripts/match/score_manager.gd`) : scores cumulés des 4 joueurs sur une partie (plusieurs manches), alimenté par `RuleEngine.score_hand()`.
- `MatchManager` (`scripts/match/match_manager.gd`, `RefCounted`, **non-autoload** — voir ADR-002) : cycle de vie complet d'une manche/partie (distribution, tour de jeu, résolution de pli, score, fin de manche, fin de partie au seuil de points). Pas de passe de cartes (3 cartes) à cette étape — voir ADR-018.
- Stub IA minimal (`scripts/ai/ai_player.gd`, `AiPlayer`) : choix aléatoire seedable parmi les coups légaux, utilisé pour simuler une manche complète sans UI ; une vraie stratégie est prévue à l'étape 5.
- Intégration avec `GameEvents` : `MatchManager` émet directement `match_started`, `card_played`, `trick_resolved`, `score_updated`, `match_ended` (même pattern que `game_session.gd`/`audio_service.gd`, voir docs/TECHNICAL_DESIGN.md).
- Tests d'intégration (`tests/integration/test_match_manager.gd`), 11 cas, tous verts (68 au total avec les étapes 2/3, voir `docs/TEST_PLAN.md`) : déroulement complet d'une manche (13 plis, mains vides), cumul des scores sur plusieurs manches, rejet des coups illégaux et hors-tour, invariant de score (26 points ou 78 en cas de "shoot the moon").

## Étape 5 — IA de base ✅ (en cours de validation)

- `AiStrategy` (`scripts/ai/ai_strategy.gd`) : interface polymorphe de choix de carte, stratégies concrètes : `RandomLegalStrategy`, `HeuristicStrategy`, `PassiveStrategy`, `MoonShooterStrategy`, `MoonBreakerStrategy`.
- `AdaptiveAiStrategy` (`scripts/ai/adaptive_ai_strategy.gd`) : hiérarchie de modes (MINIMIZE / CHASE_MOON / BREAK_MOON), personnalités mixtes, abandon nuancé de la chasse Lune — voir ADR-023.
- `MoonFeasibility`, `MoonSuspicion`, `AiConfidence` : modules de décision Lune.
- `AiPlayer` (`scripts/ai/ai_player.gd`) : porte la stratégie et un `RandomNumberGenerator` seedé.
- Intégration `MatchManager` : `build_ai_context`, `play_ai_turn`, télémétrie (`AiTelemetryCollector`). Convention sièges : ADR-019 (siège 0 = humain).
- **Simulation batch** (`simulation/`, hors livrable) : validation statistique des personnalités et taux Lune.
- Tests IA : `test_ai_player`, `test_ai_personalities`, `test_moon_feasibility`, `test_adaptive_ai_strategy`, `test_moon_suspicion`, `test_ai_confidence`, `test_ai_telemetry_collector` + intégration `test_match_ai_simulation`.

## Étape 6 — Interface de jeu (table) ✅ (en cours de validation)

- `table.gd` instancie et pilote un `MatchManager` (siège 0 = joueur humain, sièges 1-3 = IA `HeuristicStrategy`, voir docs/DECISIONS.md ADR-019/ADR-020) : la table est désormais réellement jouable, plus un simple scaffold statique.
- Main humaine affichée à partir de `MatchManager.hands[0]` (13 cartes, textures réelles) ; seules les cartes légales (`MatchManager.get_legal_plays()`) sont pleinement opaques et cliquables, les autres grisées et non interactives.
- Sièges adverses : nombre de cartes restantes (`hand_card_count`) et surbrillance du tour actif synchronisés avec l'état de `MatchManager` ; mains adverses jamais révélées (dos de carte uniquement).
- Tours IA enchaînés automatiquement (`table.gd::_run_ai_turns`) avec une pause courte entre chaque coup pour rester lisible, jusqu'au prochain tour humain ou la fin de manche/partie — sans modifier `MatchManager` (voir ADR-020 pour la justification de ne pas utiliser `MatchManager.advance_ai_turns()` ici).
- Scores cumulés affichés sur les sièges et tour courant affiché dans la barre de menu (`ScoreLabel`/`TurnLabel`).
- Fin de manche : nouvelle manche distribuée automatiquement. Fin de partie : popup dédié avec vainqueur/scores (voir étape 8, animations anticipées).
- Composants réutilisés tels quels (`card_view`, `player_seat`, `top_menu_bar`), aucune modification de la maquette visuelle statique de `table.tscn` (ajout uniquement de `AnimationLayer` et `MatchEndDialog`, voir ADR-021).
- Pas de nouveau test automatisé GdUnit4 pour cette étape (logique UI couplée à l'arbre de scène/minuteurs asynchrones, priorité plus basse — voir docs/TEST_PLAN.md) : validation par relecture du câblage et exécution headless (compilation des scripts). Les 86 tests GdUnit4 des étapes 2-5 restent inchangés et verts.

## Étape 7 — Menus & UX ✅

- Menu principal, écrans Scores / Configuration / Crédits, popup fin de manche/partie.
- Options (volume, langue, thème table) branchées sur `ConfigService` (clé `settings` dans sauvegarde v1).
- Statistiques locales via `StatsService` ; profil joueur via `PlayerProfileService` (pseudo, `player_id` stable).
- Sauvegarde versionnée `GameSaveStore` v1 (`user://savegame.json`), migration depuis l'ancien format `config`.

## Étape 7.5 — Préparation multijoueur (phases 0-6) ✅

- Actions (`PlayCardAction`), événements sérialisables, snapshots public/privé.
- `LocalMatchController` entre UI et `MatchManager`.
- Identités siège, lobby local simulé, audit et design : voir `docs/MULTIPLAYER_DESIGN.md`.
- Réseau réel (ENet, phases C+) : **non implémenté**.

## Étape 7.8 — Multijoueur en ligne LAN (phase C) ✅

- `NetworkService` + `NetworkMatchRelay` (autoloads ENet P2P).
- `HostMatchController` / `ClientMatchController`, lobby IP:port, 1–4 humains.
- Déconnexion avancée (30 s) = phase D.

## Étape 7.7 — Hot seat confidentialité (phase B) ✅

- Overlay passage d'appareil (`HotSeatPrivacyOverlay`), rotation `active_human_seat_index`.
- Main visible uniquement pour le joueur actif ; Espace/Entrée pour reprendre.

## Étape 7.6 — Modes de jeu multijoueur (phase A) ✅

- ADR-024 : solo, hot seat, en ligne (spec complète dans `docs/MULTIPLAYER_DESIGN.md`).
- `MatchMode`, `MatchLaunchConfig`, `SeatSetup`, menu choix de mode.
- Hot seat : lobby 1–4 joueurs (overlay passage = phase B).
- En ligne : écran lobby stub (ENet = phase C).

## Étape 8 — Audio & polish visuel (en cours)

Objectif : qualité « store-ready » (Play Store) — UI/UX, audio et cohérence visuelle.

### Livré / en cours
- Thème `pixel_theme.tres` : boutons, panneaux or, champs formulaire (LineEdit, sliders, OptionButton)
- Menu principal : fond tapis, vignette, panneau encadré, pseudo joueur
- **UIBundleFree** : thème Medieval (enseigne + boutons bois), catalog + slices (`ui/DesignSystem.md`)
- Overlays harmonisés (config, scores, crédits, profil, dialogs table)
- Barre menu table compacte (thème, bordure or, icônes + boutons texte)
- Navigation clavier / manette (`UiFocusNav`) sur menus et overlays
- Palette partagée `UiPalette`

### À faire (itérations suivantes)
- [x] Animation distribution cartes (visuelle) — livrée étape 6
- [x] Labels boutons NinePatch lisibles (12 px)
- [ ] Sons : volumes finaux, transitions musique
- [ ] Icône app + splash screen export Android
- [ ] Tests sur ratios mobile (safe area)
- [ ] Cartes pixel art (optionnel, post-MVP)

> Animations de pli, popups fin de manche/partie, audio de base et menus complets déjà livrés aux étapes 6–7.

## Étape 9 — Tests end-to-end & stabilisation

- Scénarios de test end-to-end (Playwright si applicable à l'export web, sinon tests d'intégration Godot).
- Correction de bugs, revue de performance.

## Étape 10 — Export & distribution

- Configuration des presets d'export (Windows en priorité).
- Build de validation finale.
