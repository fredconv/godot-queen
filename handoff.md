# Dame de Pique — Cross-machine handoff

> Shared Cursor session state for desktop and laptop. Synchronize it only through this project's
> Git repository (`fredconv/godot-queen`). Never write secrets, API keys, passwords, or `.env` values here.

## STATUS

<!-- STATUS:START -->
**Last updated:** 2026-07-21 (DESKTOP — Context Shell phase a + sync push)  
**Repository:** https://github.com/fredconv/godot-queen (branch `main`)

### Current Goal
- Package **Context Shell** (IDEA-00023–00025) : shell avant bottom bar ; jouer table-seule toujours possible.

### Current Status
- **Phase a livrée** : `ContextShellLayout` + `ContextShellHost` branchés sur la table ; `bottom_bar_slot_active=false` jusqu’à phase d.
- Insets respectent les ancres (TrickArea centré plus écrasé) ; cartes du pli **dockées** dans les slots après atterrissage.
- Réactions (00022) DONE ; polish 00021 DONE ; lobby split 00010 DONE.
- Focus Mode / Table seule (brief long) : à capitaliser en IDEA/living doc si pas encore fait — phase **g** du package.
- GdUnit layout shell : 9/9 ; smoke MCP sidebar open/close.

### TODO
1. Phase **b** coordination table/shell → **c** TogglePanel sidebar → **d** bottom bar → e–h.
2. Capturer / livrer living doc **Focus Mode** (ESSENTIAL vs OPTIONAL, snapshot UI, ≠ plein écran système).
3. Optionnel : IDEA-00014 kill tweens ; ROADMAP étape 8 mobile.

### Decisions
- Context Shell = un package, modules séparés (pas monolithe).
- Petit écran : bottom bar **compact**, pas hide (sauf Focus / préférence).
- Tour actif : TopMenuBar + table (jamais bottom bar seule).
- ReactionPicker flottant ; `shell_focus` (pas `Control.focus_mode`).

### Known Issues
- Siège droit serré vs sidebar à ~1000 px play width (responsive phase f).
- Ne pas committer : PDF multiplayer, `.DS_Store`, `gdunit_unit_result.log`.

### Next Best Task
- `implémente: phase b` (coordination) ou **c** TogglePanel — après `git pull` sur l’autre machine.

### Delegatable
- Laptop : `git pull origin main` ; smoke table + toggle sidebar ; enchaîner phase b/c.
<!-- STATUS:END -->

## CHANGELOG

Entries are append-only. For each handoff, add a dated entry with **Done**, **Discussed**, and
**TODO**. Preserve all previous entries so either machine can reconstruct the session context.

---

## 2026-07-21 — Context Shell phase a + fix pli (DESKTOP)

### Done
- Package Context Shell documenté (`docs/ui/CONTEXT_SHELL_PACKAGE.md`) ; décisions 00023–00025 validées.
- Phase a : `ContextShellHost` / `ContextShellLayout` ; bind régions table ; `shell_focus` (≠ Control.focus_mode).
- Fix insets TrickArea centré ; dock cartes du pli dans les slots ; ReactionPicker décale hors sidebar.
- Tests `test_context_shell_layout.gd` 9/9 ; smoke MCP sidebar.
- Réactions 00022 + polish 00021 déjà DONE plus tôt dans le fil.

### Discussed
- Focus / Table seule / Expert : brief architecture générique (phase g) — à capturer IDEA si manquant.
- Bottom bar compact sur petit écran ; shell avant bottom bar.

### TODO
- Phases b→h Context Shell.
- Laptop : pull + smoke table/sidebar.

---

## 2026-07-17 — Merge to main + DOC_OK

### Done
- Fast-forward merge `feat/simulation-batch` → `main` (`f879627`); pushed `origin/main`.
- No meaningful leftover sprint code to recommit (junk left untracked).
- Handoff STATUS updated: merged, pre-1.0 polish done, A1/A4 deferred.
- DOC_OK: capitalise MCP/sim lessons into skill + `lessons-learned` + STATUS/NEXT/AUDIT gaps.

### Discussed
- DOC_OK next after merge (this entry).
- Feature branch may remain until laptop confirms `main`.

### TODO
- A1 script splits / A4 mobile post-1.0 if still open.
- Optional remote branch cleanup after laptop OK.

---

## 2026-07-16 — S3 I7–I8 + soft polish A2–A7 (commit+push)

### Done
- S3: I7 archive dead assets/scenes + export exclude; I8 GDScript shadow/unused cleared.
- S4: A2 lazy Settings/Help; A3 FR hot-seat i18n; A5 music crossfade; A6 play perf MCP; A7 playtest recipes D/E/F.
- Docs: STATUS / NEXT / CHANGELOG / AUDIT-PRE-1.0 updated.
- Commit `28831ad` pushed to `origin/feat/simulation-batch`.

### Discussed
- A1 (god-object splits) and A4 (mobile) deferred post-1.0 — documented in AUDIT.
- No `scripts/handoff.ps1` in this repo; handoff via root `handoff.md` only.

### TODO
- Merge branch → `main`.
- Post-1.0 A1 / A4 when capacity allows.

---

## 2026-07-16 — S3 hygiene I7–I8

### Done
- I7: archived dead assets/scenes under `assets/_archive/`; export `exclude_filter` for archive/reports/simulation.
- I8: renamed shadowing identifiers + `_` unused params; MCP play confirms no project SHADOWED/UNUSED warnings.
- Docs: STATUS / NEXT / AUDIT / CHANGELOG updated.

### Discussed
- No commit/push requested for S3 yet.
- Deck/audio remaining MCP “unused” are intentional false positives (dynamic load).

### TODO
- Commit S3 when asked.
- Soft polish A1–A7 or merge to main.

---

## 2026-07-16 — S0+S1 pre-1.0 UI fixes

### Done
- Sprint S0: C1 settings, C2 stats isolation/reset, C3 docs.
- Sprint S1: I1 moon, I2 TopMenuBar, I3 lobby, I4 overlay dim, I5 double title.
- MCP verified; stats reset available.
- Commit + push of S0+S1 to `origin/feat/simulation-batch`.

### Discussed
- Commit/push of S0+S1 completed this session.
- Next: S3 I7–I8 or soft A1–A7.

### TODO
- S3 hygiene I7–I8.
- Optional soft polish A1–A7 post-1.0.
