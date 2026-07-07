# Simulation batch — Dame de Pique

Outil **hors livrable** : ce dossier n'est pas référencé par `project.godot` (pas d'autoload, pas de scène). Tu peux le supprimer ou l'exclure des presets d'export sans impacter le jeu.

## GDScript ou Python ?

| | **GDScript (recommandé)** | **Python** |
|---|---|---|
| **Moteur de jeu** | Réutilise `MatchManager`, `RuleEngine`, `AiPlayer` — **identique au jeu** | Il faudrait **réécrire** toutes les règles Hearts, ou lancer Godot en sous-processus |
| **Setup** | Déjà en place (`tests/integration/test_match_ai_simulation.gd` fait la même chose pour 1 partie) | Dépendances externes, duplication ou glue fragile |
| **Perf 1000 parties** | ~quelques secondes en headless (RefCounted, pas de rendu) | Lent si 1000× subprocess Godot ; rapide seulement si moteur réimplémenté |
| **Évolution** | Une modification des règles IA se propage automatiquement | Risque de divergence avec le vrai jeu |

**Conclusion :** pour des stats fiables (« est-ce toujours le même bot qui gagne ? »), **GDScript headless** est le choix naturel sur ce projet. Python reste utile en **post-traitement** (pandas, graphiques) sur le CSV exporté.

## Lancer une simulation

Depuis la racine du projet, avec Godot 4.7 :

```powershell
& "C:\chemin\vers\Godot_v4.7-stable_win64.exe" `
  --headless --path . `
  res://simulation/simulation_main.tscn `
  -- --count 1000 --seed 1 --csv simulation/results/last_run.csv
```

Arguments après `--` :

| Argument | Défaut | Description |
|----------|--------|-------------|
| `--count` | 1000 | Nombre de parties |
| `--seed` | 1 | Première seed (chaque partie utilise `seed + index`) |
| `--csv` | (aucun) | Chemin CSV optionnel |

## Interpréter les résultats

- **4 IA identiques** (`HeuristicStrategy`) avec seeds **différentes** par siège → les taux de victoire devraient être **proches de 25 %** chacun si le hasard distribution / tie-break est équilibré.
- Un siège qui domine (> 35–40 % sur 1000 parties) peut indiquer un **biais** (stratégie, ordre de jeu, convention siège 0, etc.) — piste d'équilibrage IA.
- Compare des stratégies en modifiant `MatchSimulator.strategy_factory` dans un script dérivé.

## Exclure du livrable

1. Ne pas ajouter ce dossier aux scènes exportées (rien à faire si tu n'y touches pas).
2. Dans l'éditeur : **Projet → Exporter → Filtres → Exclure** → ajouter `simulation/`.
3. Ou supprimer le dossier avant release : `rm -r simulation/`.

## Fichiers

```
simulation/
  README.md
  simulation_main.tscn   # entrée CLI (charge les autoloads)
  simulation_main.gd
  lib/
    match_simulator.gd  # 1 partie complète, 4 IA
    batch_stats.gd      # agrégation + rapport texte
  results/              # CSV générés (gitignored)
```

## Lien avec les tests existants

`tests/integration/test_match_ai_simulation.gd` valide déjà qu'une partie 4-IA se termine sans erreur. Ce dossier **étend** ce pattern en batch + statistiques, sans polluer GdUnit4 ni le build jeu.
