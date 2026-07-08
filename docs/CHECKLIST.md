# Checklist projet — Dame de Pique

> **Dernière mise à jour :** juillet 2026  
> **Commit de référence :** `5dd612f`  
> **Étape courante :** **étape 8** (audio & polish) — étapes 1 à 7.5 validées

Fichier de **continuité** : si le projet est mis en pause, reprendre ici pour savoir où on en est.

**Légende :** ✅ fait · 🔄 en cours · ⏳ à faire · 📋 planifié (décision prise, pas encore codé) · ❌ hors scope MVP

---

## A. Étapes ROADMAP

| # | Étape | Statut | Notes |
|---|---|---|---|
| 1 | Scaffolding | ✅ | Arborescence, bootstrap, autoloads, docs |
| 2 | Modèle de données & tests | ✅ | CardModel, Deck, PlayerHand, GdUnit4 |
| 3 | Règles (moteur pur) | ✅ | HeartsRules, RuleEngine, 33 tests |
| 4 | MatchManager | ✅ | Orchestration, tests intégration |
| 5 | IA de base + extension Lune | ✅ | HeuristicStrategy, AdaptiveAiStrategy, personnalités, télémétrie |
| 6 | Interface table jouable | ✅ | table.gd ↔ MatchManager, animations pli |
| 7 | Menus & UX | ✅ | Config, scores, crédits, profil, i18n, UiFocusNav |
| 7.5 | Préparation multijoueur (phases 0–6) | ✅ | Actions, snapshots, lobby local |
| 8 | Audio & polish visuel | 🔄 | Thème livré ; reste audio final, mobile, icône |
| 9 | Tests E2E & stabilisation | ⏳ | |
| 10 | Export & distribution | ⏳ | Windows prioritaire |

---

## B. Étape 7 — Menus & UX (clôturée)

### B.1 Livré

- [x] Menu principal (`main_menu.tscn`) avec navigation complète
- [x] Bootstrap → menu
- [x] Bouton NOUVELLE PARTIE → table
- [x] Bouton QUITTER
- [x] Retour MENU depuis la table (confirmation si partie en cours)
- [x] `GameSession` synchronisé via `GameEvents`
- [x] Popup fin de **manche** (`HandEndDialog`)
- [x] Popup fin de **partie** (`MatchEndDialog`) — Rejouer / Quitter
- [x] **Écran Configuration** complet (volumes, musique, thème table, langue, pseudo)
- [x] **Écran Scores** (`StatsService` : parties jouées / gagnées / perdues, taux victoire)
- [x] Écrans Crédits, Aide, configuration profil
- [x] `ConfigService` + `SaveService` v1 (migration JSON)
- [x] Contrôles musique sur la barre de menu table
- [x] Internationalisation : 6 locales (fr, en, de, es, pt, zh), CSV modulaires
- [x] `LocaleAware` + rafraîchissement immédiat à la fermeture Configuration
- [x] Navigation clavier / manette (`UiFocusNav`) sur menus et overlays
- [x] Labels boutons NinePatch lisibles (`NINE_PATCH_BUTTON_FONT_SIZE = 12`)

### B.2 Reporté (hors étape 7)

- [ ] **Sélecteur de ruleset** dans le menu (voir section E)
- [ ] Sauvegarde / reprise d'une **partie en cours** (mid-game) — ❌ MVP
- [ ] Multijoueur réseau — ❌ MVP (préparation faite, voir section H)
- [ ] Passe de 3 cartes — ❌ ADR-018

---

## C. IA avancée & simulation (extension étape 5)

### C.1 Livré (`5dd612f`)

- [x] `MoonFeasibility`, `MoonSuspicion`, `AdaptiveAiStrategy` (ADR-023)
- [x] `MoonShooterStrategy`, `MoonBreakerStrategy`, `PassiveStrategy`
- [x] Personnalités mixtes par siège (`AiPersonalityCatalog`, flag `USE_MIXED_PERSONALITIES`)
- [x] Abandon nuancé de la chasse Lune (seuils par profil)
- [x] `AiTelemetryCollector` + rapports simulation
- [x] Annonces table (`TableAiAnnouncement`) — messages rares, observationnels
- [x] Historique des plis (`TableTrickHistory`, bouton PLIS)
- [x] Tests : `test_moon_feasibility`, `test_adaptive_ai_strategy`, `test_moon_suspicion`, `test_ai_confidence`, `test_ai_telemetry_collector`
- [x] Outil batch `simulation/` (hors livrable, archive `simulation/results/`)

### C.2 Itérations possibles

- [ ] Calibrage multi-seeds (batch 1000+ parties × plusieurs seeds)
- [ ] Cassage Lune imparfait côté défenseurs (plus de nuance)
- [ ] Merger `feat/simulation-batch` → `main` après validation polish

---

## D. Correctifs & hardening récents (faits)

- [x] Cartes non jouables : voile gris
- [x] Scores avatars synchronisés pendant la manche
- [x] Séparation scores manche (avatars) vs cumul partie (scoreboard)
- [x] Hints tour : 2♣, cœurs non défoncés
- [x] Pause 4,5 s sur dernier pli avant popup fin de partie
- [x] Animation distribution depuis bords d'écran
- [x] Garde-fous sortie de scène (`_scene_exiting`, `is_inside_tree()` après `await`)
- [x] Typage GDScript renforcé
- [x] `class_name PlayerSeat` + relayout au `resized`

---

## E. Planifié — Multi-jeux / multi-rulesets (après étape 8)

### E.1 Documentation / stubs

- [ ] Rédiger **ADR multi-ruleset** dans `docs/DECISIONS.md`
- [ ] Créer stub `RulesetDefinition` (Resource) + `.tres` Hearts uniquement
- [ ] Lister rulesets futurs en data (`enabled: false`)

### E.2 Intégration menu

- [ ] `RulesetRegistry` : résolution par id + fallback Hearts
- [ ] UI sélecteur + panneau règles
- [ ] Persistance `ruleset_id` dans `ConfigService`

### E.3 Abstraction moteur (étape 7.5+ rulesets)

- [ ] Interface `CardGameRules`
- [ ] `HeartsRuleset` : wrapper autour de `RuleEngine` / `HeartsRules`
- [ ] Injection dans `MatchManager`
- [ ] Déplacer hints UI Hearts de `table.gd` vers le ruleset

---

## F. Étape 8 — Audio & polish (en cours)

- [x] Thème `pixel_theme.tres`, UIBundleFree medieval, overlays harmonisés
- [x] Barre menu table compacte, icônes + boutons texte
- [x] Navigation clavier / manette sur table et menus
- [ ] Revue complète intégration `AudioService` (tous les SFX mappés)
- [ ] Volumes finaux, transitions musique
- [ ] Icône app + splash screen export Android
- [ ] Tests ratios mobile / safe area
- [ ] Polish animation distribution : timing / son
- [ ] Cartes pixel art dédiées (optionnel post-MVP)

---

## G. Étape 9 — Stabilisation (à faire)

- [ ] Tests end-to-end (export web + Playwright si applicable)
- [ ] Investiguer fuites ObjectDB à la sortie tests headless
- [ ] Tests UI ciblés (GdUnit4 scene runner sur table)
- [ ] Revue performance (allocations, tweens, rebuild main)
- [ ] Validation manuelle parcours complet après chaque gros changement

---

## H. Étape 10 — Export (à faire)

- [ ] Preset export Windows
- [ ] Build de validation
- [ ] Export web (optionnel, pour E2E)

---

## I. Multijoueur réseau (phases 7+, planifié)

- [x] Phases 0–6 : actions, événements, snapshots, lobby local (`docs/MULTIPLAYER_DESIGN.md`)
- [ ] Phase 7+ : ENet, synchro manche, reconnexion
- [ ] Steam / GodotSteam (notes : `docs/godot multiplayer steam.md`)

---

## J. Infrastructure & outillage (faits)

- [x] GdUnit4 installé (`addons/gdUnit4/`)
- [x] **181** tests automatisés verts (32 suites)
- [x] Godot MCP (Coding-Solo) — `.cursor/mcp.example.json`
- [x] Context7 MCP — doc Godot 4.7 (config locale gitignorée)
- [x] Règles Cursor (`godot.mdc`, `ai-gameplay.mdc`)
- [x] Skill IA gameplay + `AGENTS.md`
- [x] Simulation batch (`simulation/`)

---

## K. Revue collègue — checklist rapide

- [ ] Partie Hearts jouable sans bug bloquant (1 manche + 1 partie complète)
- [ ] Règles conformes au GDD (2♣, cœurs, shoot the moon, 100 pts)
- [ ] Scores manche / partie compréhensibles
- [ ] Popups fin manche / fin partie OK
- [ ] Retour menu sans crash (y compris pendant animation)
- [ ] Config + scores + i18n OK
- [ ] 181 tests GdUnit4 verts
- [ ] IA crédible (personnalités, annonces rares)
- [ ] Priorités étape 8 validées (audio ? mobile ? export ?)

---

## L. Commandes utiles (reprise après pause)

### Lancer les tests

```powershell
cd C:\Projects\Godot\dame-de-pique
& "C:\Users\fredc\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" `
  --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/
```

### Simulation batch (équilibre IA)

```powershell
& "C:\Users\fredc\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" `
  --headless --path . res://simulation/simulation_main.tscn -- --count 1000 --seed 1
```

### Ouvrir le projet

- Godot 4.7 → `project.godot`
- Scène principale : `scenes/bootstrap/bootstrap.tscn`

### Git — état attendu

- Branche de travail : `feat/simulation-batch` (merge `main` en attente)
- Dernier commit stable : `5dd612f`
- Fichiers non versionnés normaux : `reports/`, `simulation/results/last_*`, `simulation/results/index.csv`, `.cursor/mcp.json`

---

## M. Journal des sessions (à compléter)

| Date | Commit | Travail effectué | Prochaine action |
|---|---|---|---|
| 2026-07-08 | `5dd612f` | IA adaptative Lune, télémétrie, annonces table, labels boutons, doc | Polish étape 8 (audio, icône) ; batch multi-seeds |
| 2026-07 | `66d575c` | Personnalités IA mixtes + simulation batch | Calibrage chasseur Lune |
| 2026-07 | `4de9794` | Hardening table, typage, Context7 | Menus & UX (étape 7) |
| 2026-07 | `4b4da42` | Table jouable (étape 6) | UX scores, popups, animations |
| — | — | *(ajouter une ligne à chaque session)* | — |

---

## N. Références rapides

| Besoin | Fichier |
|---|---|
| Résumé complet pour review | `docs/PROJECT_STATUS.md` |
| Design jeu | `docs/GDD.md` |
| Architecture technique | `docs/TECHNICAL_DESIGN.md` |
| Décisions d'architecture | `docs/DECISIONS.md` (ADR-023 IA) |
| Plan de tests | `docs/TEST_PLAN.md` |
| Étapes officielles | `docs/ROADMAP.md` |
| Simulation IA | `simulation/README.md` |
| Index agent | `AGENTS.md` |
