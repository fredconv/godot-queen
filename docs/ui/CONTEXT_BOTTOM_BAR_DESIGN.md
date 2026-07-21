# Bottom Context Bar modulaire — design brief

```
IDEA: IDEA-00024
Status: DOCUMENTED (Phase 0 — investigation)
Created: 2026-07-21
Last Updated: 2026-07-21
Package: Context Shell (avec IDEA-00023 Sidebar)
```

Document **dérivé** (pas d’implémentation). Spec produit : entrée INBOX `IDEA-00024`.  
Sibling : [`CONTEXT_SIDEBAR_DESIGN.md`](CONTEXT_SIDEBAR_DESIGN.md).

---

## Skills / rules consultés

Même socle que IDEA-00023 + :

| Source | Pertinence |
|--------|------------|
| `scripts/components/top_menu_bar.gd` | Barre **haute** = navigation ; ne pas dupliquer |
| `TableDisplay.refresh_turn_ui` | Statut tour déjà dans TopMenuBar / table |
| `MatchScoreboard` | Scores overlay — risque de triple affichage |
| IDEA-00022 `ReactionPicker` | Item « RÉACTIONS » = intention → picker existant |
| Theme `SmallHudButton` | Densité HUD pour items compacts |
| ADR-006 / `responsive-ui` | Hauteur barre vs main joueur (critique) |

**Absent :** aucune `bottom_bar/` ; pas de registry d’items status.

---

## État actuel

| Élément | Aujourd’hui | Risque si Bottom Bar |
|---------|-------------|----------------------|
| `TopMenuBar` | Tour, manche/partie pts, nav | **Duplication** tour/score si mal découpé |
| `MatchScoreboard` | Overlay scores | Triple score (top + board + bottom) |
| `ReactionPicker` | Bas-droite | Chevauchement hauteur / z-order avec barre |
| `MoonSuspicionButton` | Bas-droite | Même zone |
| Main 13 cartes | Bas centre | **Régression #1** : barre trop haute coupe la main |
| Sidebar 00023 | Pas encore | Doivent partager `PublicGameUiSnapshot` + layout |

### Contraintes

- Hauteur barre ≤ ~48–56 px (compact) / ~64 px max ; jamais scale global.
- Masquable sans bloquer le jeu.
- Même contrat données publiques que la sidebar (pas de secrets).
- Événementiel — pas de `_process` pour score/tour.

### Duplications potentielles

| Info | Top | Bottom (proposition) | Sidebar |
|------|-----|----------------------|---------|
| Tour | Message central TopMenuBar | Résumé compact + clic → onglet | Détail |
| Score | Optionnel / scores overlay | Synthèse manche\|partie | Historique / points |
| PLIS | Bouton nav | — | Widget historique |
| Réactions | — | Statut + ouvrir picker | Widget grille |

**Règle UX :** top = nav + message principal ; bottom = résumé + raccourcis ; sidebar = profondeur.

---

## Architecture proposée

Miroir de la sidebar, **plus légère** (items HBox, pas d’onglets) :

```text
scripts/ui/context_shell/     # package partagé 00023+00024 (recommandé)
  public_game_ui_snapshot.gd  # Resource / RefCounted — données publiques
scripts/ui/bottom_bar/
  bottom_context_bar.gd
  bottom_bar_layout_controller.gd  # priorités / overflow
  bottom_bar_item.gd               # contrat base
resources/ui/bottom_bar/
  bottom_bar_definition.gd
  bottom_bar_item_definition.gd
```

Pas d’autoload. Configuration via `BottomBarDefinition` injectée depuis le jeu (Hearts provider).

### Flux

```text
GameEvents / MatchManager
  → PublicGameUiSnapshot (build TableContext)
  → BottomContextBar.apply_snapshot(s)
  → items.refresh(s)
Items interactifs :
  sidebar_toggle_requested
  reaction_picker_requested
  open_sidebar_tab_requested(tab_id)
  quick_settings_requested
```

Lien sidebar : **signals uniquement** (pas `get_node` croisé).

---

## UX / responsive

| Mode | Contenu |
|------|---------|
| Large | Icône + label + valeur(s) + séparateurs |
| Moyen | Icône + valeur ; labels tooltips |
| Petit | Priorité critique seulement + overflow « … » |

Priorités MVP Hearts : **critique** Panneau, Tour ; **haute** Score, Couleur/cœurs ; **moyenne** Réactions, Aide ; **faible** ⚙ (réseau/timer = plus tard).

Animations : hover/clic courts ; respect « animations réduites ».

---

## MVP Hearts (items)

1. `SidebarToggleItem`  
2. `ScoreSummaryItem`  
3. `TurnStatusItem`  
4. `HeartsLeadOrBrokenItem` (couleur demandée **ou** cœurs sortis — un seul slot MVP)  
5. `ReactionsStatusItem` → ouvre picker 00022  
6. `ContextualHelpItem` → onglet aide sidebar (si 00023)  
7. `QuickSettingsItem` (sous-set audio/réactions/aide)

Hors MVP : ping, timer, réseau.

---

## Décisions humaines nécessaires

1. **Package unique** « Context Shell » (00023+00024) vs deux chantiers séparés ?  
2. **Hauteur / main** : barre toujours visible **ou** masquable par défaut en mobile ?  
3. **Tour** : retirer le message long du `TopMenuBar` pour ne le garder qu’en bas, **ou** top = phrase / bottom = icône+statut ?  
4. **Réactions** : garder picker flottant bas-droite **et** item barre, ou migrer entièrement vers barre+sidebar ?  
5. Ordre d’implémentation : **bottom bar d’abord** (raccourci panneau) puis sidebar, ou shell layout table d’abord ?

---

## Fichiers (prévision)

**Créer :** `bottom_bar/` + snapshot public partagé.  
**Modifier :** `table.tscn` layout (marge bas), éventuellement alléger TopMenuBar, ConfigService prefs.  
**Ne pas toucher :** `rules/`, `ai/`, logique score.

## Validation

MCP : large/moyen/petit ; panneau ouvert/fermé ; 13 cartes ; cooldown réactions ; modal ouverte ; DoD visuelle WORKFLOW ; GdUnit priorités + snapshot sans secrets.
