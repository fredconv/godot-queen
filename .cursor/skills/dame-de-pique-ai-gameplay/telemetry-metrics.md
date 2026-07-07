# Métriques télémétrie IA — Dame de pique

Catalogue des statistiques collectées par `AiTelemetryCollector` lors des simulations.

## 1. Générales (par siège)

- Parties, manches, victoires, 2e/3e/4e places
- Score final moyen, manches moyennes avant victoire
- Score moyen par manche (points bruts)

## 2. Lune — tentatives

- `moon_attempts`, `moon_successes`, `moon_success_rate`
- Tentatives haute probabilité (≥ 70 %), basse (< 40 %)

## 3. Lune — détection

- `moon_detected`, `moon_undetected`, `moon_detection_rate`
- `avg_detection_trick` (pli moyen de première détection adverse)

## 4. Lune — cassage

- `moons_broken`, `broken_first_heart`, `broken_queen`, `broken_lost_trick`
- `moon_break_rate_on_detected` = cassées / détectées

## 5. Qualité des décisions

- Compteurs haute/basse probabilité à l'entrée en `CHASE_MOON`
- **Regret stratégique** : buckets `0.0-0.4`, `0.4-0.7`, `0.7-1.0` — tentatives vs réussites réelles

## 6. Après échec de Lune

- `avg_score_after_failed_moon` (coût moyen en points bruts)
- `failed_moon_rank_distribution` (classement en fin de partie)
- Rempli à `end_match` pour chaque tentative ratée

## 7. Rentabilité

- `avg_hand_score_with_attempt` vs `avg_hand_score_without_attempt`

## 8. Détection par l'IA (lecture)

- `detections_made` (fois où l'IA émet une lecture `suspect_moon`)

## 9. Cassage défensif

- `break_actions`, `break_success_rate`
- `sacrifice_points`, `sacrifice_events` (points pris volontairement en mode `BREAK_MOON`)

## 10. Contrôle

- `avg_tricks_won_per_hand`, `max_consecutive_trick_streak`

## 11. Dame de Pique

- `queen_taken`, `queen_held_to_end`, `queen_broke_moon`

## 12. Tableau prioritaire (dans `telemetry_report.txt`)

Victoires, score/manche, Lunes tentées, taux réussite, détection, cassage, coût échec, rentabilité avec/sans tentative, sacrifices.

## Non encore instrumenté (évolutions)

- Vidage de couleur (première couleur vidée, pli, impact) — nécessite suivi des renonces par pli
- Cassage « attend / ne fait rien » explicite — distinguer modes passifs vs break actif

## Fichiers code

- `scripts/ai/ai_telemetry_collector.gd` — collecte
- `scripts/ai/ai_telemetry_report.gd` — rapports
- `scripts/ai/moon_feasibility.gd` — `estimate_success_probability()`
- `scripts/match/match_manager.gd` — hooks `telemetry`
