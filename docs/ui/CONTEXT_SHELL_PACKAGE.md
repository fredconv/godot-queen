# Context Shell — package fonctionnel

```
IDEAs: 00023 (sidebar) + 00024 (bottom bar) + 00025 (TogglePanel)
Status: READY — décisions validées 2026-07-21
Package name: Context Shell
```

Point d’entrée du package. Détails modules :  
[`CONTEXT_SIDEBAR_DESIGN.md`](CONTEXT_SIDEBAR_DESIGN.md) · [`CONTEXT_BOTTOM_BAR_DESIGN.md`](CONTEXT_BOTTOM_BAR_DESIGN.md) · [`TOGGLE_PANEL_PATTERN.md`](TOGGLE_PANEL_PATTERN.md)

---

## Décisions validées (2026-07-21)

1. **Un package, modules indépendants** — sidebar, bottom bar, TogglePanel, layout, Focus. Pas de scène/script monolithique.
2. **Petit écran** — bottom bar **ne disparaît pas** par défaut : mode **compact** (panneau, tour, réactions, menu « plus »). Masquage total seulement en **Focus** ou préférence explicite.
3. **Joueur actif** — source principale = **TopMenuBar + table** ; bottom bar = résumé compact uniquement (jamais unique source).
4. **ReactionPicker** — reste **flottant / indépendant** (IDEA-00022). Bottom bar : item « ouvrir ». Ouverture aussi sans barre (Focus, mobile, raccourci).
5. **Ordre d’implémentation** :
   1. Context Shell minimal + régions de layout  
   2. Coordination table / sidebar / bottom bar  
   3. Prototype sidebar toggle (TogglePanel)  
   4. Prototype bottom bar  
   5. Données réelles (`PublicGameUiSnapshot`)  
   6. Responsive  
   7. Mode Focus  
   8. MCP + documentation  

**Règle :** shell + containers **avant** bottom bar (éviter de refaire anchors/responsive).

---

## Modules (indépendants)

| Module | Rôle | Ne contient pas |
|--------|------|-----------------|
| `ContextShell` | Coordonne insets + hosts | Widgets métier Hearts |
| `ContextShellLayout` | Calcul largeur/hauteur / compact / focus | Tweens |
| `SidebarHost` | Slot panneau droit | Items bottom bar |
| `BottomBarHost` | Slot barre basse | Logique réactions |
| `TogglePanel` (00025) | Anim open/close | Définitions widgets |
| `ReactionPicker` | Emotes flottantes | Dépendance obligatoire à la barre |

---

## Phase courante

**a — Context Shell minimal** (en cours) :

- `ContextShellLayout` — insets / compact / focus
- `ContextShellHost` — `SidebarHost` + `BottomBarHost` + application d’insets
- Table : bind `PlayerSeats`, `TrickArea`, `HumanHandArea`, `AnimationLayer`
- `bottom_bar_slot_active = false` jusqu’à la phase **d** (ne pas manger la main)
- Propriété Focus produit = `shell_focus` (**pas** `focus_mode` — conflit `Control`)
- Insets : `apply_insets_to_offsets` respecte les ancres (TrickArea centré **ne doit pas** être écrasé)

Suivant : **b** coordination → **c** TogglePanel sidebar → **d** bottom bar.
