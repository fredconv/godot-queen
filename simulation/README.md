# Simulation batch — Dame de Pique

Outil **hors livrable** : ce dossier n'est pas référencé par `project.godot` (pas d'autoload, pas de scène). Tu peux le supprimer ou l'exclure des presets d'export sans impacter le jeu.

## Personnalités IA (adversaires)

Par défaut (`scripts/ai/ai_personality_catalog.gd`) :

| Siège | Personnalité |
|-------|----------------|
| 1 | Chasseur de lune (`MoonShooterStrategy`) |
| 2 | Passive (`PassiveStrategy`) |
| 3 | Équilibrée (`HeuristicStrategy`) |

**Revenir aux 3 IA équilibrées** : dans `ai_personality_catalog.gd`, passer :

```gdscript
const USE_MIXED_PERSONALITIES: bool = false
```

Le mode est enregistré dans `index.csv` (colonne `personality_mode`).

## Lancer une simulation

```powershell
& "C:\chemin\vers\Godot_v4.7-stable_win64.exe" `
  --headless --path . `
  res://simulation/simulation_main.tscn `
  -- --count 1000 --seed 1
```

Arguments : `--count` (défaut 1000), `--seed` (défaut 1).

## Fichiers enregistrés (historique consultable)

Chaque run est **archivé** dans `simulation/results/` :

| Fichier | Rôle |
|---------|------|
| `index.csv` | **Index de tous les runs** — ouvrir dans Excel pour comparer dans le temps |
| `index.json` | Même index, format JSON |
| `last_run.csv` / `last_summary.json` / `last_report.txt` | Copie du **dernier** run |
| `runs/<id>/matches.csv` | Détail : 1 ligne par partie |
| `runs/<id>/summary.json` | Agrégats du run (taux de victoire, scores moyens…) |
| `runs/<id>/report.txt` | Rapport texte lisible |

Exemple d'id de dossier : `20260707_134500_count1000_seed1`

Voir aussi `simulation/results/README.md`.

## Interpréter les résultats

- 4 IA `HeuristicStrategy`, seeds différentes par siège → taux de victoire attendus ~25 % chacun.
- Écart durable (> 30–35 % sur 1000+ parties) → piste de biais (stratégie, ordre de jeu, siège).
- Modifier `MatchSimulator.strategy_factory` pour comparer des IA.

## Exclure du livrable

1. Exclure `simulation/` dans les presets d'export Godot.
2. Ou supprimer le dossier avant release.

## Fichiers code

```
simulation/
  simulation_main.tscn / .gd
  lib/match_simulator.gd
  lib/batch_stats.gd
  lib/simulation_archive.gd
  results/          ← données locales (gitignored sauf README)
```
