# Panneau contextuel modulaire (sidebar) — design brief

```
IDEA: IDEA-00023
Status: DOCUMENTED (Phase 0 — investigation)
Created: 2026-07-21
Last Updated: 2026-07-21
```

## Animation sidebar (contrainte produit — IDEA-00025)

Appliquer le pattern [`TOGGLE_PANEL_PATTERN.md`](TOGGLE_PANEL_PATTERN.md) :

- slide-in/out **180–250 / 150–220 ms**, ease-out / ease-in léger ;
- **aucun** rebond / élastique / zoom / rotation ;
- table `PUSH_CONTENT` synchronisée ;
- bouton toujours visible (`☰`/`▶` ↔ `✕`/`◀`) + tooltips FR ;
- `reduced_motion` → transition quasi instantanée.

Sibling package : [`CONTEXT_BOTTOM_BAR_DESIGN.md`](CONTEXT_BOTTOM_BAR_DESIGN.md) (**IDEA-00024**).  
Recommandation : un **Context Shell** partagé (`PublicGameUiSnapshot` + layout table) avant widgets profonds.

Document **dérivé** (pas d’implémentation). Spec produit : entrée INBOX `IDEA-00023`.  
Validation humaine requise avant Phase 1–2 (prototype).

---

## Skills / rules consultés

| Source | Pertinence |
|--------|------------|
| `AGENTS.md` | Index skills projet |
| `.cursor/rules/godot.mdc` | Archi DDP, pas d’autoload gameplay, ADR-002 |
| `.cursor/rules/idee-capture.mdc` | Capture seule — pas d’auto-implémentation |
| `.cursor/rules/dame-de-pique-mcp-loop.mdc` + skill `dame-de-pique-mcp-playtest` | DoD visuelle MCP |
| `docs/WORKFLOW.md` | DoD UI, gate MCP |
| `docs/TECHNICAL_DESIGN.md` | Table, UILayer, responsive ADR-006 |
| `docs/DECISIONS.md` | ADR-002, 004, 006, 007, 008 |
| skill `godot-pixel-ui-button` | Theme / StyleBox / pas de sprites externes |
| skill `dame-de-pique-multiplayer` | Host autoritaire ; widgets = intentions seulement |
| skill perso `component-system`, `event-bus`, `responsive-ui`, `godot-brainstorming` | Patterns génériques |
| IDEA-00022 Réactions | À réutiliser comme widget / raccourci, pas à fusionner dans `table.gd` |

**Absent aujourd’hui :** aucun `sidebar/`, aucun registry de widgets, aucun système d’onglets table générique.

---

## État actuel (cartographie)

### Scènes / UI table

| Élément | Rôle | Relation future sidebar |
|---------|------|-------------------------|
| `scenes/table/table.tscn` | Plateau + `UILayer` | Host layout table↔sidebar |
| `TopMenuBar` | Règles, scores, PLIS, nouveau, menu | PLIS / SCORES peuvent devenir onglets ou rester raccourcis |
| `MatchScoreboard` | Scores cumulés overlay | Candidat widget « manche » (lecture seule) |
| `TableTrickHistory` | Overlay historique plis | **Premier widget réel** (extraire overlay → widget) |
| `ReactionPicker` | Bas-droite emotes | Widget + raccourci hors panel |
| `MoonSuspicionButton` | Social multi | Hors MVP sidebar ou onglet social plus tard |
| Dialogs / ScoresScreen | Modales | Ne pas empiler sous sidebar ouverte sans règles z-order |

### Données / bus

- Source de vérité gameplay : `MatchManager` (pas autoload) + `GameEvents`
- UI table : `TableContext` (injection locale) — **pattern à réutiliser** pour `SidebarWidgetContext`
- Pas de modèle « public observation snapshot » dédié aujourd’hui (à créer pour detective / cartes sorties)

### Contraintes

- ADR-006 : 1280×720, mobile paysage, pas scale global seul
- ADR-008 / polish : StyleBox / Theme / `_draw()`, pas nouveaux PNG structure
- ADR-004 : widgets ≠ règles ; pas de `if game == HEARTS` dans le host
- Secrets : jamais mains adverses / état IA interne

---

## Architecture proposée (recommandation)

**Host local + definitions Resource + widgets scènes** — pas de nouvel autoload.

```text
scripts/ui/sidebar/          # host générique (futur card engine)
  context_sidebar.gd
  sidebar_layout_controller.gd
  sidebar_registry.gd        # RefCounted / static helpers, pas autoload
resources/ui/sidebar/
  sidebar_definition.gd      # Resource
  sidebar_widget_definition.gd
scenes/ui/sidebar/
  context_sidebar.tscn
scripts/ui/sidebar/widgets/base/
  sidebar_widget.gd          # contrat (méthodes refresh/cleanup)
scenes/.../widgets/hearts/   # DDP only
  trick_history_widget.*
  hand_info_widget.*
```

### Flux de données

```text
MatchManager / GameEvents
        ↓ (événements publics)
TableContext ou PublicMatchView (snapshot lecture seule)
        ↓ injecté
SidebarWidgetContext
        ↓
SidebarWidget.refresh(context)
        ↓ (intentions seulement)
reaction_requested / open_rules_requested → ReactionManager / UI existante
```

### Responsive (stratégie)

| Breakpoint (largeur) | Comportement |
|----------------------|--------------|
| ≥ ~1100 px | Sidebar dock droite, table shrink |
| ~800–1100 | Sidebar étroite / icônes + tooltips |
| < ~800 | Drawer overlay (ferme au clic hors / Esc) |

Persistance MVP : `ConfigService` — `sidebar_open: bool`, `sidebar_last_tab: StringName` uniquement.

---

## Widgets MVP (ordre)

| # | Widget | Bénéfice | Difficulté | Risque |
|---|--------|----------|------------|--------|
| 1 | Shell open/close + 1 onglet placeholder | Valide layout | ★★☆ | Chevauchement main / scoreboard |
| 2 | Historique des plis (extraire `TableTrickHistory`) | Remplace overlay PLIS | ★★★ | Régression UX PLIS |
| 3 | Infos manche (faits publics) | Remplace/complète scoreboard partiel | ★★☆ | Doublon HUD |
| 4 | Réactions (host → `ReactionManager`) | Cohérence IDEA-00022 | ★★☆ | Double UI picker |
| 5 | Aide contextuelle (légalité / règles) | Onboarding | ★★★ | Ne pas « jouer à la place » |

---

## Alternatives rejetées (pour l’instant)

| Alternative | Pourquoi non |
|-------------|--------------|
| Autoload `SidebarService` | Contredit « pas de manager global » ; cycle de vie = table |
| Tout coder dans `table.gd` | God object ; non multi-jeux |
| Sidebar obligatoire | Contredit confort optionnel |
| Detective « connaître Dame » via état IA | Fuite d’info secrète |

---

## Décisions humaines nécessaires

1. **Priorité relative** vs ROADMAP mobile (00019) / polish restant ?
2. **PLIS bouton** : reste overlay **ou** ouvre l’onglet historique de la sidebar ?
3. **Réactions** : rester bas-droite seul **ou** aussi onglet sidebar (les deux) ?
4. **Scope Phase 2** : prototype shell seul OK avant tout widget Hearts ?

---

## Fichiers (prévision — ne pas créer avant validation Phase 1)

**Créer (plus tard) :** arborescence `sidebar/` + definitions Resource + 1–2 widgets Hearts.  
**Modifier (plus tard) :** `table.tscn` / layout, éventuellement `ConfigService`, i18n.  
**Ne pas toucher :** `scripts/rules/**`, `scripts/ai/**`, `MatchManager` règles.

---

## Plan de validation (quand implémenté)

Recette MCP dédiée : fermé / ouvert / compact / overlay mobile / pendant pli / pendant modal ; DoD visuelle WORKFLOW ; GdUnit contrat widget + pas de fuite secrets sur snapshot public.
