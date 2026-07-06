# Checklist projet — Dame de Pique

> **Dernière mise à jour :** juillet 2026  
> **Commit de référence :** `4de9794`  
> **Étape courante :** fin de l’étape 6 + hardening — **prochaine : étape 7**

Fichier de **continuité** : si le projet est mis en pause, reprendre ici pour savoir où on en est.

**Légende :** ✅ fait · 🔄 en cours · ⏳ à faire · 📋 planifié (décision prise, pas encore codé) · ❌ hors scope MVP

---

## A. Étapes ROADMAP

| # | Étape | Statut | Notes |
|---|---|---|---|
| 1 | Scaffolding | ✅ | Arborescence, bootstrap, autoloads, docs |
| 2 | Modèle de données & tests | ✅ | CardModel, Deck, PlayerHand, GdUnit4 |
| 3 | Règles (moteur pur) | ✅ | HeartsRules, RuleEngine, 33 tests |
| 4 | MatchManager | ✅ | Orchestration, 11 tests intégration |
| 5 | IA de base | ✅ | HeuristicStrategy, 22 tests IA/simulation |
| 6 | Interface table jouable | ✅ | table.gd ↔ MatchManager, animations pli |
| 7 | Menus & UX | ⏳ | Voir section B |
| 8 | Audio & polish visuel | ⏳ | Animations pli anticipées ; reste polish |
| 9 | Tests E2E & stabilisation | ⏳ | |
| 10 | Export & distribution | ⏳ | Windows prioritaire |

---

## B. Étape 7 — Menus & UX (détail)

### B.1 Déjà fait (anticipation)

- [x] Menu principal (`main_menu.tscn`) avec navigation de base
- [x] Bootstrap → menu (plus d’écran statut isolé)
- [x] Bouton NOUVELLE PARTIE → table
- [x] Bouton QUITTER
- [x] Retour MENU depuis la table (confirmation si partie en cours)
- [x] `GameSession` synchronisé via `GameEvents` (plus d’appel manuel au lancement)
- [x] Popup fin de **manche** (`HandEndDialog`)
- [x] Popup fin de **partie** (`MatchEndDialog`) — Rejouer / Quitter
- [x] `ConfigService` : volume SFX, volume musique, musique on/off, langue (persisté JSON)
- [x] `SaveService` : API lecture/écriture `user://savegame.json`
- [x] Contrôles musique sur la barre de menu table (toggle + piste suivante)

### B.2 À faire — priorité haute (clôturer étape 7)

- [ ] **Écran Configuration** complet (remplacer le stub modal)
  - [ ] Sliders volume SFX / musique
  - [ ] Toggle musique
- [x] Sélecteur langue (6 locales : fr, en, de, es, pt, zh + drapeaux)
- [x] Textes UI via CSV modulaires (`menu`, `table`, `dialogs`, `common`, `game`)
- [x] Rafraîchissement immédiat à la fermeture Configuration (`LocaleAware`)
  - [ ] Bouton retour / sauvegarde automatique à la fermeture
- [ ] **Écran Scores** (remplacer le stub modal)
  - [ ] Définir le périmètre : stats session ? historique persisté ? classement IA ?
  - [ ] Brancher sur `SaveService` si persistance souhaitée
- [ ] Revue UX menu : focus clavier, états disabled explicites, lisibilité mobile
- [ ] Mettre à jour `docs/ROADMAP.md` (marquer étape 7 ✅ quand validée)
- [ ] Validation manuelle du parcours complet menu → partie → menus

### B.3 À faire — priorité moyenne (étape 7 enrichie)

- [ ] **Sélecteur de ruleset** dans le menu (voir section E — multi-jeux)
  - [ ] Hearts seul jouable
  - [ ] Autres jeux listés « Bientôt disponible » (disabled)
  - [ ] Persistance du choix via `ConfigService`
  - [ ] Panneau texte des règles (`rules_panel`)
- [ ] Tests manuels accessibilité : navigation Tab, tooltips, contrastes
- [x] Internationalisation : clés `scripts/core/i18n/`, CSV `translations/`, 6 langues

### B.4 Hors scope étape 7 (reporté)

- [ ] Sauvegarde / reprise d’une **partie en cours** (mid-game) — ❌ MVP
- [ ] Multijoueur / hot-seat — ❌ MVP
- [ ] Passe de 3 cartes — ❌ ADR-018

---

## C. Correctifs & hardening récents (faits)

- [x] Cartes non jouables : voile gris (plus de transparence seule)
- [x] Scores avatars synchronisés pendant la manche
- [x] Séparation scores manche (avatars) vs cumul partie (scoreboard)
- [x] Hints tour : 2♣, cœurs non défoncés
- [x] Pause 4,5 s sur dernier pli avant popup fin de partie
- [x] Animation distribution depuis bords d’écran
- [x] Fix tween parallèle (`set_trans` sur Tween, pas sur chaîne null)
- [x] Fix références libérées (free immédiat dos de cartes)
- [x] Garde-fous sortie de scène (`_scene_exiting`, `is_inside_tree()` après `await`)
- [x] Changement de scène menu différé (`call_deferred`)
- [x] Typage : `Array[PlayerSeat]`, `Phase`, signal `card_played(CardModel)`
- [x] `class_name PlayerSeat` + relayout au `resized`
- [x] Suppression code mort `_play_deal_sfx`

---

## D. Infrastructure & outillage (faits)

- [x] GdUnit4 installé (`addons/gdUnit4/`)
- [x] 88 tests automatisés verts
- [x] Godot MCP (Coding-Solo) — `.cursor/mcp.example.json`
- [x] Context7 MCP — doc Godot 4.7 (config locale gitignorée)
- [x] Règles Cursor (`.cursor/rules/godot.mdc`, `context7.mdc`)

---

## E. Planifié — Multi-jeux / multi-rulesets (après étape 7)

> Décision : **ne pas refactorer le moteur avant l’étape 7**. Documenter puis implémenter en étape 7.5.

### E.1 Maintenant (optionnel, faible risque)

- [ ] Rédiger **ADR multi-ruleset** dans `docs/DECISIONS.md`
- [ ] Créer stub `RulesetDefinition` (Resource) + `.tres` Hearts uniquement
- [ ] Lister rulesets futurs en data (`enabled: false`) : Spades, Whist, Oh Hell, Bridge simplifié

### E.2 Étape 7 (intégration menu, sans toucher MatchManager)

- [ ] `RulesetRegistry` : résolution par id + fallback Hearts + warning
- [ ] UI sélecteur + panneau règles
- [ ] Persistance `ruleset_id` dans `ConfigService`

### E.3 Étape 7.5 (abstraction moteur)

- [ ] Interface `CardGameRules` (validation, scoring, deal, fin manche/partie)
- [ ] `HeartsRuleset` : wrapper autour de `RuleEngine` / `HeartsRules` existants
- [ ] Injection dans `MatchManager` (défaut = Hearts)
- [ ] Déplacer hints UI Hearts de `table.gd` vers le ruleset
- [ ] 2–3 tests `RulesetRegistry` (fallback, id invalide)
- [ ] Vérifier 88 tests existants toujours verts

### E.4 Plus tard (nouveaux jeux)

- [ ] Implémenter un second ruleset (ex. Spades) — un fichier à la fois
- [ ] Stratégie IA par ruleset

---

## F. Étape 8 — Audio & polish (à faire)

- [ ] Revue complète intégration `AudioService` (tous les SFX mappés)
- [ ] Assets audio manquants ou placeholders
- [ ] Effets visuels (`assets/vfx/`)
- [ ] Revue ergonomie mobile (paysage, tailles touch)
- [ ] Animation distribution : polish timing / son (déjà animée visuellement)

---

## G. Étape 9 — Stabilisation (à faire)

- [ ] Tests end-to-end (export web + Playwright si applicable)
- [ ] Investiguer fuites ObjectDB à la sortie tests headless
- [ ] Tests UI ciblés (optionnel : GdUnit4 scene runner sur table)
- [ ] Revue performance (allocations, tweens, rebuild main)

---

## H. Étape 10 — Export (à faire)

- [ ] Preset export Windows
- [ ] Build de validation
- [ ] Export web (optionnel, pour E2E)

---

## I. Revue collègue — checklist rapide

À valider avant de coder l’étape 7 :

- [ ] Partie Hearts jouable sans bug bloquant (1 manche + 1 partie complète)
- [ ] Règles conformes au GDD (2♣, cœurs, shoot the moon, 100 pts)
- [ ] Scores manche / partie compréhensibles
- [ ] Popups fin manche / fin partie OK
- [ ] Retour menu sans crash (y compris pendant animation)
- [ ] 88 tests GdUnit4 verts
- [ ] Architecture documentée (`PROJECT_STATUS.md`, `DECISIONS.md`)
- [ ] Priorités étape 7 validées (config ? scores ? multi-ruleset ?)

---

## J. Commandes utiles (reprise après pause)

### Lancer les tests

```powershell
cd C:\Projects\Godot\dame-de-pique
& "C:\chemin\Godot_v4.7-stable_win64.exe" --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/
```

### Ouvrir le projet

- Godot 4.7 → `project.godot`
- Scène principale : `scenes/bootstrap/bootstrap.tscn`

### Git — état attendu

- Branche : `main`
- Dernier commit stable : `4de9794`
- Fichiers non versionnés normaux : `reports/`, `.cursor/mcp.json`, logs locaux

---

## K. Journal des sessions (à compléter)

| Date | Commit | Travail effectué | Prochaine action |
|---|---|---|---|
| 2026-07 | `4de9794` | Hardening table, typage, Context7 | Démarrer étape 7 — écran Configuration |
| 2026-07 | `4b4da42` | Table jouable (étape 6) | UX scores, popups, animations |
| 2026-07 | `979d2a4` | IA heuristique (étape 5) | Câblage UI table |
| — | — | *(ajouter une ligne à chaque session)* | — |

---

## L. Références rapides

| Besoin | Fichier |
|---|---|
| Résumé complet pour review | `docs/PROJECT_STATUS.md` |
| Design jeu | `docs/GDD.md` |
| Architecture technique | `docs/TECHNICAL_DESIGN.md` |
| Décisions d’architecture | `docs/DECISIONS.md` |
| Plan de tests | `docs/TEST_PLAN.md` |
| Étapes officielles | `docs/ROADMAP.md` |
