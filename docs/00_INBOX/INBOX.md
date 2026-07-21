# Documentation Inbox — Dame de Pique

```
Version : V01
Created : 2026-07-21
Last Updated : 2026-07-21
Status : Active
Next ID : IDEA-00026
```

**Purpose:** Flux append-only d’idées. L’agent = **Project Manager IA** — voir [`../WORKFLOW.md`](../WORKFLOW.md).

**Capture** (`idée:` · `suggestion:` · `feature:` · …) → rule [`.cursor/rules/idee-capture.mdc`](../../.cursor/rules/idee-capture.mdc) — **jamais** d’auto-implémentation. Pour coder : `implémente:` ou choix explicite.

**Anti-pattern :** ne pas créer un `.md` par idée. Une entrée ici → living docs ailleurs. Vue backlog = [`KANBAN.md`](KANBAN.md) + [`BACKLOG_PRIORITY.md`](BACKLOG_PRIORITY.md).

**ID :** `IDEA-XXXX` (4 digits). Incrémenter **Next ID** après assignation.

**Statuts :** `DOCUMENTED` → `READY` → `IN_PROGRESS` → `TESTED` → `WAITING_USER_VALIDATION` → `DONE` → `RELEASED` | `ARCHIVED` | `REJECTED`

**Audit source :** [`../QUALITY-AUDIT.md`](../QUALITY-AUDIT.md)

---

## CURRENT FOCUS

| ID | Title | Status | Next Action |
|----|-------|--------|-------------|
| **00023–00025** | **Context Shell** | READY — phase a layout | implémenter shell |
| **00022** | **Réactions table** | DONE (MCP + GdUnit) | playtest humain optionnel |
| 00021 | Polish visuel natif | DONE | — |
| 00010 | Lobby UI split | DONE (MCP + GdUnit) | playtest LAN optionnel |
| 00014 | kill tweens carte | DOCUMENTED | si bug anim |

---

## Entry format

```markdown
## IDEA-XXXX — YYYY-MM-DD — Titre
- **Statut:** …
- **Decision:** — | Accepted | Rejected | Deferred
- **Origin:** chat | audit
- **Motivation:** …
- **Impact:** ★★★☆☆
- **Complexité:** ★★★☆☆
- **Priorité proposée:** P0 | P1 | P2 | Later
- **Epic:** Architecture | UI/Polish | Table/Feel | Multiplayer | Hygiene | Audio | Mobile | Tooling
- **Depends on:** —
- **Living Documents:** …
- **Next Action:** …
- **Ready checklist:** [ ] Documenté [ ] Impacts [ ] Specs [ ] Pas de blocker [ ] Depends OK [ ] Pas règles/IA sans OK
- **Notes:** …
```

---

## DOCUMENTED — PRIORITÉ

## IDEA-00025 — 2026-07-21 — Pattern Toggle / Sliding Panel (standard UI)

- **Statut:** READY
- **Decision:** Accepted — fondation Context Shell ; slide sobre sans bounce
- **Origin:** chat `idée` (anim sidebar premium + panneau générique + backlog widgets/layouts)
- **Motivation:** Un composant réutilisable (états CLOSED/OPENING/OPEN/CLOSING, slide sobre 180–250 ms, reduced_motion, edge L/R/T/B, PUSH/OVERLAY/DOCKED/AUTO) pour toute UI rétractable — pas une anim ad hoc par écran. Capitalise aussi favoris, layouts Compact/Analyse/Streamer/Débutant, dockable, etc. en backlog.
- **Impact:** ★★★★★ (framework cartes / Creative OS)
- **Complexité:** ★★★☆☆ (composant + tests) ; layouts/widgets = Later
- **Priorité proposée:** P1 — **fondation** avant/avec Context Shell 00023–00024
- **Epic:** Architecture (+ UI/Polish)
- **Depends on:** Theme pixel ; Config `reduced_motion` (à ajouter si absent) ; consommé par 00023/00024
- **Living Documents:** [`../ui/TOGGLE_PANEL_PATTERN.md`](../ui/TOGGLE_PANEL_PATTERN.md)
- **Next Action:** Phase **c** TogglePanel sidebar après phase a–b layout OK
- **Ready checklist:** [x] Documenté [x] Impacts [x] Specs pattern [x] Pas de blocker [ ] Depends Config reduced_motion [x] Pas règles/IA
- **Notes:** Interdit bounce/élastique. Bouton toujours visible. Backlog widgets (wiki, replay, défis, journal, favoris, drag-reorder, presets layout) listé dans le living doc — **pas** d’IDEA séparée par item.

## IDEA-00024 — 2026-07-21 — Bottom Context Bar modulaire (moteur cartes)

- **Statut:** READY
- **Decision:** Accepted — package Context Shell ; compact sur petit écran ; Focus/préférence pour hide ; tour jamais unique ; picker flottant
- **Origin:** chat `idée` (mockup barre basse + brief multi-jeux)
- **Motivation:** Résumé / raccourcis sous la table ; ouvre sidebar ; réactions ; statuts secondaires ; optionnelle ; multi-jeux via definitions — sans logique Hearts dans le host.
- **Impact:** ★★★★☆
- **Complexité:** ★★★☆☆ (items + priorités responsive + hauteur vs main)
- **Priorité proposée:** P1 — **couplée à 00023** (Context Shell)
- **Epic:** Architecture (+ UI/Polish, Table/Feel)
- **Depends on:** IDEA-00023 (sidebar) pour toggle/onglets ; IDEA-00022 (réactions) ; ADR-006 hauteur main ; **IDEA-00025** (TogglePanel pour anim ouverture)
- **Living Documents:** [`../ui/CONTEXT_BOTTOM_BAR_DESIGN.md`](../ui/CONTEXT_BOTTOM_BAR_DESIGN.md)
- **Next Action:** Après shell + sidebar toggle : prototype bottom bar (phase **d**) ; slot `bottom_bar_slot_active` alors
- **Ready checklist:** [x] Documenté [x] Impacts [x] Specs Phase 0 [x] Pas de blocker conceptuel [x] Depends OK (ordre shell) [x] Pas règles/IA sans OK
- **Notes:** Risque #1 = barre qui mange la main. Snapshot public partagé avec sidebar. MVP : Panneau, Score, Tour, Couleur/Cœurs, Réactions, Aide, ⚙. Pas réseau/timer au MVP.

## IDEA-00023 — 2026-07-21 — Panneau contextuel latéral modulaire (moteur cartes)

- **Statut:** READY
- **Decision:** Accepted — package Context Shell avec 00024/00025 ; modules séparés
- **Origin:** chat `idée:` (brief architecture multi-jeux + mockup)
- **Motivation:** Sidebar rétractable droite = confort / analyse / widgets ; réutilisable hors Hearts (Belote, Poker, …) ; optionnelle ; pas de secrets ; pas de god-object table.
- **Impact:** ★★★★★
- **Complexité:** ★★★★☆ (shell + registry + responsive + widgets)
- **Priorité proposée:** P1 (après validation archi) — Later si focus mobile/export
- **Epic:** Architecture (+ UI/Polish, Table/Feel)
- **Depends on:** IDEA-00022 ; ADR-002/004/006/008 ; **IDEA-00024** ; **IDEA-00025** (anim / TogglePanel)
- **Living Documents:** [`../ui/CONTEXT_SIDEBAR_DESIGN.md`](../ui/CONTEXT_SIDEBAR_DESIGN.md) · [`../ui/TOGGLE_PANEL_PATTERN.md`](../ui/TOGGLE_PANEL_PATTERN.md)
- **Next Action:** Phase **a** en cours (ContextShellHost + insets) → puis **b** coordination → **c** TogglePanel
- **Ready checklist:** [x] Documenté [x] Impacts [x] Specs Phase 0 [x] Pas de blocker conceptuel [x] Depends OK (ordre shell) [x] Pas règles/IA sans OK
- **Notes:** Aucune sidebar existante. Réutiliser `TableContext` / `GameEvents` / `TableTrickHistory` / `ReactionPicker` / Theme pixel. MVP widgets : shell → historique plis → infos manche → réactions → aide. Pas d’autoload. Pas d’`if game_type`.

## IDEA-00021 — 2026-07-21 — Polish visuel natif Godot (épic)

- **Statut:** DONE
- **Decision:** Accepted — playtest cartes OK ; pass visible menus 2026-07-21
- **Origin:** chat `idée prioritaire` (brief polish 12 étapes)
- **Motivation:** Remonter fortement qualité visuelle / lisibilité / feedback UI en restant 100 % natif Godot (Theme, StyleBox, Tween, shaders légers) — **sans** nouveaux sprites/textures externes ; conserver disposition, personnages, cartes, fond, rétro pixel-art et règles Hearts.
- **Impact:** ★★★★★
- **Complexité:** ★★★★☆ (lots L0–L9)
- **Priorité proposée:** **P0**
- **Epic:** UI/Polish
- **Depends on:** Packs A–C (fondations)
- **Living Documents:** [`../ui/VISUAL_POLISH_NATIVE_PLAN.md`](../ui/VISUAL_POLISH_NATIVE_PLAN.md)
- **Implémentation:** `UiThemeCatalog`, menus (panneau + chrome NinePatch), sections config, HUD, scores, cartes (ombre/rim hover/shake), `PixelNotification`, vignette ; pass 2 menus plus visibles
- **MCP validation (2026-07-21):** play main_menu + overlay smoke ; GdUnit theme/style
- **Next Action:** —
- **Notes:** Theme seul n’affecte pas NinePatch — chrome OpaqueBackground obligatoire pour feedback menu.

---

## DONE

## IDEA-00001 — 2026-07-21 — Gouvernance inbox / backlog / index docs

- **Statut:** DONE
- **Decision:** Accepted
- **Origin:** audit chat (prompt polish + modèle TLD)
- **Motivation:** Aligner Dame sur Creative OS (INBOX, KANBAN, backlog) pour piloter polish sans perdre les idées.
- **Impact:** ★★★★☆ (process)
- **Complexité:** ★★☆☆☆
- **Priorité proposée:** P0
- **Epic:** Tooling
- **Living Documents:** [`INBOX.md`](INBOX.md), [`KANBAN.md`](KANBAN.md), [`BACKLOG_PRIORITY.md`](BACKLOG_PRIORITY.md), [`../WORKFLOW.md`](../WORKFLOW.md), [`../DOCUMENT_INDEX.md`](../DOCUMENT_INDEX.md), [`../QUALITY-AUDIT.md`](../QUALITY-AUDIT.md)
- **Next Action:** —
- **Notes:** Structure allégée vs TLD (pas de meta-progression).

## IDEA-00002 — 2026-07-21 — Corriger skill bouton + Components (NinePatch live)

- **Statut:** DONE
- **Decision:** Accepted
- **Origin:** audit
- **Motivation:** Le skill pointait `pixel_button.tscn` archivé ; production = `button_template` / `NinePatchButton`.
- **Impact:** ★★★☆☆
- **Complexité:** ★☆☆☆☆
- **Priorité proposée:** P0
- **Epic:** Hygiene
- **Living Documents:** `.cursor/skills/godot-pixel-ui-button/SKILL.md`, `ui/Components.md`
- **Next Action:** —

## IDEA-00003 — 2026-07-21 — Retirer dialog_template live orphelin

- **Statut:** DONE
- **Decision:** Accepted
- **Origin:** audit
- **Motivation:** Doublon `scenes/menus/dialog_template.tscn` alors que l’archive existe déjà.
- **Impact:** ★★☆☆☆
- **Complexité:** ★☆☆☆☆
- **Priorité proposée:** P0
- **Epic:** Hygiene
- **Notes:** Archive conserve la référence.

## IDEA-00004 — 2026-07-21 — Gate _process hot-seat privacy overlay

- **Statut:** DONE
- **Decision:** Accepted
- **Origin:** audit
- **Motivation:** Éviter `_process` chaque frame quand overlay invisible.
- **Impact:** ★★☆☆☆
- **Complexité:** ★☆☆☆☆
- **Priorité proposée:** P0
- **Epic:** Hygiene
- **Implémentation:** `scripts/ui/table/hot_seat_privacy_overlay.gd`
- **MCP validation (2026-07-21):**
  - `reload_project` (disk avait le fix, cache éditeur non)
  - `script.reload() == OK` + source contient `set_process(false|true)`
  - Runtime `play_scene` main : `after_ready_processing=false` → `after_show=true` → `after_close=false`
  - Hygiene : `dialog_template` live absent ; archive + `button_template` présents

## IDEA-00005 — 2026-07-21 — Anim open/close ModalOverlayScreen

- **Statut:** DONE
- **Decision:** Accepted (next phase go / Pack A+B)
- **Epic:** UI/Polish
- **Implémentation:** `modal_overlay_screen.gd` + `ui_offset_anim.gd`
- **MCP:** Settings open → scale (1,1) / backdrop α=1 ; close → visible false

## IDEA-00006 — 2026-07-21 — Entrée HandEnd + Confirm comme MatchEnd

- **Statut:** DONE
- **Decision:** Accepted
- **Epic:** UI/Polish
- **Implémentation:** `hand_end_dialog.gd`, `confirm_dialog.gd`, `match_end_dialog.gd` → `UiOffsetAnim.play_dialog_entrance`
- **MCP:** HandEnd/Confirm start scale 0.86 + α=0

## IDEA-00007 — 2026-07-21 — Harmoniser top menu bar (pixel/or)

- **Statut:** DONE
- **Decision:** Accepted
- **Epic:** UI/Polish
- **Implémentation:** `top_menu_bar.gd` + `UiStyleFactory.pixel_bar_button_style` (coins 0, bordure or)
- **MCP:** StyleBoxFlat corner_radius=0, border=2, gold

## IDEA-00008 — 2026-07-21 — Hover/focus premium NinePatchButton

- **Statut:** DONE
- **Decision:** Accepted
- **Epic:** UI/Polish
- **Implémentation:** `nine_patch_button.gd` — scale hover 1.04 / pressed 0.97 + couleurs or
- **MCP:** focus → `offset_transform_scale` (1.04, 1.04)

---

## DOCUMENTED

## IDEA-00009 — 2026-07-21 — Factoriser network_service

- **Statut:** DONE
- **Decision:** Accepted (implémentation directe demandée)
- **Origin:** AUDIT-PRE-1.0 A1 + QUALITY-AUDIT
- **Motivation:** 588 L — transport + lobby + discovery mélangés.
- **Impact:** ★★★★☆
- **Complexité:** ★★★★☆
- **Priorité proposée:** P1 → traité comme P0 sur demande
- **Epic:** Architecture
- **Implémentation:**
  - `network_lobby_book.gd` (lobby + peer↔siège)
  - `network_match_disconnect_coordinator.gd` (phase D)
  - `network_online_bridge.gd` (registry)
  - `network_service.gd` façade (~433 L) — API publique inchangée
- **MCP + tests (2026-07-21):**
  - 4 scripts `reload()==OK`
  - Runtime `host_game(17999)` → host + 1 human + invite code ; `disconnect_from_host` OK
  - GdUnit : `test_network_lobby_book` 5/5 PASS · `test_network_match_disconnect_coordinator` 3/3 PASS

## IDEA-00010 — 2026-07-21 — Découper multiplayer_lobby_screen

- **Statut:** DONE
- **Decision:** Accepted (suite après 00021)
- **Origin:** audit
- **Motivation:** 525 L multi-modes UI → helpers à responsabilité unique.
- **Impact:** ★★★☆☆
- **Complexité:** ★★★☆☆
- **Priorité proposée:** P1
- **Epic:** Multiplayer
- **Depends on:** IDEA-00009 (soft)
- **Implémentation:**
  - `multiplayer_lobby_sessions.gd` — liste / labels / contraste
  - `multiplayer_lobby_invite_code.gd` — format live code
  - `multiplayer_lobby_public_ip.gd` — lookup IP
  - `multiplayer_lobby_screen.gd` orchestrateur (~425 L) ; fix bug `_sessions` → `item_count`
- **MCP + tests (2026-07-21):** GdUnit helpers 4/4 ; lobby `open()` runtime OK

## IDEA-00011 — 2026-07-21 — Factory StyleBox banners table

- **Statut:** DONE
- **Decision:** Accepted (`implémente: Pack C`)
- **Epic:** Table/Feel
- **Implémentation:** `UiStyleFactory.pixel_banner_panel_style` / compact + apply sur hand_start, ai_announcement, ai_thinking, table_fx, moon picker, trick history
- **MCP:** corner 0, border or ; GdUnit `test_ui_style_factory_pixel` 4/4

## IDEA-00012 — 2026-07-21 — StyleBoxFlat pixel (coins 0, bordures 2px)

- **Statut:** DONE
- **Decision:** Accepted
- **Epic:** UI/Polish
- **Implémentation:** `pixel_overlay_panel_style` appliqué `ModalOverlayScreen` + Confirm/HandEnd/MatchEnd
- **MCP:** Settings Panel corner=0 border=2 gold

## IDEA-00013 — 2026-07-21 — Borner @export numériques

- **Statut:** DOCUMENTED
- **Decision:** —
- **Origin:** AUDIT_CONFORMITE
- **Motivation:** GD-VALIDATION-001
- **Impact:** ★☆☆☆☆
- **Complexité:** ★☆☆☆☆
- **Priorité proposée:** P2
- **Epic:** Hygiene

## IDEA-00014 — 2026-07-21 — kill() tweens carte sur retarget

- **Statut:** DOCUMENTED
- **Decision:** —
- **Origin:** AUDIT_CONFORMITE LIFECYCLE-001
- **Motivation:** Éviter chevauchement anims (risque déjà bas).
- **Impact:** ★★☆☆☆
- **Complexité:** ★★☆☆☆
- **Priorité proposée:** P2
- **Epic:** Table/Feel

## IDEA-00015 — 2026-07-21 — Vignette shader ColorRect (menu)

- **Statut:** DOCUMENTED
- **Decision:** Deferred → **absorbé par IDEA-00021 Lot L9**
- **Origin:** audit polish
- **Motivation:** Profondeur sans asset ; tester GL Compatibility.
- **Impact:** ★★☆☆☆
- **Complexité:** ★★☆☆☆
- **Priorité proposée:** P2 (ne pas lancer seul ; suite via 00021)
- **Epic:** UI/Polish
- **Notes:** Voir [`../ui/VISUAL_POLISH_NATIVE_PLAN.md`](../ui/VISUAL_POLISH_NATIVE_PLAN.md) § Lot L9.

## IDEA-00016 — 2026-07-21 — Score pop modulation discrète

- **Statut:** DONE
- **Decision:** Accepted (Pack C)
- **Epic:** Table/Feel
- **Implémentation:** `player_seat._play_score_pop` — scale 1.12 + GOLD_BRIGHT puis reset
- **MCP:** score set → offset_transform_enabled + font GOLD_BRIGHT

## IDEA-00017 — 2026-07-21 — Helpers layout player_seat

- **Statut:** DOCUMENTED
- **Decision:** Deferred
- **Origin:** audit
- **Motivation:** 432 L — extraire maths layout.
- **Impact:** ★★☆☆☆
- **Complexité:** ★★★☆☆
- **Priorité proposée:** P2
- **Epic:** Architecture

## IDEA-00018 — 2026-07-21 — Déprécier / fusionner PixelButton mort

- **Statut:** DOCUMENTED
- **Decision:** —
- **Origin:** audit
- **Motivation:** Script `pixel_button.gd` sans scène live.
- **Impact:** ★★☆☆☆
- **Complexité:** ★★☆☆☆
- **Priorité proposée:** Later
- **Epic:** Hygiene

## IDEA-00019 — 2026-07-21 — Mobile / safe area (A4)

- **Statut:** DOCUMENTED
- **Decision:** Deferred ROADMAP 8
- **Origin:** STATUS / NEXT
- **Motivation:** Responsive mobile.
- **Impact:** ★★★☆☆
- **Complexité:** ★★★★☆
- **Priorité proposée:** Later
- **Epic:** Mobile

## IDEA-00020 — 2026-07-21 — Particles discrètes moments clés

- **Statut:** DOCUMENTED
- **Decision:** —
- **Origin:** audit
- **Motivation:** Moon / last trick — sobriété stricte.
- **Impact:** ★★☆☆☆
- **Complexité:** ★★☆☆☆
- **Priorité proposée:** Later
- **Epic:** Table/Feel
- **Notes:** Interdit si ça « clignote ».

## IDEA-00022 — 2026-07-21 — Réactions rapides (emotes table)

- **Statut:** DONE
- **Decision:** Implémenté — picker bas-droite, bulles procédurales sur `AnimationLayer`, cooldown, option settings, RPC host
- **Origin:** user (Clash Royale–like social layer)
- **Motivation:** Couche sociale légère sans chat texte ; solo / hot seat / LAN prêt
- **Impact:** ★★★☆☆
- **Complexité:** ★★★☆☆
- **Priorité proposée:** Now
- **Epic:** Table/Feel
- **Notes:** 4 émotions `_draw()` ; preuves MCP `.mcp_audit/reactions_02_palette.png`, `reactions_09_normal_above_avatar.png` ; tests `test_reaction_system.gd` 3/3
