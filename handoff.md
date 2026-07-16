# Dame de Pique — Cross-machine handoff

> Shared Cursor session state for desktop and laptop. Synchronize it only through this project's
> Git repository (`fredconv/godot-queen`). Never write secrets, API keys, passwords, or `.env` values here.

## STATUS

<!-- STATUS:START -->
**Last updated:** 2026-07-16 (DESKTOP — S0+S1 committed/pushed)  
**Repository:** https://github.com/fredconv/godot-queen (branch `feat/simulation-batch`)

### Current Goal
- Ship pre-1.0 polish on `feat/simulation-batch` then merge to `main`.

### Current Status
- Sprint **S0** done: C1 settings OptionButton, C2 simulation stats isolation + reset, C3 docs (STATUS/NEXT/AUDIT/CHANGELOG).
- Sprint **S1** done: I1 moon button gating, I2 TopMenuBar cleanup, I3 lobby contrast/labels, I4 overlay dim, I5 double title fix.
- MCP Pro verified on CreativeOS path; stats reset path available in Configuration.
- Commit `14eff79` pushed to `origin/feat/simulation-batch`.

### TODO
1. Sprint **S3** hygiene: I7–I8 (assets / zero-warnings GDScript).
2. Optional soft polish **A1–A7** post-1.0 (see `docs/AUDIT-PRE-1.0.md`).
3. Merge `feat/simulation-batch` → `main` after polish.

### Decisions
- Open Godot only from `C:\Users\fredc\Projects\CreativeOS\projects\Games\DameDePique`.
- Standalone repo handoff via root `handoff.md` + `Invoke-SyncHandoff.ps1 -Scope HandoffOnly`.

### Known Issues
- Leftover local-only junk not committed: debug medieval PNGs, multiplayer PDF refs, `.DS_Store`, `gdunit_unit_result.log`.

### Next Best Task
- S3 hygiene **I7–I8** (or soft **A1–A7** if prioritizing UX polish over warnings).

### Delegatable
- Laptop: `git pull` on `feat/simulation-batch` then MCP playtest smoke (settings, moon button, lobby, overlays).
<!-- STATUS:END -->

## CHANGELOG

Entries are append-only. For each handoff, add a dated entry with **Done**, **Discussed**, and
**TODO**. Preserve all previous entries so either machine can reconstruct the session context.

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
