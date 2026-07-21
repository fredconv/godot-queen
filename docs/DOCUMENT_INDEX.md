# DOCUMENT_INDEX — Dame de Pique

```
Version : V01
Created : 2026-07-21
Last Updated : 2026-07-21
Status : Active
```

Tableau de bord docs du projet. **Source of truth idées** = [`00_INBOX/INBOX.md`](00_INBOX/INBOX.md).

---

## État & pilotage

| Doc | Rôle |
|-----|------|
| [`../STATUS.md`](../STATUS.md) | État courant (jalons, blockers) |
| [`../NEXT.md`](../NEXT.md) | Prochaine action concrète |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Historique livré |
| [`ROADMAP.md`](ROADMAP.md) | Phases produit |
| [`PROJECT_STATUS.md`](PROJECT_STATUS.md) | Fiche statut détaillée |
| [`WORKFLOW.md`](WORKFLOW.md) | Workflow agent (idées → code) |

## Inbox / backlog

| Doc | Rôle |
|-----|------|
| [`00_INBOX/INBOX.md`](00_INBOX/INBOX.md) | **Source of truth** idées (`IDEA-XXXX`) |
| [`00_INBOX/KANBAN.md`](00_INBOX/KANBAN.md) | Vue kanban (régénérée) |
| [`00_INBOX/BACKLOG_PRIORITY.md`](00_INBOX/BACKLOG_PRIORITY.md) | Priorités P0/P1/P2 |

## Audits qualité

| Doc | Rôle |
|-----|------|
| [`QUALITY-AUDIT.md`](QUALITY-AUDIT.md) | **Audit complet + plan polish** (2026-07-21) — canonique |
| [`AUDIT-PRE-1.0.md`](AUDIT-PRE-1.0.md) | Audit pré-1.0 (S0–S4) |
| [`AUDIT_CONFORMITE_optimisation_DDP.md`](AUDIT_CONFORMITE_optimisation_DDP.md) | Conformité règles optimisation GD (réf. TLD) |
| [`MULTIPLAYER_AUDIT.md`](MULTIPLAYER_AUDIT.md) | Audit multijoueur |
| [`MCP-AUDIT-SPLASH-HOTSEAT-2026-07-16.md`](MCP-AUDIT-SPLASH-HOTSEAT-2026-07-16.md) | Playtest MCP splash/hot seat |

## Design & technique

| Doc | Rôle |
|-----|------|
| [`GDD.md`](GDD.md) | Règles Hearts |
| [`TECHNICAL_DESIGN.md`](TECHNICAL_DESIGN.md) | Architecture technique |
| [`DECISIONS.md`](DECISIONS.md) | ADR |
| [`TEST_PLAN.md`](TEST_PLAN.md) | Stratégie tests |
| [`MULTIPLAYER_DESIGN.md`](MULTIPLAYER_DESIGN.md) | Spec multi |
| [`../ui/Components.md`](../ui/Components.md) | Catalogue composants UI |
| [`../ui/DesignSystem.md`](../ui/DesignSystem.md) | Identité visuelle (si présent) |
| [`ui/VISUAL_POLISH_NATIVE_PLAN.md`](ui/VISUAL_POLISH_NATIVE_PLAN.md) | **IDEA-00021** — audit + plan polish natif (lots L0–L9) |

## Agent Cursor

| Artefact | Rôle |
|----------|------|
| [`../AGENTS.md`](../AGENTS.md) | Index skills / rules / hooks |
| [`.cursor/skills/`](../.cursor/skills/) | Skills projet |
| [`.cursor/rules/`](../.cursor/rules/) | Rules projet |
| [`.cursor/architecture/dame-de-pique/`](../.cursor/architecture/dame-de-pique/) | Lessons-learned |

---

## Commandes chat utiles

| Dis | Effet |
|-----|--------|
| `idée:` … | Capture INBOX (pas de code) |
| `implémente:` IDEA-XXXX | Lance l’implémentation |
| `priorise le backlog` | Met à jour BACKLOG_PRIORITY + KANBAN |
| `DOC_OK` | Capitalise la session |
| `SYNC` | Sync workspace + handoff |
| `verify` | Lance les tests documentés |
