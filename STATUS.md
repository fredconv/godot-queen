# STATUS — Dame de Pique

**Derniere mise a jour:** 2026-07-16 (sprint S1 UX audit pré-1.0)

| Element | Statut |
|---------|--------|
| Emplacement CreativeOS | OK — `projects/Games/DameDePique` |
| Branche active | `feat/simulation-batch` |
| `project.godot` / main scene | OK — `bootstrap.tscn` |
| Godot | 4.7.1-stable |
| Addon `gdUnit4` | OK (activé) |
| Addon `godot_mcp` | OK (activé) — MCP Pro connecté |
| Tests GdUnit | Base solide (unit + intégration) |
| Solo / Hot seat / LAN | Jouable |
| Audit pré-1.0 | `docs/AUDIT-PRE-1.0.md` — S0 ✅ S1 ✅ |

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
