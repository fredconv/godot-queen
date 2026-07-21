# AGENTS — Dame de pique

Guide pour les agents Cursor (et pour toi dans un mois). **Point d'entrée unique** : skills, règles, hooks et subagents du projet.

---

## Phrase à copier-coller dans le chat

```
Consulte AGENTS.md et les skills listés. Lis ceux pertinents pour la tâche avant de coder.
```

Variantes utiles :

| Tu veux… | Dis à l'agent |
|----------|----------------|
| Développer une feature | `Check AGENTS.md — quels skills pour [décrire la feature] ? Utilise-les.` |
| IA / Lune / messages table | `Utilise le skill dame-de-pique-ai-gameplay (voir AGENTS.md).` |
| Bouton ou menu pixel art | `Utilise godot-pixel-ui-button (AGENTS.md).` |
| Tests GdUnit4 | `Utilise godot-testing + lance les tests unitaires.` |
| Doc Godot à jour | `Utilise context7-mcp pour l'API Godot 4.7.` |

---

## Comment consulter ce fichier

1. **Ouvrir** `AGENTS.md` à la racine du repo (ce fichier).
2. **Dans Cursor Chat** : taper `@AGENTS.md` pour l'attacher au contexte.
3. **Règles auto** : `.cursor/rules/godot.mdc` s'applique toujours ; `ai-gameplay.mdc` quand tu édites l'IA.
4. **Index détaillé IA** : `.cursor/skills/dame-de-pique-ai-gameplay/reference.md`

---

## Workflow agent (à chaque tâche)

1. Lire **AGENTS.md** (section « Par type de fonctionnalité »).
2. Lire les **SKILL.md** pertinents (projet d'abord, puis perso si besoin).
3. Respecter les **règles** `.cursor/rules/`.
4. Après edit IA : le **hook** rappelle les tests (voir ci-dessous).
5. Lancer les **tests** / **simulation** selon la checklist du skill.

---

## Skills du projet (`.cursor/skills/`)

Priorité : **toujours préférer un skill projet** s'il existe pour Dame de pique.

| Skill | Fichier | Quand l'utiliser |
|-------|---------|------------------|
| **dame-de-pique-ai-gameplay** | [SKILL.md](.cursor/skills/dame-de-pique-ai-gameplay/SKILL.md) | IA adverses, Lune, suspicion, personnalités, confiance, messages table, `AdaptiveAiStrategy`, simulation équilibre |
| **dame-de-pique-multiplayer** | [SKILL.md](.cursor/skills/dame-de-pique-multiplayer/SKILL.md) | Modes solo/hot seat/LAN, host autoritaire, snapshots, `SeatSetup`, phases A–G |
| **godot-pixel-ui-button** | [SKILL.md](.cursor/skills/godot-pixel-ui-button/SKILL.md) | Boutons NinePatch **vivants** = `button_template.tscn` / `NinePatchButton` (pas `pixel_button` archivé) |
| **godot-performance-dame-de-pique** | [SKILL.md](.cursor/skills/godot-performance-dame-de-pique/SKILL.md) | Perf 2D cartes/UI, preload, profilage (pas physique 3D) |
| **context7-mcp** | [SKILL.md](.cursor/skills/context7-mcp/SKILL.md) | API Godot 4.7 / GDScript — doc à jour via MCP Context7 |
| **dame-de-pique-mcp-playtest** | [SKILL.md](.cursor/skills/dame-de-pique-mcp-playtest/SKILL.md) | Playtests MCP + **QA visuelle** (DoD UI) avant DONE |

---

## Par type de fonctionnalité → skills à lire

| Fonctionnalité | Skills / docs |
|----------------|---------------|
| Idées / polish / backlog | `docs/00_INBOX/INBOX.md` + `docs/WORKFLOW.md` + rule `idee-capture.mdc` — audit : `docs/QUALITY-AUDIT.md` |
| IA, chasse Lune, contre-Lune, agressivité | `dame-de-pique-ai-gameplay` + règle `ai-gameplay.mdc` + ADR-023 dans `docs/DECISIONS.md` |
| Messages « devient agressif » / « pense que… vise la Lune » | `dame-de-pique-ai-gameplay` → section Messages |
| Fin de manche / fin de partie (dialogs) | `godot-pixel-ui-button` + `localization` (perso) + `dialogs.csv` |
| Barre menu, PLIS, historique plis | `godot-pixel-ui-button` + `docs/TECHNICAL_DESIGN.md` |
| Règles pure jeu (validation coup, score) | `docs/GDD.md` — **pas** dans `scripts/ai/` |
| Tests unitaires GdUnit4 | `godot-testing` (perso) — `tests/unit/` |
| i18n / traductions | `localization` (perso) — `translations/*.csv`, `LocaleAware` |
| Nouveau écran menu | `godot-pixel-ui-button` + `gdscript-patterns` (perso) |
| Simulation 1000 parties | `dame-de-pique-ai-gameplay` → `simulation/README.md` + télémétrie `telemetry-metrics.md` |
| Multijoueur (modes, hot seat, LAN, réseau) | `dame-de-pique-multiplayer` + `docs/MULTIPLAYER_DESIGN.md` + ADR-024–027 |
| Hot seat rotation UI / confidentialité / pli | `dame-de-pique-multiplayer` → `reference.md` → ADR-025, ADR-026 |
| Erreur multijoueur / table déjà vue | `.cursor/architecture/dame-de-pique/lessons-learned.md` |
| Lune soupçonnée (bouton social multijoueur) | `dame-de-pique-multiplayer` → `reference.md` → `MoonSuspicionManager` |
| Multijoueur futur | `dame-de-pique-multiplayer` + `godot-multiplayer-turn-based` (global) + `docs/Multiplayer basics in godot.md` |
| Jeu de cartes (autre titre) | `card-game-ai-design` (perso) |

---

## Skills personnels utiles (`~/.cursor/skills/`)

Installés sur ta machine — **non versionnés** dans ce repo. **Priorité** : skills **projet** (`.cursor/skills/`) puis globaux.

### Index global

Voir `~/.cursor/README.md` — point d'entrée **`godot-dev-index`** et **`agent-workflow`**.

| Skill global | Quand (Dame de pique) |
|--------------|------------------------|
| **godot-dev-index** | Router skills Godot au début d'une tâche |
| **godot-pre-release-audit** | Avant export / playtest public (étape 8–10) |
| **godot-audio-integration** | Polish audio (`AudioService`) |
| **godot-user-settings-i18n** | i18n / config (`ConfigService`, `LocaleAware`) |
| **godot-parser-error** | Erreurs `class_name` / parser |
| **agent-workflow** | DOC OK, mémoire `.cursor/` |
| **card-game-ai-design** | Patterns IA cartes génériques |
| **godot-testing** | Écrire / lancer tests GdUnit4 |
| **gdscript-patterns** | Style GDScript, typage, signaux |
| **localization** | TranslationServer, CSV |
| **godot-ui** | Control, thèmes, layout |
| **responsive-ui** | Mobile paysage, ancrages (ADR-006) |
| **godot-code-review** | Revue avant PR |
| **save-load** | `SaveService`, `user://` |
| **event-bus** | Patterns signaux (`GameEvents`) |

### Rules / hooks / agents globaux (`~/.cursor/`)

| Type | Fichiers | Cumul projet |
|------|----------|--------------|
| Rules | `rules/godot-class-names.mdc`, `gdscript-godot.mdc`, `agent-workflow.mdc` | `.cursor/rules/godot.mdc` prime sur le détail projet |
| Hooks | `hooks.json` → rappels class_name, i18n, object pool | `hooks/after-ai-gameplay-edit.ps1` |
| Agents | `agents/godot-gdscript-reviewer.md`, `godot-architect.md` | Task tool `generalPurpose` |

Sync Creative OS → global : `CreativeOS\scripts\sync-cursor-skills.ps1`

Liste complète GodotPrompter : `~/.cursor/skills/` (60+ skills).

---

## Règles Cursor (`.cursor/rules/`)

| Fichier | Portée |
|---------|--------|
| [godot.mdc](.cursor/rules/godot.mdc) | **Toujours** — architecture, stack, conventions repo |
| [context7.mdc](.cursor/rules/context7.mdc) | Doc Godot via MCP |
| [idee-capture.mdc](.cursor/rules/idee-capture.mdc) | Capture idées → INBOX ; packs polish A/B |
| [ai-gameplay.mdc](.cursor/rules/ai-gameplay.mdc) | Fichiers `scripts/ai/**`, tests Lune/IA, simulation |
| [multiplayer.mdc](.cursor/rules/multiplayer.mdc) | Fichiers `scripts/network/**`, hot seat, lobby, docs MULTIPLAYER |

---

## Hooks (`.cursor/hooks.json`)

| Hook | Déclencheur | Effet |
|------|-------------|--------|
| `after-ai-gameplay-edit.ps1` | Après édition fichier IA / Lune / tests IA | Rappel : tests `test_moon_*`, `test_adaptive_*`, `test_ai_*` |
| `after-multiplayer-edit.ps1` | Après édition réseau / hot seat / soupçon Lune / lobby | Rappel : skill `dame-de-pique-multiplayer`, tests seat/hot seat/display map/moon |

---

## Subagents Task (quand déléguer)

| Subagent | Usage sur ce projet |
|----------|---------------------|
| `explore` | Cartographier code (ex. tout `scripts/ai/`) |
| `generalPurpose` | Simulation batch, tâches multi-fichiers |
| `shell` | Godot headless, GdUnit4 CLI |
| `bugbot` | Revue PR (sur demande explicite) |
| `ci-investigator` | CI GitHub en échec |

---

## Documentation projet (hors skills)

| Doc | Contenu |
|-----|---------|
| [docs/GDD.md](docs/GDD.md) | Règles Hearts |
| [docs/DECISIONS.md](docs/DECISIONS.md) | ADR — **ADR-023** (IA), **ADR-024–027** (multijoueur, hot seat, dépannage) |
| [.cursor/architecture/dame-de-pique/lessons-learned.md](.cursor/architecture/dame-de-pique/lessons-learned.md) | **Erreurs connues + fixes** (autoload, banner, hot seat, IA siège 0) |
| [docs/TECHNICAL_DESIGN.md](docs/TECHNICAL_DESIGN.md) | UI table, scènes |
| [docs/TEST_PLAN.md](docs/TEST_PLAN.md) | Stratégie tests |
| [docs/MULTIPLAYER_DESIGN.md](docs/MULTIPLAYER_DESIGN.md) | Spec multijoueur, phases A–G, références tutoriel Godot |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Étapes projet |
| [docs/Multiplayer basics in godot.md](docs/Multiplayer%20basics%20in%20godot.md) | Workshop ENet (référence externe) |
| [simulation/README.md](simulation/README.md) | Batch 1000 parties |

---

## Commandes rapides

```powershell
# Tests unitaires (Godot 4.7 console)
& "C:\Users\fredc\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe" `
  --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/unit

# Simulation équilibre IA
& "...\Godot_v4.7-stable_win64_console.exe" --headless --path . `
  res://simulation/simulation_main.tscn -- --count 1000 --seed 1

# Résultats télémétrie (dernier run)
# simulation/results/last_telemetry.json
# simulation/results/last_telemetry_report.txt
# simulation/results/last_telemetry_by_seat.csv (dans le dossier run)
```

---

## Maintenir ce fichier

Quand tu **ajoutes un skill projet** dans `.cursor/skills/` :

1. Ajouter une ligne dans le tableau « Skills du projet ».
2. Si besoin, une ligne dans « Par type de fonctionnalité ».
3. Mettre à jour `docs/DECISIONS.md` si c'est une décision d'architecture.

---

*Dernière mise à jour : juillet 2026 — Phase D déconnexion, hot seat ADR-026, lessons-learned, ADR-027 dépannage.*
