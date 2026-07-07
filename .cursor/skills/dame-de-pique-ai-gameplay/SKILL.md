---
name: dame-de-pique-ai-gameplay
description: >-
  Hearts AI for Dame de Pique: moon feasibility, suspicion, personalities,
  adaptive modes, player-facing messages, and MatchManager context. Use when
  changing scripts/ai/, moon logic, AI banners, confidence, simulation balance,
  or personality switching.
---

# IA & gameplay — Dame de pique

Guide pour modifier l'IA, les messages table et les changements de tactique sans casser l'architecture (règles pures / match / UI).

## Architecture (3 couches)

| Couche | Rôle | Fichiers clés |
|--------|------|----------------|
| **Faisabilité** | Qui *peut* encore viser la Lune (règles + maths) | `moon_feasibility.gd` |
| **Décision** | Qui *veut* chasser / casser / minimiser | `adaptive_ai_strategy.gd`, `moon_suspicion.gd` |
| **Exécution** | Quelle carte jouer | `moon_shooter_strategy.gd`, `moon_breaker_strategy.gd`, `passive_strategy.gd`, `heuristic_strategy.gd` |
| **Présentation** | Messages rares, jamais la tactique complète | `table_ai_announcement.gd`, `game_copy.gd`, `translations/table.csv` |

`MatchManager.build_ai_context()` est le **seul** point d'injection du contexte IA.

## Modes de jeu (`AiPlayMode`)

Hiérarchie dans `AdaptiveAiStrategy._select_play_mode()` :

1. `moon_busted` → **MINIMIZE** (tous)
2. suspicion adverse forte → **BREAK_MOON** (silencieux côté jeu)
3. `moon_feasible` + personnalité/confiance → **CHASE_MOON**
4. sinon → **MINIMIZE** (+ personnalité passive / fallback)

## Règles Lune (faisabilité)

| Situation | Chasse possible ? |
|-----------|-------------------|
| 0 joueur avec points | Tous (si contrôle + confiance) |
| **1 seul** avec points | **Lui seul** ; les 3 autres **non** |
| **2+** avec points | **Personne** (`is_moon_busted_globally`) |
| Adversaire a la Dame de Pique | Non pour les autres |

Perte accidentelle d'un pli ≠ tentative de Lune : exiger contrôle de main + confiance (`_recovery_path_viable`, seuils dans `adaptive_ai_strategy.gd`).

Détail complet : [reference.md](reference.md)

## Messages joueur (ne jamais dévoiler la tactique)

| `reason_key` | Message | Quand |
|--------------|---------|-------|
| `more_aggressive` | « %s devient plus agressif. » | Entrée en ligne plus audacieuse |
| `suspect_moon` | « %s pense que %s vise la Lune. » | Lecture adverse (pas « je casse la Lune ») |

**Interdits** : annoncer la Lune, annoncer qu'on la casse, bulle d'intention à chaque pli.

**Limites** : max **1** bandeau / manche, espacement ≥ **5** plis (`MAX_ANNOUNCEMENTS_PER_HAND`, `ANNOUNCE_MIN_TRICK_INTERVAL`).

Clés : `TableKeys.AI_STRATEGY_*` → `translations/table.csv`.

## Personnalités

| Kind | Chasse Lune | Notes |
|------|-------------|-------|
| `MOON_HUNTER` | Si `moon_feasible` | Avec points en main : confiance ≥ `RECOVERY_MOON_CONFIDENCE` |
| `BALANCED` | Si faisable + confiance | Seuil plus haut si points en main |
| `PASSIVE` | Jamais | Peut « se réveiller » → `more_aggressive` + `HeuristicStrategy` |

Catalogue : `ai_personality_catalog.gd` — flag `USE_MIXED_PERSONALITIES` pour revenir à tout `HeuristicStrategy`.

Confiance : `ai_confidence.gd` — mise à jour fin de manche dans `MatchManager`.

## Workflow agent

### Avant de coder

1. Lire [reference.md](reference.md) si la règle touche la Lune ou les messages.
2. Pour calibrer l'IA : lire [telemetry-metrics.md](telemetry-metrics.md) et lancer une simulation.
3. Décider : faisabilité (`MoonFeasibility`) vs volonté (`AdaptiveAiStrategy`) vs UI.
3. Ne pas mettre de règles Hearts dans `scripts/services/` ni dans l'UI table directement.

### Après modification

1. Tests unitaires : `tests/unit/test_moon_feasibility.gd`, `test_adaptive_ai_strategy.gd`, `test_moon_suspicion.gd`.
2. Si équilibre : simulation 1000 parties (`simulation/`).
3. Vérifier traductions (6 langues dans `table.csv` / `dialogs.csv`).

Checklist : [checklist.md](checklist.md)

## Subagents recommandés

| Subagent | Usage |
|----------|--------|
| `explore` | Cartographier `scripts/ai/`, contexte `build_ai_context`, flux annonces |
| `generalPurpose` | Batch simulation, analyse `simulation/results/` |
| `bugbot` | Revue PR touchant faisabilité Lune ou messages |
| `shell` | Lancer GdUnit4 headless ou sim `--count 1000` |

Ne pas lancer `bugbot` sauf demande explicite.

## Fichiers à ne pas confondre

- `moon_feasibility.gd` — **peut-on** encore ?
- `moon_suspicion.gd` — **qui** semble dangereux ?
- `adaptive_ai_strategy.gd` — **que fait-on** + annonces
- `table_ai_thinking.gd` — obsolète (pas d'intention par pli)
