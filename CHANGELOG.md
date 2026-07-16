# Changelog — DameDePique

## [Unreleased]

### Meta
- `feat/simulation-batch` merged into `main` (2026-07-17, fast-forward)

### Fixed
- Configuration : peuplement OptionButton avant sélection (crash `item_count = 0`)
- Simulation batch : `MatchManager.emit_game_events = false` — ne pollue plus StatsService / Audio / Session
- Bouton « Réinitialiser stats » dans Configuration
- Bouton « Lune soupçonnée » masqué en début de manche (avant pli 3 si Cœurs non défoncés)
- Overlays menu : backdrop plus opaque (α 0,78) — plus de fuite visuelle du menu
- Hot seat : reset du dim bullet-time après handoff
- Menu principal : double titre retiré (Label masqué, branding splash seul)
- Warnings GDScript : shadows (`peer_connected`, `are_hearts_broken`, `target_size`, `ease_type`, …) + params unused préfixés `_`

### Changed
- Projet déplacé vers CreativeOS `projects/Games/DameDePique` (2026-07-16)
- Docs STATUS / NEXT / PROJECT_STATUS alignés audit pré-1.0
- TopMenuBar : boutons MUSIQUE / SUIVANT retirés (contrôle audio dans Configuration)
- Lobby multi : « Rejoindre par code » vs « Rejoindre (IP) » + contraste ItemList
- Assets morts / scènes orphelines déplacés vers `assets/_archive/` ; export exclut archive, reports, simulation
- Settings/Help : instantiation lazy au premier open (menu + table) — A2
- i18n : mode « Partage d'appareil » en FR (EN conserve Hot seat) — A3
- AudioService : crossfade volume court entre pistes musique — A5
- Playtest MCP : recettes D/E/F (settings, scores, moon) — A7
