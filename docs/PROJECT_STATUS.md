# État du projet — Dame de Pique (Hearts)

> **Dernière mise à jour :** juillet 2026  
> **Commit de référence :** `4de9794` (`main`)  
> **Prochaine étape prévue :** Étape 7 — Menus & UX

Document destiné à une **relecture par un collègue** avant de poursuivre le développement. Il résume ce qui est implémenté, ce qui fonctionne en jeu, et les pistes d’amélioration identifiées.

---

## 1. Vue d’ensemble

| Élément | Détail |
|---|---|
| **Jeu** | Dame de Pique / Hearts — 4 joueurs, 52 cartes, 13 cartes par main |
| **Moteur** | Godot **4.7** (GL Compatibility, D3D12 sur Windows) |
| **Langage** | GDScript typé (pas de C#) |
| **Joueur** | 1 humain (siège 0, bas de table) + 3 IA (`HeuristicStrategy`) |
| **Tests automatisés** | **88/88** GdUnit4 verts (unitaires + intégration) |
| **Jouabilité** | Partie complète jouable de bout en bout (menu → table → fin de partie) |
| **Dépôt** | `https://github.com/fredconv/godot-queen.git` |

---

## 2. Parcours utilisateur actuel

```
Bootstrap → Menu principal → Nouvelle partie → Table de jeu
                ↑                                    |
                └──────── MENU (avec confirmation) ──┘
```

### Menu principal (`scenes/menus/main_menu.tscn`)

- **NOUVELLE PARTIE** : charge la table de jeu.
- **SCORES** / **CONFIGURATION** : recouvrement modal provisoire « à venir ».
- **QUITTER** : ferme l’application.
- Musique d’ambiance via `AudioService` (si activée dans `ConfigService`).

### Table de jeu (`scenes/table/table.tscn`)

- Main humaine en éventail (cartes cliquables si coup légal).
- Cartes illégales : voile gris + position basse, non cliquables.
- Hints de tour : « 2 de Trèfle », « Cœurs pas défoncés », etc.
- Dos de cartes adverses, compteurs de main, surbrillance du joueur actif.
- Animations : distribution depuis les bords d’écran, pose de carte, surbrillance du vainqueur de pli, collecte du pli.
- **Scores** :
  - Sous chaque avatar : points de **manche** `(N)` + cœurs capturés `♥ N`.
  - Panneau haut-droite + barre centrale : scores **cumulés** de partie (objectif 100 pts).
- **Fin de manche** : popup `HandEndDialog` → « Manche suivante ».
- **Fin de partie** : pause 4,5 s sur le dernier pli, puis popup `MatchEndDialog` (Rejouer / Quitter).
- **MENU** : retour au menu avec confirmation si partie en cours (`GameSession`).

---

## 3. Architecture logicielle

### Séparation des responsabilités

```
scripts/
  core/              # Suit, Rank, chemins textures/audio
  gameplay/cards/    # CardModel, Deck, PlayerHand
  rules/             # HeartsRules (constantes), RuleEngine (règles avec état)
  match/             # MatchManager, TrickManager, ScoreManager
  ai/                # AiPlayer, AiStrategy, HeuristicStrategy, RandomLegalStrategy
  services/          # Autoloads (GameEvents, Audio, Config, Save, Debug, GameSession)
  ui/                # table.gd, table_animations.gd, main_menu.gd
  components/        # CardView, PlayerSeat, dialogs, scoreboard, menu bar
```

### Principes respectés

- **`MatchManager` n’est pas un autoload** : cycle de vie lié à la scène table (`RefCounted`, instancié par `table.gd`). Voir `docs/DECISIONS.md` ADR-002.
- **Règles pures** dans `scripts/rules/` — pas de nœuds Godot.
- **Découplage par signaux** via l’autoload `GameEvents` (audio, session).
- **Pas de `print()`** dans le code jeu — `DebugService` / `push_warning` / `push_error`.

### Autoloads

| Autoload | Rôle |
|---|---|
| `GameEvents` | Bus de signaux (`match_started`, `card_played`, `trick_resolved`, …) |
| `GameSession` | Flag `match_in_progress` (via signaux `match_started` / `match_ended`) |
| `AudioService` | SFX + musique, écoute `GameEvents` |
| `ConfigService` | Volume, musique, langue — persistance via `SaveService` |
| `SaveService` | Lecture/écriture `user://savegame.json` |
| `DebugService` | Logging centralisé, flag debug |

---

## 4. Étapes livrées (ROADMAP)

| Étape | Statut | Contenu principal |
|---|---|---|
| **1 — Scaffolding** | ✅ | Arborescence, bootstrap, autoloads, documentation initiale |
| **2 — Modèle de données** | ✅ | CardModel, Deck, PlayerHand, GdUnit4, 24 tests unitaires |
| **3 — Règles (moteur pur)** | ✅ | HeartsRules, RuleEngine, shoot the moon, 33 tests règles |
| **4 — MatchManager** | ✅ | Orchestration manche/partie, TrickManager, ScoreManager, 11 tests intégration |
| **5 — IA** | ✅ | HeuristicStrategy, AiPlayer, 17 tests IA + 5 tests simulation complète |
| **6 — Table jouable** | ✅ | Câblage UI ↔ MatchManager, animations de pli |
| **7 — Menus & UX** | ⏳ | Partiellement anticipé (voir section 6) |

### Livraisons au-delà de l’étape 6 (anticipations & correctifs)

Ces éléments ne sont pas tous listés dans `ROADMAP.md` mais sont **déjà en production** :

- Popup fin de **manche** (`HandEndDialog`) et tooltips scores avatars.
- Séparation scores manche / scores partie (`MatchScoreboard`).
- Animation de **distribution** des cartes depuis les bords d’écran.
- Hints UI pour règles Hearts (2♣, cœurs non défoncés).
- **Hardening** pré-étape 7 (`4de9794`) :
  - Garde-fous `await` / sortie de scène dans `table.gd`.
  - Changement de scène différé (`call_deferred`).
  - Typage GDScript renforcé (`Array[PlayerSeat]`, `Phase`, signal `CardModel`).
  - `class_name PlayerSeat`, relayout dos de cartes au `resized`.
- **Context7 MCP** pour documentation Godot 4.7 (config locale, non versionnée — voir `.cursor/mcp.example.json`).

---

## 5. Règles Hearts implémentées

Conformes à `docs/GDD.md` et `docs/DECISIONS.md` (ADR-016) :

- 2 de Trèfle obligatoire au premier pli.
- Suivi de couleur obligatoire.
- Cœurs non défoncés : interdiction d’entamer avec un Cœur (sauf main 100 % Cœurs).
- Premier pli : pas de carte à points (sauf main 100 % cartes à points).
- Cœurs défoncés par Cœur ou Dame de Pique.
- Score : 1 pt/Cœur, 13 pts Dame de Pique, shoot the moon (0 pt / 26 pts aux autres).
- Fin de partie à **100 points** cumulés.

**Hors scope (non implémenté, documenté)** : passe de 3 cartes entre les manches (ADR-018).

---

## 6. Étape 7 — ce qui existe déjà vs ce qui reste

### Déjà en place (anticipation partielle)

| Fonctionnalité | État |
|---|---|
| Menu principal navigable | ✅ Basique |
| Retour menu depuis la table | ✅ Avec confirmation |
| Popups fin de manche / fin de partie | ✅ |
| `ConfigService` (volume, musique, langue) | ✅ Persistance JSON |
| `SaveService` (fichier JSON) | ✅ API générique |
| Contrôles musique sur la table | ✅ Toggle + piste suivante |

### À faire pour clôturer l’étape 7

| Fonctionnalité | État |
|---|---|
| Écran **Scores** détaillé (historique, stats) | ❌ Stub « à venir » |
| Écran **Configuration** complet (volume, langue, UI) | ❌ Stub « à venir » |
| Sauvegarde de **progression de partie** (reprise) | ❌ Non prévu MVP actuel |
| Localisation (fichiers de traduction) | ❌ Constantes FR en dur |
| Accessibilité menus (navigation clavier/manette) | ❌ Partiel |
| Tests UI / menus | ❌ Non automatisés |

---

## 7. Tests

### Exécution

```powershell
# Depuis la racine du projet (adapter le chemin Godot)
& "C:\chemin\Godot_v4.7-stable_win64.exe" --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/
```

### Couverture actuelle

| Suite | Fichiers | Cas |
|---|---|---|
| Unit — cartes/deck/main | `test_card_model`, `test_deck`, `test_player_hand` | 24 |
| Unit — règles | `test_rule_engine` | 33 |
| Unit — IA | `test_ai_player` | 17 |
| Intégration — MatchManager | `test_match_manager` | 11 |
| Intégration — simulation IA | `test_match_ai_simulation` | 5 |
| **Total** | | **88** |

### Non couvert (volontairement)

- Logique UI `table.gd` (animations async, couplage scène).
- Menus et popups (validation manuelle).
- Rapports dans `reports/` (ignorés par Git).

### Points d’attention connus

- Fuites mineures à la sortie des tests headless (`5 ObjectDB instances`, `2 resources`) — non bloquant.
- Pas de tests end-to-end navigateur (étape 9).

---

## 8. Dette technique & couplages identifiés

Points utiles pour une **review constructive** :

| Sujet | Détail | Priorité suggérée |
|---|---|---|
| **Règles couplées à Hearts** | `MatchManager` instancie `RuleEngine` en dur ; `table.gd` contient des hints Hearts | Après étape 7 (étape 7.5 — multi-ruleset) |
| **`table.gd` volumineux** (~600 lignes) | Contrôleur UI + animations + boucle IA | Refactor progressif si besoin |
| **`GameEvents.score_updated`** | Émis mais non consommé par l’UI (lecture directe de `MatchManager`) | Cosmétique / cohérence |
| **Menu : pas de sélecteur de jeu** | Un seul ruleset (Hearts) en dur | Prévu étape 7 + vision multi-jeux |
| **IA Hearts-only** | `HeuristicStrategy` spécifique au jeu | Normal tant qu’un seul ruleset |
| **Tests UI** | Aucun test GdUnit4 scène table | Étape 9 ou ciblé si régression |

---

## 9. Vision planifiée (non implémentée)

Décision d’architecture **documentée en discussion**, à traiter **après l’étape 7** :

- Préparer le support de **plusieurs jeux de cartes** (Spades, Whist, Bridge simplifié, etc.) avec le même moteur/UI.
- **Ne pas réécrire** le moteur Hearts actuel : wrapper + injection progressive.
- **Étape 7** : sélecteur de ruleset dans le menu (Hearts seul jouable, autres « Bientôt disponible »).
- **Étape 7.5** : interface `CardGameRules` + injection dans `MatchManager`.
- ADR formel à rédiger dans `docs/DECISIONS.md` quand l’implémentation démarre.

---

## 10. Pistes pour la review collègue

### Questions à se poser

1. **Règles** : le comportement Hearts correspond-il à la variante attendue (shoot the moon, 2♣, cœurs) ?
2. **UX table** : lisibilité des cartes non jouables, hints, scores manche vs partie ?
3. **Flux fin de partie** : pause 4,5 s, popups manche/partie, bouton Rejouer ?
4. **Architecture** : la séparation rules / match / UI est-elle suffisante pour évoluer ?
5. **Tests** : couverture logique suffisante pour itérer sur les menus sans régression ?
6. **Étape 7** : quoi prioriser — config complète, scores, sélecteur multi-jeux, accessibilité ?

### Fichiers clés à lire en priorité

| Fichier | Pourquoi |
|---|---|
| `scripts/match/match_manager.gd` | Cœur de l’orchestration |
| `scripts/rules/rule_engine.gd` | Toutes les règles Hearts |
| `scripts/ui/table.gd` | Contrôleur UI principal |
| `scripts/ai/heuristic_strategy.gd` | Comportement IA adverse |
| `docs/DECISIONS.md` | Choix d’architecture (ADR) |
| `docs/TECHNICAL_DESIGN.md` | Design technique détaillé |

### Lancer le jeu localement

1. Godot 4.7 → ouvrir `project.godot`.
2. Scène principale : `scenes/bootstrap/bootstrap.tscn`.
3. F6 : menu → Nouvelle partie → jouer une manche complète.

---

## 11. Documentation projet existante

| Document | Contenu |
|---|---|
| `docs/GDD.md` | Game Design Document |
| `docs/TECHNICAL_DESIGN.md` | Architecture technique |
| `docs/ROADMAP.md` | Étapes de développement |
| `docs/DECISIONS.md` | Architecture Decision Records (ADR) |
| `docs/TEST_PLAN.md` | Stratégie et exécution des tests |
| `docs/CHECKLIST.md` | Suivi des tâches (fait / à faire / planifié) |

---

## 12. Historique Git récent (résumé)

| Commit | Sujet |
|---|---|
| `4de9794` | Hardening table + typage GDScript |
| `7422a18` | Context7 MCP (doc Godot) |
| `78877f3` | Animation distribution cartes |
| `5960af2` | Popup fin de manche + tooltips |
| `4b4da42` | Étape 6 — table jouable |
| `979d2a4` | Étape 5 — IA heuristique |
| `4bdf6a3` | Initialisation du dépôt (étapes 1–4) |
