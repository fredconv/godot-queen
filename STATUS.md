# STATUS — Dame de Pique

**Derniere mise a jour:** 2026-07-21 (Context Shell phase a — DESKTOP)

| Element | Statut |
|---------|--------|
| Emplacement CreativeOS | OK — `projects/Games/DameDePique` |
| Branche active | `main` |
| Focus courant | **Context Shell** 00023–00025 — phase **a** OK ; suite b→h |
| Réactions / polish UI | 00022 / 00021 DONE |
| Tests GdUnit | Layout shell 9/9 + suite existante |
| Handoff | `handoff.md` à jour 2026-07-21 |

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
