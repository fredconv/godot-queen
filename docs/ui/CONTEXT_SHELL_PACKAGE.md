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

**b — Coordination table / sidebar / bottom bar** (en cours) :

- `UiLayoutSnapshot` — restore Focus (phase g)
- `ContextShellHost.mount_*` + content roots
- `TableContextShell` — bouton ▶/◀, hamburger → toggle shell, dock `MatchScoreboard`, Escape

Suivant : **c** TogglePanel (anim slide) → **d** bottom bar.
