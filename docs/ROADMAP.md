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

## Étape 4 — Orchestration de partie (`MatchManager`)

- `MatchManager` (nœud non-autoload) : cycle de vie d'une manche/partie complète.
- Intégration avec `GameEvents` pour notifier les changements d'état.
- Tests d'intégration (`tests/integration/`) sur un déroulement de manche complet.

## Étape 5 — IA de base

- Stratégie IA simple (choix de carte valide, priorité à défausser les points).
- Intégration de l'IA dans le déroulement de la partie via `MatchManager`.

## Étape 6 — Interface de jeu (table)

- Scène `table.tscn` : affichage des mains, du pli en cours, des scores.
- Composants réutilisables (carte visuelle, jeton de score) dans `scenes/components/`.
- Interactions joueur (sélection et validation d'une carte à jouer).

> Note : un **scaffold visuel statique** de `table.tscn` (fond, barre de menu, sièges, zone de pli, main en éventail de démonstration) a été mis en place en avance de phase — voir `docs/TECHNICAL_DESIGN.md` (section « Architecture UI — table de jeu »). Il reste à y brancher les interactions et les données réelles via `GameEvents`/`MatchManager`.

## Étape 7 — Menus & UX

- Menu principal, écran de fin de manche, écran de fin de partie.
- Options (volume, langue) branchées sur `ConfigService`.
- Sauvegarde de la progression via `SaveService`.

> Note : un premier **menu principal** (`scenes/menus/main_menu.tscn`) a été mis en place en avance de phase : fond tapis vert identique à `table.tscn`, boutons « NOUVELLE PARTIE » (charge `table.tscn` via `GameSession.start_match()`), « SCORES » et « CONFIGURATION » (recouvrement modal provisoire « à venir », écrans détaillés restant à construire) et « QUITTER ». `Bootstrap` (`run/main_scene`) enchaîne désormais sur ce menu au lieu d'afficher un écran de statut isolé, et le bouton « MENU » de la table y ramène (avec confirmation si une partie est en cours, via `GameSession`).

## Étape 8 — Audio & polish visuel

- Intégration des assets sonores via `AudioService`.
- Animations de cartes, effets visuels (`assets/vfx/`).
- Passage en revue de l'ergonomie et des retours visuels.

## Étape 9 — Tests end-to-end & stabilisation

- Scénarios de test end-to-end (Playwright si applicable à l'export web, sinon tests d'intégration Godot).
- Correction de bugs, revue de performance.

## Étape 10 — Export & distribution

- Configuration des presets d'export (Windows en priorité).
- Build de validation finale.
