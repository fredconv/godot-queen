# Changelog — DameDePique

## [Unreleased]

### Fixed
- Configuration : peuplement OptionButton avant sélection (crash `item_count = 0`)
- Simulation batch : `MatchManager.emit_game_events = false` — ne pollue plus StatsService / Audio / Session
- Bouton « Réinitialiser stats » dans Configuration
- Bouton « Lune soupçonnée » masqué en début de manche (avant pli 3 si Cœurs non défoncés)
- Overlays menu : backdrop plus opaque (α 0,78) — plus de fuite visuelle du menu
- Hot seat : reset du dim bullet-time après handoff
- Menu principal : double titre retiré (Label masqué, branding splash seul)

### Changed
- Projet déplacé vers CreativeOS `projects/Games/DameDePique` (2026-07-16)
- Docs STATUS / NEXT / PROJECT_STATUS alignés audit pré-1.0
- TopMenuBar : boutons MUSIQUE / SUIVANT retirés (contrôle audio dans Configuration)
- Lobby multi : « Rejoindre par code » vs « Rejoindre (IP) » + contraste ItemList
