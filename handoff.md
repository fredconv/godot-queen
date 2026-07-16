# Dame de Pique — Cross-machine handoff

> Shared Cursor session state for desktop and laptop. Synchronize it only through this project's
> Git repository (`fredconv/godot-queen`). Never write secrets, API keys, passwords, or `.env` values here.

## STATUS

<!-- STATUS:START -->
**Last updated:** 2026-07-16 (DESKTOP — S3 hygiene I7–I8 done, uncommitted)  
**Repository:** https://github.com/fredconv/godot-queen (branch `feat/simulation-batch`)

### Current Goal
- Ship pre-1.0 polish on `feat/simulation-batch` then merge to `main`.

### Current Status
- Sprint **S0** done: C1 settings OptionButton, C2 simulation stats isolation + reset, C3 docs.
- Sprint **S1** done: I1 moon button gating, I2 TopMenuBar cleanup, I3 lobby contrast/labels, I4 overlay dim, I5 double title fix.
- Sprint **S3** done: I7 assets archive + export exclude; I8 GDScript shadow/unused warnings cleared (MCP verified).
- MCP Pro verified on CreativeOS path; stats reset path available in Configuration.
- Commit `14eff79` pushed (S0+S1). **S3 changes are local / not committed yet.**

### TODO
1. Commit + push S3 when requested.
2. Optional soft polish **A1–A7** (see `docs/AUDIT-PRE-1.0.md`).
3. Merge `feat/simulation-batch` → `main` after polish.

### Decisions
- Open Godot only from `C:\Users\fredc\Projects\CreativeOS\projects\Games\DameDePique`.
- Standalone repo handoff via root `handoff.md` + `Invoke-SyncHandoff.ps1 -Scope HandoffOnly`.
- Dead assets live under `assets/_archive/` (excluded from Windows export).

### Known Issues
- MCP `find_unused_resources` still lists deck/audio/UI slices as unused (dynamic `load()` false positives) — documented in `assets/_archive/README.md`.
- Leftover local-only junk may remain: multiplayer PDF refs, `.DS_Store`, `gdunit_unit_result.log`.

### Next Best Task
- Commit S3, or soft polish **A1–A7**, then merge to `main`.

### Delegatable
- Laptop: `git pull` after S3 push; MCP playtest smoke (settings, moon, lobby, overlays).
<!-- STATUS:END -->

## CHANGELOG

Entries are append-only. For each handoff, add a dated entry with **Done**, **Discussed**, and
**TODO**. Preserve all previous entries so either machine can reconstruct the session context.

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
