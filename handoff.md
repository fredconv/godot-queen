# Dame de Pique — Cross-machine handoff

> Shared Cursor session state for desktop and laptop. Synchronize it only through this project's
> Git repository (`fredconv/godot-queen`). Never write secrets, API keys, passwords, or `.env` values here.

## STATUS

<!-- STATUS:START -->
**Last updated:** 2026-07-21 (DESKTOP — Royal Salon checkpoint ~90 % + Context Shell complet)
**Repository:** https://github.com/fredconv/godot-queen (branch `main`)

### Current Goal
- Validation humaine du checkpoint **Royal Salon** (IDEA-00027) et du **Context Shell** (IDEA-00023–00025).

### Current Status
- Context Shell complet : sidebar droite tweenée, bottom bar pleine largeur, onglets Plis/Cartes/Points/Aide et mises à jour live.
- Royal Salon ~90 % : sprites de couleurs, médaillons, tableaux, réglages/dialogues, aide contextuelle et variantes de Lune.
- Régression plis protégée par nettoyage défensif ; compteur de cartes dédupliqué et replié par défaut.
- QA MCP 1280×720 ouverte/fermée ; 18/18 tests GdUnit ciblés passés.

### TODO
1. Validation visuelle humaine du checkpoint ~90 %.
2. Retouches finales issues du playtest, puis release.
3. Optionnel : ROADMAP mobile et Focus Mode.

### Decisions
- Context Shell = un package, modules séparés (pas monolithe).
- Petit écran : bottom bar **compact**, pas hide (sauf Focus / préférence).
- Tour actif : TopMenuBar + table (jamais bottom bar seule).
- ReactionPicker flottant ; `shell_focus` (pas `Control.focus_mode`).

### Known Issues
- Validation mobile multi-format encore à approfondir.
- Ne pas committer : PDF multiplayer, `.DS_Store`, `gdunit_unit_result.log`.

### Next Best Task
- Playtest humain du checkpoint Royal Salon, puis corriger uniquement les écarts observés.

### Delegatable
- Laptop : `git pull origin main` ; smoke table + toggle sidebar ; enchaîner phase b/c.
<!-- STATUS:END -->

## CHANGELOG

Entries are append-only. For each handoff, add a dated entry with **Done**, **Discussed**, and
**TODO**. Preserve all previous entries so either machine can reconstruct the session context.

---

## 2026-07-21 — Royal Salon checkpoint ~90 % + Context Shell complet (DESKTOP)

### Done
- Refonte table/HUD, médaillons, top/bottom bars, sidebar et onglets contextuels.
- Sprites des quatre couleurs intégrés ; compteurs dédupliqués et aide stratégique repliée par défaut.
- Animations sidebar/main/siège coordonnées ; protections de collecte des plis.
- Réglages et dialogues rendus lisibles/responsives ; textes et infobulles clarifiés.
- QA MCP 1280×720 et tests ciblés GdUnit 18/18.

### Discussed
- Moodboard utilisé comme cible qualitative, sans copie à l'identique.
- Prochain point demandé à 80–90 %, atteint par ce checkpoint.

### TODO
- Validation visuelle humaine et dernières retouches avant release.

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
