# UI Pattern — Toggle / Sliding Panel

```
IDEA: IDEA-00025
Status: DOCUMENTED (pattern — pas d’implémentation)
Created: 2026-07-21
Last Updated: 2026-07-21
Scope: Creative OS / Card Game Framework (+ Dame de Pique Context Shell 00023–00024)
```

Pattern **transversal** pour tout panneau ouvrable / fermable / coulissant.  
Les sidebars, drawers, aides, réactions, scores détaillés et paramètres rapides **réutilisent** ce composant au lieu de réinventer Tween + états.

---

## Skills / rules alignés

| Source | Note |
|--------|------|
| `godot.mdc` / ADR-008 | Pixel, sobriété — **pas** de bounce / élastique |
| `WORKFLOW.md` DoD visuelle | Captures fermé / ouvrant / ouvert + reduced motion |
| `CONTEXT_SIDEBAR_DESIGN.md` | Consommateur principal (edge RIGHT) |
| `CONTEXT_BOTTOM_BAR_DESIGN.md` | Toggle sidebar via item ; pas un slide panel lui-même |
| Theme / `UiStyleFactory` | Chrome or ; pas de sprites externes structure |
| Config | Prévoir `reduced_motion` (à brancher ConfigService si absent) |

**Existant à ne pas confondre :** tweens ponctuels (`MoonSuspicion`, avatars BOUNCE) — hors scope ; le pattern TogglePanel **interdit** TRANS_BOUNCE / BACK excessif.

---

## États

```text
CLOSED → OPENING → OPEN → CLOSING → CLOSED
```

Pas de booléen seul si ça provoque des états incohérents.  
Pendant OPENING/CLOSING : ignorer double open/close ; permettre reverse propre ; un seul Tween actif (`kill` avant nouveau).

---

## Animation (défaut — premium sobre)

| Sens | Durée | Easing | Notes |
|------|-------|--------|-------|
| Open | **180–250 ms** | `TRANS_QUAD` / `EASE_OUT` | Slide depuis le bord ; fade contenu léger ; layout push fluide |
| Close | **150–220 ms** | `EASE_IN` ou `EASE_IN_OUT` léger | Symétrique ; table récupère largeur |

**Interdit :** rebond, élastique, zoom fort, rotation, pulsation infinie, blur.

**`reduced_motion` :** durée ~0–50 ms ou instantané ; pas de slide long ; pas de scale.

---

## API conceptuelle

```text
PanelEdge: LEFT | RIGHT | TOP | BOTTOM
PanelDisplayMode: PUSH_CONTENT | OVERLAY | DOCKED | AUTO
```

AUTO : large → PUSH ; moyen → compact ; mobile → OVERLAY.

Signals : `open_requested`, `close_requested`, `toggle_requested`, `opening_started`, `opened`, `closing_started`, `closed`, `state_changed(state)`.

Méthodes : `configure(def)`, `open()`, `close()`, `toggle()`, `set_display_mode()`, `set_reduced_motion()`.

Resource optionnelle : `TogglePanelDefinition` (id, edge, mode, sizes, durées, escape/overlay, persist).

---

## Bouton toggle

Toujours visible. Icônes procédurales / labels (pas emoji OS obligatoires) :

| État | Icône indicative | Tooltip |
|------|------------------|---------|
| Fermé | `☰` ou `▶` | Ouvrir le panneau |
| Ouvert | `✕` ou `◀` | Fermer le panneau |

États bouton : normal, hover, pressed, focus, disabled, opening/closing.  
Changement d’icône animé (swap court ou crossfade), pas de rebond.

---

## Overlay / focus / z-order

- Overlay optionnel ; clic dehors + Escape ferment si configuré.
- Focus : mémoriser avant open ; restaurer sur close.
- Modales critiques **au-dessus** des toggle panels ; pas d’overlay concurrent anarchique.

---

## Consommateurs prévus (DDP + framework)

1. Sidebar droite (00023)  
2. Aide / règles drawer  
3. Réactions (si un jour drawer)  
4. Historique plis (si extrait de overlay)  
5. Paramètres rapides  
6. Drawer mobile bas  

---

## Backlog widgets / layouts (hors MVP — capitalisé ici)

Ne pas créer une IDEA par ligne. Implémenter seulement après shell stable.

| Idée | Priorité relative | Notes |
|------|-------------------|--------|
| Widgets favoris (checkbox) | Later | Persistance Config |
| Widgets épinglés | Later | Zone fixe + onglets |
| Recherche widgets | Later | Si N widgets grand |
| Wiki / règles in-game | P2 | Lié aide contextuelle |
| Assistant débutant (pourquoi illégal) | P2 | Snapshot public only |
| Replay dernier pli | Later | Réutilise anim table |
| Graphiques fin de manche | Later | StyleBox / bars natives |
| Défis / succès | Later | Notifications discrètes |
| Lecteur musique | Later | AudioService existant |
| Collection tapis/dos/avatars | Later | Cosmétiques |
| Profil IA | Later | Lecture seule catalogue |
| Stats détaillées | Later | StatsService |
| Ping / sync multi | Later | Network |
| Journal type Discord | Later | Event log public |
| **Dockable** L/R/Masqué | P2 après TogglePanel | Peu coûteux si Containers |
| Drag reorder widgets | Later | Pas MVP |
| **Layout UI presets** (Compact / Analyse / Streamer / Débutant) | **Fort** framework | Profils d’interface moteur |

---

## Validation MCP (composant)

Fermé · mid-open si capture frames · ouvert · large/moyen/étroit · reduced_motion · Escape · clic overlay · spam toggle · resize mid-anim · popup ouverte · changement scène · DoD visuelle WORKFLOW.

## Régressions clés

Panneau à moitié bloqué · double Tween · layout jump · mouse_filter fantôme · focus perdu · bouton hors écran · overlay orphelin · état après reload scène.
