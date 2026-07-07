# Référence IA — Dame de pique

## Contexte IA (`build_ai_context`)

Champs utilisés par les stratégies :

```gdscript
{
  "player_index": int,
  "hand_number": int,
  "trick_number": int,
  "hearts_broken": bool,
  "is_leading": bool,
  "lead_suit": int,
  "trick_cards": Array,
  "hand_size": int,
  "hand_cards": Array[CardModel],
  "hand_raw_scores": Array,      # points manche en cours
  "match_scores": Array,
  "confidence": float,           # 0.0–1.0, AiPlayer
  "tricks_won_counts": Array,
  "consecutive_trick_wins": Array,
  "moon_busted": bool,           # 2+ joueurs avec points
  "moon_feasible": bool,         # MoonFeasibility.is_viable_for_player(...)
}
```

Enrichissement break : `moon_suspect_index`, `moon_suspect_score` dans `_enrich_break_context`.

## MoonFeasibility — API

| Fonction | Rôle |
|----------|------|
| `is_viable_for_player(...)` | Faisabilité globale pour un siège |
| `is_moon_busted_globally(tricks_taken)` | ≥ 2 joueurs avec points pénalité |
| `sole_penalty_collector_index(tricks_taken)` | Index si exactement 1 joueur a des points, sinon -1 |
| `another_player_has_penalty_points(...)` | Bloque la chasse pour les 3 autres |
| `compute_control_score(hand_cards)` | Contrôle distribution (hautes, longueur, gros cœurs) |

### Branches `is_viable_for_player`

1. **Global bust** (2+ joueurs) → false
2. **Autre joueur a des points** → false pour `player_index`
3. **Dame de Pique chez un adversaire** → false
4. **Tous les points déjà pris** → true seulement si ce joueur a les 26
5. **`our_captured == 0`** → ouverture / début de manche (contrôle + matériel cœurs)
6. **`our_captured > 0`** → maths restantes + couverture Dame + `_recovery_path_viable` (confiance + contrôle)

## MoonSuspicion

- `should_break_moon(context)` : score max ≥ `BREAK_THRESHOLD` (40) et pli ≥ `MIN_TRICK_TO_BREAK` (3)
- `find_top_suspect(context)` → `{ player_index, score }`
- Signaux : points en main adverse, plis gagnés, série de victoires, seul collecteur de pénalités

## AdaptiveAiStrategy — annonces

Structure `_pending_announcement` :

```gdscript
{
  "from_label": String,
  "to_label": String,
  "reason_key": String,           # more_aggressive | suspect_moon
  "player_index": int,
  "target_player_index": int,     # suspect_moon seulement
}
```

Consommée par `TableAiAnnouncement.play(ctx, announcement)` via `table_play_flow.gd`.

Reset par manche dans `_sync_hand` : compteurs annonces, `_was_chasing_moon`.

## Constantes à ajuster (équilibrage)

| Fichier | Constantes |
|---------|------------|
| `moon_feasibility.gd` | seuils contrôle ouverture/tôt/récupération, `RECOVERY_MIN_CONFIDENCE` |
| `adaptive_ai_strategy.gd` | `BOLD_MOON_CONFIDENCE`, `RECOVERY_MOON_CONFIDENCE`, seuils passive wakeup |
| `moon_suspicion.gd` | `BREAK_THRESHOLD`, poids signaux |
| `ai_confidence.gd` | boosts/pénalités fin de manche |
| `ai_personality_catalog.gd` | `USE_MIXED_PERSONALITIES` |

## Simulation & équilibre

```text
Godot --headless --path . res://simulation/simulation_main.tscn -- --count 1000 --seed 1
```

Résultats : `simulation/results/index.csv`. Viser ~22–29 % victoires par siège sur 4 IA adaptatives.

### Télémétrie décisions (pas seulement victoires)

Chaque run produit aussi :

| Fichier | Contenu |
|---------|---------|
| `telemetry.json` | Agrégats complets (Lune, regret, sacrifices, Dame…) |
| `telemetry_by_seat.csv` | Tableau par siège pour Excel |
| `telemetry_report.txt` | Rapport lisible (tableau prioritaire §13) |

Collecteur : `scripts/ai/ai_telemetry_collector.gd` — branché sur `MatchManager.telemetry`.

Métriques clés : tentatives/réussites Lune, taux détection, cassage, regret stratégique (estimation vs réalité), coût Lune ratée, rentabilité avec/sans tentative, sacrifices défensifs.

Voir [telemetry-metrics.md](telemetry-metrics.md) pour le catalogue complet aligné sur le cahier des charges.

## Tests obligatoires par changement

| Changement | Tests |
|------------|-------|
| Règles Lune | `test_moon_feasibility.gd` |
| Modes / annonces | `test_adaptive_ai_strategy.gd` |
| Suspicion | `test_moon_suspicion.gd` |
| Confiance | `test_ai_confidence.gd` |
| Copy i18n | `test_game_copy.gd`, `test_translation_coverage.gd` |

## ADR projet

Voir `docs/DECISIONS.md` — **ADR-023** (architecture IA gameplay).
