# Plan de test — Dame de Pique

## Stratégie générale

Le projet combine deux niveaux de test :

1. **Tests unitaires et d'intégration GDScript (GdUnit4)** — pour la logique de jeu (règles, scoring, deck, orchestration de manche).
2. **Tests end-to-end (Playwright)** — pour valider le comportement de l'export web (si un export HTML5 est produit), en simulant des interactions joueur réelles dans le navigateur.

> **GdUnit4 est installé** depuis l'étape 2 (`addons/gdUnit4/`, voir `docs/DECISIONS.md` ADR-012 pour le choix de version). Le plugin est activé dans `project.godot` (`[editor_plugins]`).

## Lancer les tests unitaires

### Depuis l'éditeur Godot

1. Ouvrir le projet dans Godot 4.7 (le plugin GdUnit4 s'active automatiquement).
2. Dans le panneau **FileSystem**, clic droit sur `tests/unit/` (ou un fichier `test_*.gd` précis) → **Run Tests**.
3. Les résultats s'affichent dans le panneau **GdUnit** (bas de l'éditeur, à côté de Sortie/Debug).

### En ligne de commande (headless, CI-friendly)

Depuis la racine du projet, avec `GODOT_BIN` pointant vers l'exécutable Godot 4.7 :

```
addons\gdUnit4\runtest.cmd --godot_binary "C:\chemin\vers\Godot_v4.7-stable_win64.exe" -a res://tests/unit -c
```

(`runtest.sh` équivalent sous Linux/macOS.) L'option `-c` (`--continue`) exécute tous les tests même après un échec ; l'omettre pour un arrêt au premier échec (fail-fast, comportement par défaut).

**Prérequis** : au premier lancement après l'ajout d'un nouveau script `class_name` (ou du plugin lui-même), il faut que Godot ait reconstruit le cache des classes globales une fois — sinon le CLI échoue avec des erreurs `Nonexistent function 'new' in base 'GDScript'`. Régénérer le cache (ouverture normale de l'éditeur, ou headless) :

```
"C:\chemin\vers\Godot_v4.7-stable_win64.exe" --path . --headless --editor --quit
```

À refaire uniquement après ajout/renommage de classes `class_name`, pas à chaque exécution de tests.

Un rapport HTML/XML est généré dans `reports/` (ignoré par Git, voir `.gitignore`) après chaque exécution.

## Tests unitaires (GdUnit4) — `tests/unit/`

Cible en priorité les fonctions **pures**, sans dépendance à une scène instanciée :

- **Deck & cartes** (`scripts/gameplay/cards/`) : génération des 52 cartes, absence de doublon, mélange, distribution équitable (13 cartes x 4 joueurs).
- **Règles** (`scripts/rules/`) :
  - validation d'un coup (suivre la couleur si possible).
  - interdiction du Cœur tant qu'il n'a pas été défoncé (sauf main 100% Cœurs).
  - interdiction de la Dame de Pique au premier pli (sauf main sans alternative).
  - détermination du vainqueur d'un pli.
  - calcul du score d'une manche (Cœurs = 1 pt, Dame de Pique = 13 pts).
  - détection du « shooting the moon » (0 pt pour le joueur, 26 pts pour les autres).
- **IA** (`scripts/ai/`, `tests/unit/test_ai_player.gd`) : l'IA ne propose jamais un coup invalide (test croisé avec `RuleEngine`/`MatchManager` sur des manches complètes simulées), déterminisme par seed (même seed → même choix à état identique), comportements ciblés de `HeuristicStrategy` (évite d'entamer avec une carte à points quand une alternative existe, défausse en priorité la Dame de Pique puis les Cœurs hauts quand elle ne peut pas suivre la couleur, "ducke" ou minimise la carte gagnante quand elle le peut).

## Tests d'intégration (GdUnit4) — `tests/integration/`

Cible les interactions entre plusieurs modules, avec un `MatchManager` instancié :

- Déroulement complet d'une manche : distribution → 13 plis joués → calcul du score → émission des signaux attendus (`GameEvents`).
- Déroulement complet d'une partie : plusieurs manches jusqu'à ce qu'un joueur atteigne le score seuil, désignation correcte du vainqueur.
- Vérification que `SaveService` persiste et recharge correctement un état de partie/configuration.
- Simulation complète pilotée par 4 IA (`tests/integration/test_match_ai_simulation.gd`) : manche complète sans erreur (plusieurs seeds), partie complète jusqu'au seuil de points, déterminisme de bout en bout (même seed → même score final, même vainqueur) — voir docs/DECISIONS.md ADR-019.

## Tests end-to-end (Playwright)

À activer si un export **HTML5/Web** est produit (sinon cette section reste informative) :

- Lancement du jeu dans le navigateur, vérification que l'écran `Bootstrap` puis le menu principal s'affichent.
- Simulation d'une partie complète via les interactions UI (sélection de carte, validation).
- Vérification visuelle basique (captures d'écran) des écrans clés (table, fin de manche, fin de partie).

## Priorités

1. Règles du jeu (le cœur du gameplay, risque de bug élevé si mal testé).
2. Scoring (impact direct sur l'expérience et la victoire/défaite).
3. Orchestration de manche/partie (intégration).
4. IA (comportement valide, pas nécessairement optimal en MVP).
5. End-to-end (une fois l'UI stabilisée).

## Bonnes pratiques

- Tests déterministes : pas de dépendance au hasard non maîtrisé (utiliser un `RandomNumberGenerator` avec seed fixe dans les tests de mélange).
- Un test = un comportement, nommage explicite (`test_hearts_cannot_be_played_before_broken`).
- Éviter les tests fragiles couplés à des détails d'implémentation UI ; préférer tester `scripts/rules/` et `scripts/match/` directement.
