# Résultats des simulations

Ce dossier est **gitignored** (données locales). Chaque run crée un sous-dossier horodaté.

## Structure après un run

```text
simulation/results/
  index.csv              ← tableau de tous les runs (ouvrir dans Excel)
  index.json             ← même chose, format machine
  last_run.csv           ← copie du dernier run
  last_summary.json
  last_report.txt        ← rapport texte du dernier run
  runs/
    20260707_134500_count1000_seed1/
      matches.csv        ← 1 ligne par partie simulée
      summary.json       ← agrégats + métadonnées
      report.txt         ← rapport lisible
```

## Consulter l'historique

1. **Vue d'ensemble** : ouvrir `index.csv` (tous les runs, une ligne chacun).
2. **Détail d'un run** : suivre les chemins dans les colonnes `matches_csv` / `report_txt`.
3. **Dernier run** : fichiers `last_*` à la racine de `results/`.
