# Dame de Pique — Cross-machine handoff

> Shared Cursor session state for desktop and laptop. Synchronize it only through this project's
> Git repository (`fredconv/godot-queen`). Never write secrets, API keys, passwords, or `.env` values here.

## STATUS

<!-- STATUS:START -->
**Last updated:** 2026-07-17 (DESKTOP — merged to `main` + DOC_OK)  
**Repository:** https://github.com/fredconv/godot-queen (branch `main`)

### Current Goal
- Pre-1.0 polish done on `main`; prepare store/ROADMAP étape 8 when ready.

### Current Status
- **`feat/simulation-batch` merged → `main`** (fast-forward `ff749b3..f879627`) and pushed `origin/main`.
- Sprint **S0** done: C1 settings OptionButton, C2 simulation stats isolation + reset, C3 docs.
- Sprint **S1** done: I1 moon button gating, I2 TopMenuBar cleanup, I3 lobby contrast/labels, I4 overlay dim, I5 double title fix.
- Sprint **S3** done: I7 assets archive + export exclude; I8 GDScript shadow/unused warnings cleared.
- Sprint **S4** soft polish: A2 lazy Settings/Help, A3 FR « Partage d'appareil », A5 music crossfade, A6 perf measured, A7 MCP recipes D/E/F.
- **Deferred (post-1.0):** A1 script splits; A4 mobile/safe area (ROADMAP étape 8).
- Feature branch `feat/simulation-batch` still exists at same tip as `main` (optional cleanup later).

### TODO
1. Post-1.0: A1 script splits (`network_service` / lobby / `player_seat`).
2. Post-1.0: A4 mobile/safe area + store icon (ROADMAP 8).
3. Optional: delete remote `feat/simulation-batch` once laptop confirmed on `main`.

### Decisions
- Open Godot only from `C:\Users\fredc\Projects\CreativeOS\projects\Games\DameDePique`.
- Standalone repo handoff via root `handoff.md` (no local `scripts/handoff.ps1` — manual STATUS + log).
- Dead assets live under `assets/_archive/` (excluded from Windows export).
- A1/A4 explicitly deferred; not blockers for 1.0.

### Known Issues
- MCP `find_unused_resources` still lists deck/audio/UI slices as unused (dynamic `load()` false positives) — documented in `assets/_archive/README.md`.
- Leftover local-only junk (not committed): multiplayer PDF refs, `.DS_Store`, `gdunit_unit_result.log`.

### Next Best Task
- DOC_OK capitalisation complete this session; laptop `git pull` on `main` + optional smoke MCP D/E/F.

### Delegatable
- Laptop: `git checkout main && git pull`; smoke MCP D/E/F; confirm OK to delete `feat/simulation-batch`.
<!-- STATUS:END -->

## CHANGELOG

Entries are append-only. For each handoff, add a dated entry with **Done**, **Discussed**, and
**TODO**. Preserve all previous entries so either machine can reconstruct the session context.

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
