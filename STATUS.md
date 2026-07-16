# STATUS — Dame de Pique

**Derniere mise a jour:** 2026-07-17 (merged `feat/simulation-batch` → `main` ; A1/A4 différés)

| Element | Statut |
|---------|--------|
| Emplacement CreativeOS | OK — `projects/Games/DameDePique` |
| Branche active | `main` (pre-1.0 S0–S4 merged) |
| `project.godot` / main scene | OK — `bootstrap.tscn` |
| Godot | 4.7.1-stable |
| Addon `gdUnit4` | OK (activé) |
| Addon `godot_mcp` | OK (activé) — MCP Pro connecté |
| Tests GdUnit | Base solide (unit + intégration) |
| Solo / Hot seat / LAN | Jouable |
| Audit pré-1.0 | `docs/AUDIT-PRE-1.0.md` — S0 ✅ S1 ✅ S3 ✅ S4 ✅ (A1/A4 différés) |

## Important — chemin Godot

Ouvrir uniquement :

`C:\Users\fredc\Projects\CreativeOS\projects\Games\DameDePique`

## Sprint S0 (blockers audit)

- [x] C1 — Config OptionButton (ordre refresh / load)
- [x] C2 — Simulation ne pollue plus StatsService (`emit_game_events`) + bouton reset stats
- [x] C3 — Docs STATUS / NEXT / PROJECT_STATUS

## Sprint S1 (UX table/menu)

- [x] I1 — Bouton Lune masqué jusqu'à pli ≥ 3 ou Cœurs défoncés
- [x] I2 — TopMenuBar : MUSIQUE / SUIVANT retirés (audio dans Configuration)
- [x] I3 — Lobby multi : labels Rejoindre distincts + contraste ItemList
- [x] I4 — Backdrop overlays α 0,78 + reset dim post hot-seat
- [x] I5 — Double titre menu : Label masqué (branding splash)

## Sprint S3 (hygiene)

- [x] I7 — Assets / scènes morts → `assets/_archive/` + `exclude_filter` export
- [x] I8 — Warnings GDScript shadow/unused nettoyés (MCP : plus de SHADOWED/UNUSED projet)

## Sprint S4 (soft polish)

- [x] A2 — Settings/Help lazy-instanciés (menu + table)
- [x] A3 — i18n FR « Partage d'appareil » (EN Hot seat)
- [x] A5 — Crossfade musique + faux positifs AudioPaths documentés
- [x] A6 — Perf play mesurée (FPS OK ; orphans = éditeur)
- [x] A7 — Recettes MCP D/E/F (settings / scores / moon)
- [ ] A1 — Factoriser gros scripts — différé post-1.0
- [ ] A4 — Responsive / mobile — différé ROADMAP étape 8
