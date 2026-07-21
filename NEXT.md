# NEXT — DameDePique

## Fait (S0 — 2026-07-16)

- [x] Fix Configuration OptionButton (C1)
- [x] Isolation stats simulation + reset UI (C2)
- [x] Docs statut à jour (C3)
- [x] Godot MCP Pro opérationnel sur ce chemin

## Fait (S1 — 2026-07-16)

- [x] I1 — Masquer / retarder « LUNE SOUPÇONNÉE » en début de manche
- [x] I2 — Alléger TopMenuBar (audio → settings)
- [x] I3 — Lobby multi contraste + labels Rejoindre
- [x] I4 — Assombrir fond des overlays menu + dim hot-seat
- [x] I5 — Double titre splash / Label

## Fait (S3 — 2026-07-16)

- [x] I7 — Archive assets/scènes morts + filtre export
- [x] I8 — Zero warnings GDScript projet (shadow / unused)

## Fait (S4 — 2026-07-16)

- [x] A2 — Overlays Settings/Help à la demande
- [x] A3 — Terminologie i18n hot seat FR
- [x] A5 — Audio fade + doc faux positifs
- [x] A6 — Mesure perf play MCP
- [x] A7 — Recettes playtest D/E/F
- [x] A1 / A4 — documentés comme différés (post-1.0 / ROADMAP 8)

## Priorite immediate

- [x] Merge `feat/simulation-batch` → `main` (2026-07-17, FF + push)
- [x] 2026-07-21 — Audit qualité + INBOX/backlog (`docs/QUALITY-AUDIT.md`, `docs/00_INBOX/`)
- [x] Hygiene SAFE — skill NinePatch, dialog_template orphelin, gate `_process` hot-seat
- [x] **Pack A+B** — modales animées + boutons/top bar pixel (IDEA-00005…00008) — MCP OK
- [x] **IDEA-00009** — factoriser `network_service` (LobbyBook / Disconnect / OnlineBridge) — MCP + GdUnit OK
- [x] **Pack C** — banners StyleBox + overlays pixel + score pop (00011/12/16) — MCP + GdUnit OK
- [x] **P0 IDEA-00021** — Polish visuel natif (L1–L9 + pass menus visibles) — DONE
- [x] **IDEA-00010** — découpe `multiplayer_lobby_screen` (sessions / invite / public IP) — DONE
- [x] **IDEA-00022** — Réactions table — DONE
- [x] **Context Shell phase a** — layout hosts + insets + dock pli — DONE (2026-07-21)
- [x] **Context Shell phase b** — coordination toggle / scoreboard dock / Escape — DONE
- [ ] **Context Shell** phases c→h (TogglePanel, bottom bar, Focus, MCP doc)
- [ ] Capturer living doc Focus Mode / Table seule (brief validé)
- [ ] Optionnel : IDEA-00014 kill tweens carte si bug observé
- [ ] ROADMAP étape 8 — icône store, mobile/safe area (A4), polish audio restant

Note : S2 (I3) a été absorbé dans S1.

## Cleanup déménagement (si pas encore fait)

```powershell
& "C:\Users\fredc\Projects\CreativeOS\scripts\finish-dame-de-pique-move.ps1"
```
