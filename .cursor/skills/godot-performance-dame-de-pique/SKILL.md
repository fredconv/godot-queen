---
name: godot-performance-dame-de-pique
description: >-
  Godot performance tips filtered for Dame de Pique (2D card/UI game, GDScript,
  no physics). Use when optimizing frame rate, loading, or reviewing perf-related
  changes. Skip physics plugins unless the project gains physics gameplay.
---

# Performance — Dame de pique

> Premature optimization is often a big time waster. Use complicated tricks on an as-needed basis.

Ce projet : **jeu de cartes 2D**, logique pure GDScript, **aucun** `CharacterBody` / `Area2D` / `move_and_slide`. La majorité des astuces « physics » de la vidéo Godot 4.3 **ne s'appliquent pas** ici.

## Matrice d'applicabilité

| Astuce | Pertinent ? | Action projet |
|--------|-------------|---------------|
| Jolt (3D) | Non | Déjà dans `project.godot` mais inutilisé — ignorer |
| Rapier (2D) | Non | Pas de physique 2D — ne pas installer |
| Physics tick rate / interpolation | Non | Aucune simulation physique |
| Moins de colliders | Non | — |
| `move_and_slide` / soft collisions | Non | — |
| C++ / C# / Rust | Non | GDScript par convention (`docs/DECISIONS.md`) |
| Solver iterations / physics thread | Non | — |
| Multithreading / compute shaders | Non* | *Sauf besoin futur massif (milliers d'entités) |
| **Classes util Godot** | **Oui** | `Geometry2D`, `Rect2`, `Packed*Array`, `Tween`, etc. |
| **Preload / cache ressources** | **Oui** | Textures UI, cartes, scènes instanciées souvent |
| Pixel Snap + Nearest filter | **Oui** | Déjà activé — voir skill `godot-pixel-ui-button` |
| Profilage avant optim | **Oui** | Éditeur → Moniteur / Profiler |

## Règles actives pour ce repo

### 1. Preload plutôt que `load()` en boucle

**À preload** (const de classe ou `@export`) :
- Scènes instanciées souvent (`card_view.tscn`, `pixel_button.tscn`)
- Thème UI (`pixel_theme.tres`)
- Textures NinePatch boutons (3 états)
- Dos de carte

**`load()` acceptable** :
- Audio chargé à la demande (`AudioService`)
- Assets rares / écran unique

**Cache en mémoire** pour textures répétées :
- `CardTexturePaths` — cache par chemin (52 cartes max)
- Éviter `load()` à chaque coup joué

### 2. Préférer les utilitaires moteur

En logique chaude (validation coups, tri mains, scoring) :
- Utiliser APIs C++ du moteur plutôt que réimplémenter en GDScript
- `PackedInt32Array`, `Array.sort_custom`, `Geometry2D`, comparaisons natives

### 3. UI / rendu 2D

- Pas de filtre linéaire sur pixel art
- Limiter les `StyleBox` / overrides dynamiques par frame
- Tweens `offset_transform_*` plutôt que recréer des nœuds (Godot 4.7)
- Éviter `visible = false` sur enfants de `Container` si ça force un recalcul layout inutile

### 4. Instanciation

```gdscript
# Bon
const CardViewScene: PackedScene = preload("res://scenes/components/card_view.tscn")
var view := CardViewScene.instantiate()

# À éviter en boucle
var view := load("res://...").instantiate()
```

## Quand réévaluer

Installer Rapier / baisser tick rate **seulement si** :
- mini-jeux avec physique 2D
- particules/collisions interactives

Passer en C# **seulement si** demandé explicitement et profilage prouve un goulot GDScript.

## Checklist agent (avant PR perf)

1. Profiler ou reproduire le lag concret
2. Vérifier `load()` dans `_process` / boucles de jeu
3. Vérifier instanciation répétée de scènes sans pool
4. Ne pas toucher `project.godot` physics sans justification
5. Tests GdUnit4 inchangés ou mis à jour

## Fichiers sensibles perf

| Fichier | Risque |
|---------|--------|
| `scripts/core/card_texture_paths.gd` | `load()` par carte → cache |
| `scripts/components/ui/pixel_button.gd` | textures bouton → preload |
| `scripts/core/ui/ui_style_factory.gd` | atlas `load()` → cache si hot path |
| `scripts/ui/table/*.gd` | animations / instanciation cartes |
| `scripts/services/audio_service.gd` | OK lazy load |

## Référence vidéo (contexte)

Source : tips Godot 4.3 (physics-heavy). Conserver ce skill comme **filtre projet** : ne pas appliquer aveuglément toute la liste.
