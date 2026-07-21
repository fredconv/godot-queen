# Workflow — Dame de Pique

```
Version : V02
Created : 2026-07-21
Last Updated : 2026-07-21
Status : Active
```

Aligné sur The Last Defender / Creative OS, **allégé** pour un jeu de cartes mature (pas de meta-progression massive).

**Inbox :** [`00_INBOX/INBOX.md`](00_INBOX/INBOX.md) · **Kanban :** [`00_INBOX/KANBAN.md`](00_INBOX/KANBAN.md) · **Index :** [`DOCUMENT_INDEX.md`](DOCUMENT_INDEX.md)

---

## Principes

1. **Pas d’idée perdue** — toute idée chat → entrée `IDEA-XXXX` dans INBOX.
2. **Pas d’auto-implémentation** sur `idée:` — backlog seulement.
3. **Pas de nouvelles règles / IA / équilibrage** sans validation explicite.
4. **Polish sans assets externes** — Theme, Tween, StyleBox, shaders Godot uniquement.
5. **Un seul source of truth idées** — INBOX (pas de `BACKLOG.md` parallèle).

---

## Capture d’idée

Préfixes : `idée:` · `idee:` · `suggestion:` · `feature:` · `amélioration:` · `brainstorming:`

Règle : [`.cursor/rules/idee-capture.mdc`](../.cursor/rules/idee-capture.mdc)

L’agent :
1. Assigne le prochain `IDEA-XXXX`
2. Remplit Motivation / Impact / Complexité / Priorité / Epic
3. Statut **DOCUMENTED**
4. Régénère KANBAN
5. Demande : backlog seul · prioriser · `implémente:` maintenant

---

## Statuts

```text
DOCUMENTED → READY → IN_PROGRESS → TESTED → WAITING_USER_VALIDATION → DONE → RELEASED
Optional: ARCHIVED | REJECTED
```

**Definition of Ready :** documenté · impacts identifiés · specs assez détaillées · pas de question bloquante · Depends on DONE/RELEASED · **ne touche pas règles/IA sans OK**.

---

## Epics (taxonomie DDP)

| Epic | Exemples |
|------|----------|
| Architecture | Découpe scripts, autoloads, modularité |
| UI/Polish | Boutons, modales, thème, micro-animations |
| Table/Feel | Cartes, feedback in-game, transitions manche |
| Multiplayer | Lobby, réseau, hot seat (hors règles) |
| Hygiene | Code mort, docs, warnings, archive |
| Audio | Crossfade, SFX (AudioService) |
| Mobile | Safe area, responsive (ROADMAP 8) |
| Tooling | MCP playtest, tests, simulation |

---

## Polish — garde-fous

- Identité : **taverne de cartes** pixel-art (vert feutre, or, Press Start 2P)
- **Interdit** : nouveaux PNG/sprites/textures externes
- **Autorisé** : shaders, StyleBoxFlat/Texture existants, Theme, Tween, particles sans texture, modulation
- Sobriété table : pas de clignotements ; hover scale ≤ ~1.05
- Toute modif structurelle UI → proposer avant coder (sauf hygiene SAFE)

---

## Après implémentation

1. **Gate MCP + QA visuelle** avant de dire « validé / DONE » (voir ci-dessous)
2. Tests GdUnit concernés (`verify`) si logique pure
3. Entrée CHANGELOG si visible joueur
4. Statut IDEA → TESTED / WAITING_USER_VALIDATION
5. Mettre à jour STATUS / NEXT si focus change

---

## Definition of Done (UI / table)

Une feature UI n’est **jamais** DONE tant que **toutes** ces cases sont cochées :

| # | Critère | Preuve |
|---|---------|--------|
| 1 | Gate MCP technique (reload + runtime sync) | log / rapport |
| 2 | **QA visuelle MCP** (captures + inspection) | `res://.mcp_audit/*.png` |
| 3 | Aucun débordement / clipping / chevauchement / élément masqué | checklist visuelle |
| 4 | Marges, centrage, alignements, hiérarchie lisibles | lecture des screenshots |
| 5 | États ouverts inspectés (ex. palette ouverte, cooldown, disabled) | ≥ 1 screenshot par état clé |
| 6 | GdUnit si logique pure / géométrie testable | suite verte |
| 7 | Pas d’erreur éditeur liée au changement | `get_editor_errors` |

**Échec automatique de Done** : screenshot flou / distant sans zoom sur le composant touché ; validation uniquement par `validate_script` ou « le nœud existe ».

---

## Gate MCP — ne jamais clamer « validé » sans preuve

Avant de marquer une idée **DONE** / dire à l’utilisateur que c’est OK :

| Étape | Outil MCP | Pourquoi |
|-------|-----------|----------|
| 1 | `reload_project` | Sinon l’éditeur peut garder l’**ancien** `.gd` en cache (disk ≠ editor) |
| 2 | `execute_editor_script` + `ResourceLoader.CACHE_MODE_IGNORE` | Vérifier le contenu réellement chargé + `script.reload() == OK` |
| 3 | `play_scene` + `execute_game_script` (sync, **pas** `await`) | Preuve runtime (ex. `is_processing()` après open/close) |
| 4 | `get_game_screenshot` (+ crop mental / focus composant) | **QA visuelle** — voir checklist |
| 5 | `get_editor_errors` / `get_output_log` | Aucune erreur bloquante liée au changement |
| 6 | `stop_scene` | Nettoyer la session play |

### Checklist QA visuelle (obligatoire pour UI)

Pour chaque composant modifié, l’agent **doit** ouvrir les PNG et vérifier :

- [ ] Pas de débordement hors parent / panel / cellule / **viewport**
- [ ] Pas de clipping involontaire (texte/icône coupés) — **crop zoomé** de la zone touchée
- [ ] Pas de chevauchement illisible
- [ ] Centrage / alignement cohérents avec le design pixel (assert `get_global_rect` si possible)
- [ ] Marges ≥ 1–2 px nets vs bordures or
- [ ] États : normal, hover/focus si pertinent, ouvert/fermé, cooldown/disabled
- [ ] Lisibilité à 1280×720 (et note si autre résolution testée)

Si un défaut est visible sur la capture → **corriger immédiatement**, rejouer la gate — ne pas marquer DONE.

**Pièges connus :**

- `validate_script` sur un fichier avec `class_name` → faux positif « hides a global script class » — **ne pas** s’en servir comme preuve seule.
- Éditer via outils filesystem Cursor **sans** `reload_project` → Godot joue encore l’ancienne version.
- `execute_game_script` + `await` → crash MCP (« async without await ») — rester synchrone.
- Screenshot plein écran OK pour contexte, **insuffisant** si le défaut est pixel-level : zoomer mentalement / assert géométrie (`get_global_rect` enclose) + capture dédiée.
- Description auto d’image peut rater un petit défaut — croiser avec **assert géométrie** quand possible.

Skill playtest : `.cursor/skills/dame-de-pique-mcp-playtest/SKILL.md`.
