# État du projet — Dame de Pique (Hearts)

> **Dernière mise à jour :** juillet 2026  
> **Commit de référence :** `5dd612f` (`feat/simulation-batch`)  
> **Prochaine étape prévue :** Étape 8 — Audio & polish visuel (puis stabilisation / export)

Document destiné à une **relecture par un collègue** avant de poursuivre le développement. Il résume ce qui est implémenté, ce qui fonctionne en jeu, et les pistes d'amélioration identifiées.

---

## 1. Vue d'ensemble

| Élément | Détail |
|---|---|
| **Jeu** | Dame de Pique / Hearts — 4 joueurs, 52 cartes, 13 cartes par main |
| **Moteur** | Godot **4.7** (GL Compatibility, D3D12 sur Windows) |
| **Langage** | GDScript typé (pas de C#) |
| **Joueur** | 1 humain (siège 0) + 3 IA à personnalités mixtes (chasseur Lune, passive, équilibrée) |
| **Tests automatisés** | **181/181** GdUnit4 verts (unitaires + intégration) |
| **Jouabilité** | Partie complète jouable de bout en bout (menu → table → fin de partie) |
| **Dépôt** | `https://github.com/fredconv/godot-queen.git` |
| **Branche active** | `feat/simulation-batch` (à merger sur `main` après validation polish) |

---

## 2. Parcours utilisateur actuel

```
Bootstrap → Menu principal → Nouvelle partie → Table de jeu
     ↑              ↑                                    |
     |         SCORES / CONFIG / CRÉDITS / AIDE          |
     └──────── MENU (avec confirmation) ────────────────┘
```

### Menu principal (`scenes/menus/main_menu.tscn`)

- **NOUVELLE PARTIE** : charge la table de jeu.
- **SCORES** : overlay modal avec stats persistées (`StatsService`).
- **CONFIGURATION** : volumes, musique, thème table, langue (6 locales), pseudo.
- **CRÉDITS** / **AIDE** : overlays modaux.
- **QUITTER** : ferme l'application.
- Musique d'ambiance via `AudioService` (si activée dans `ConfigService`).
- Navigation clavier / manette (`UiFocusNav`).

### Table de jeu (`scenes/table/table.tscn`)

- Main humaine en éventail (cartes cliquables si coup légal).
- Cartes illégales : voile gris + position basse, non cliquables.
- Hints de tour : « 2 de Trèfle », « Cœurs pas défoncés », etc.
- Dos de cartes adverses, compteurs de main, surbrillance du joueur actif.
- Animations : distribution depuis les bords d'écran, pose de carte, surbrillance du vainqueur de pli, collecte du pli.
- **Historique des plis** : bouton PLIS dans la barre de menu (`TableTrickHistory`).
- **Annonces IA** : messages rares et observationnels (ex. suspicion de Lune) via `TableAiAnnouncement`.
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
  core/              # Suit, Rank, i18n, chemins textures/audio
  gameplay/cards/    # CardModel, Deck, PlayerHand
  rules/             # HeartsRules (constantes), RuleEngine (règles avec état)
  match/             # MatchManager, TrickManager, ScoreManager
  ai/                # AiPlayer, stratégies, MoonFeasibility, AdaptiveAiStrategy, télémétrie
  game_actions/      # PlayCardAction (préparation multijoueur)
  game_events/       # Événements sérialisables
  network/           # Lobby local, stubs réseau
  services/          # Autoloads (GameEvents, Audio, Config, Save, Stats, …)
  ui/                # table.gd, menus, modules table (annonces, historique plis)
  components/        # CardView, PlayerSeat, dialogs, scoreboard, menu bar
simulation/          # Outil batch headless (hors livrable, non référencé par project.godot)
```

### Principes respectés

- **`MatchManager` n'est pas un autoload** : cycle de vie lié à la scène table (`RefCounted`, instancié par `table.gd`). Voir `docs/DECISIONS.md` ADR-002.
- **Règles pures** dans `scripts/rules/` — pas de nœuds Godot.
- **Découplage par signaux** via l'autoload `GameEvents` (audio, session).
- **Pas de `print()`** dans le code jeu — `DebugService` / `push_warning` / `push_error`.

### Autoloads

| Autoload | Rôle |
|---|---|
| `GameEvents` | Bus de signaux (`match_started`, `card_played`, `trick_resolved`, …) |
| `GameSession` | Flag `match_in_progress` (via signaux `match_started` / `match_ended`) |
| `AudioService` | SFX + musique, écoute `GameEvents` |
| `ConfigService` | Volume, musique, langue, thème table — persistance via `SaveService` |
| `SaveService` | Lecture/écriture `user://savegame.json` (v1, migration) |
| `StatsService` | Statistiques locales (parties jouées / gagnées / perdues) |
| `PlayerProfileService` | Pseudo joueur, `player_id` stable |
| `DebugService` | Logging centralisé, flag debug |

---

## 4. Étapes livrées (ROADMAP)

| Étape | Statut | Contenu principal |
|---|---|---|
| **1 — Scaffolding** | ✅ | Arborescence, bootstrap, autoloads, documentation initiale |
| **2 — Modèle de données** | ✅ | CardModel, Deck, PlayerHand, GdUnit4 |
| **3 — Règles (moteur pur)** | ✅ | HeartsRules, RuleEngine, shoot the moon |
| **4 — MatchManager** | ✅ | Orchestration manche/partie, TrickManager, ScoreManager |
| **5 — IA** | ✅ | HeuristicStrategy, AiPlayer, personnalités mixtes, Lune (voir §5) |
| **6 — Table jouable** | ✅ | Câblage UI ↔ MatchManager, animations de pli |
| **7 — Menus & UX** | ✅ | Config, scores, crédits, profil, i18n 6 langues, `UiFocusNav` |
| **7.5 — Préparation multijoueur** | ✅ | Actions, snapshots, lobby local (phases 0–6) ; réseau ENet ⏳ |
| **8 — Audio & polish** | 🔄 | Thème pixel, UIBundleFree, overlays — reste audio final, mobile, icône |
| **9 — Stabilisation** | ⏳ | E2E, perf, tests UI ciblés |
| **10 — Export** | ⏳ | Preset Windows, build de validation |

---

## 5. IA avancée & simulation (extension étape 5)

Architecture documentée en **ADR-023** (`docs/DECISIONS.md`) :

| Module | Rôle |
|---|---|
| `MoonFeasibility` | Qui peut encore viser la Lune (règles + maths) |
| `MoonSuspicion` | Heuristique : quel adversaire semble dangereux |
| `AdaptiveAiStrategy` | Modes MINIMIZE / CHASE_MOON / BREAK_MOON, abandons nuancés |
| `MoonShooterStrategy` / `MoonBreakerStrategy` / `PassiveStrategy` | Exécution par profil |
| `AiTelemetryCollector` | Métriques Lune, regret, sacrifices (simulation batch) |

**Personnalités par défaut** (`AiPersonalityCatalog`, sièges 1–3) : chasseur Lune, passive, équilibrée. Revenir aux 3 IA équilibrées : `USE_MIXED_PERSONALITIES = false`.

**Outil batch** (`simulation/`, hors livrable) : lance N parties headless, archive résultats dans `simulation/results/`. Voir `simulation/README.md`.

**Documentation agent** : `AGENTS.md`, skill `.cursor/skills/dame-de-pique-ai-gameplay/`, règle `ai-gameplay.mdc`.

---

## 6. Règles Hearts implémentées

Conformes à `docs/GDD.md` et `docs/DECISIONS.md` (ADR-016) :

- 2 de Trèfle obligatoire au premier pli.
- Suivi de couleur obligatoire.
- Cœurs non défoncés : interdiction d'entamer avec un Cœur (sauf main 100 % Cœurs).
- Premier pli : pas de carte à points (sauf main 100 % cartes à points).
- Cœurs défoncés par Cœur ou Dame de Pique.
- Score : 1 pt/Cœur, 13 pts Dame de Pique, shoot the moon (0 pt / 26 pts aux autres).
- Fin de partie à **100 points** cumulés.

**Hors scope (non implémenté, documenté)** : passe de 3 cartes entre les manches (ADR-018).

---

## 7. Étape 8 — ce qui reste (polish store-ready)

| Fonctionnalité | État |
|---|---|
| Thème pixel, menus, overlays harmonisés | ✅ |
| Boutons NinePatch, labels lisibles (12 px) | ✅ |
| Sons : volumes finaux, transitions musique | ⏳ |
| Icône app + splash screen export Android | ⏳ |
| Tests ratios mobile / safe area | ⏳ |
| Polish animation distribution (timing, SFX) | ⏳ |
| Cartes pixel art dédiées | ⏳ optionnel post-MVP |

### Hors scope MVP (reporté)

| Fonctionnalité | État |
|---|---|
| Sauvegarde / reprise d'une **partie en cours** | ❌ |
| Multijoueur réseau (ENet, Steam) | ⏳ phase 7+ — voir `docs/MULTIPLAYER_DESIGN.md` |
| Sélecteur multi-ruleset (Spades, Whist, …) | 📋 après polish |
| Passe de 3 cartes | ❌ ADR-018 |

---

## 8. Tests

### Exécution

```powershell
cd C:\Projects\Godot\dame-de-pique
& "C:\chemin\Godot_v4.7-stable_win64_console.exe" --headless --path . `
  -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/
```

### Couverture actuelle

| Suite | Fichiers (exemples) | Cas |
|---|---|---|
| Unit — cartes/deck/main | `test_card_model`, `test_deck`, `test_player_hand` | 24 |
| Unit — règles | `test_rule_engine` | 33 |
| Unit — IA classique | `test_ai_player`, `test_ai_personalities` | 17 |
| Unit — IA Lune / adaptative | `test_moon_feasibility`, `test_adaptive_ai_strategy`, `test_moon_suspicion`, `test_ai_confidence`, `test_ai_telemetry_collector` | 36 |
| Unit — i18n, profil, save, MP prep | divers `test_*` | ~73 |
| Intégration — MatchManager | `test_match_manager` | 13 |
| Intégration — simulation IA | `test_match_ai_simulation`, `test_main_menu_scene` | 7 |
| **Total** | 32 suites | **181** |

### Non couvert (volontairement)

- Logique UI `table.gd` (animations async, couplage scène).
- Menus et popups (validation manuelle + `test_main_menu_scene` minimal).
- Rapports dans `reports/` (ignorés par Git).
- Simulation batch (outil dev, pas de tests GdUnit4 dédiés).

### Points d'attention connus

- Fuites mineures à la sortie des tests headless (`5 ObjectDB instances`, `2 resources`) — non bloquant.
- Pas de tests end-to-end navigateur (étape 9).

---

## 9. Dette technique & couplages identifiés

| Sujet | Détail | Priorité suggérée |
|---|---|---|
| **Règles couplées à Hearts** | `MatchManager` instancie `RuleEngine` en dur ; hints Hearts dans l'UI | Multi-ruleset (après étape 8) |
| **`table.gd` volumineux** | Contrôleur UI + orchestration modules table | Refactor progressif si besoin |
| **Menu : pas de sélecteur de jeu** | Un seul ruleset (Hearts) en dur | Planifié (section E de `CHECKLIST.md`) |
| **Calibrage IA Lune** | Taux rares validés par simulation multi-seeds | Itérer via `simulation/` |
| **Tests UI table** | Aucun scene runner dédié | Étape 9 |
| **Docs locales** | `PROJECT_STATUS` / `CHECKLIST` à tenir à jour à chaque jalon | Continu |

---

## 10. Vision planifiée (non implémentée)

- **Multi-ruleset** : wrapper `CardGameRules` autour du moteur Hearts existant (ne pas réécrire).
- **Multijoueur réseau** : ENet, synchro, reconnexion — phases 7+ (`docs/MULTIPLAYER_DESIGN.md`).
- **Steam** : notes exploratoires dans `docs/godot multiplayer steam.md`.
- **Second ruleset** (ex. Spades) : un fichier à la fois, après abstraction.

---

## 11. Pistes pour la review collègue

### Questions à se poser

1. **Règles** : comportement Hearts conforme (shoot the moon, 2♣, cœurs) ?
2. **UX table** : lisibilité cartes, hints, historique plis, annonces IA ?
3. **IA** : personnalités crédibles, chasse Lune ni trop rare ni trop fréquente ?
4. **Flux fin de partie** : pause, popups manche/partie, Rejouer ?
5. **Menus** : config, scores, i18n, navigation clavier ?
6. **Prêt export** : audio, mobile, icône ?

### Fichiers clés à lire en priorité

| Fichier | Pourquoi |
|---|---|
| `scripts/match/match_manager.gd` | Orchestration + contexte IA |
| `scripts/rules/rule_engine.gd` | Règles Hearts |
| `scripts/ai/adaptive_ai_strategy.gd` | Décision IA (modes, abandon Lune) |
| `scripts/ai/moon_feasibility.gd` | Faisabilité Lune |
| `scripts/ui/table.gd` | Contrôleur UI principal |
| `docs/DECISIONS.md` | ADR (dont ADR-023 IA) |
| `simulation/README.md` | Batch stats & télémétrie |

### Lancer le jeu localement

1. Godot 4.7 → ouvrir `project.godot`.
2. Scène principale : `scenes/bootstrap/bootstrap.tscn`.
3. F5 : menu → Nouvelle partie → jouer une manche complète.

---

## 12. Documentation projet existante

| Document | Contenu |
|---|---|
| `docs/GDD.md` | Game Design Document |
| `docs/TECHNICAL_DESIGN.md` | Architecture technique |
| `docs/ROADMAP.md` | Étapes de développement |
| `docs/DECISIONS.md` | Architecture Decision Records (ADR) |
| `docs/TEST_PLAN.md` | Stratégie et exécution des tests |
| `docs/CHECKLIST.md` | Suivi des tâches (fait / à faire / planifié) |
| `docs/MULTIPLAYER_DESIGN.md` | Design multijoueur (phases 0–7+) |
| `AGENTS.md` | Index skills / règles agent Cursor |
| `simulation/README.md` | Outil batch simulation IA |

---

## 13. Historique Git récent (résumé)

| Commit | Sujet |
|---|---|
| `5dd612f` | IA adaptative Lune, télémétrie, UX table (annonces, labels boutons) |
| `66d575c` | Personnalités IA mixtes (flag revert) |
| `53b0986` | Simulation batch : archive horodatée + index |
| `d45db34` | Gitignore artefacts import simulation/results |
| `4de9794` | Hardening table + typage GDScript |
| `4b4da42` | Étape 6 — table jouable |
