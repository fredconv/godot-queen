# Changelog — DameDePique

## [Unreleased]

### Meta
- `feat/simulation-batch` merged into `main` (2026-07-17, fast-forward)
- 2026-07-21 : gouvernance idées type TLD — `docs/00_INBOX/`, `docs/WORKFLOW.md`, `docs/DOCUMENT_INDEX.md`, `docs/QUALITY-AUDIT.md`

### Fixed
- Configuration : peuplement OptionButton avant sélection (crash `item_count = 0`)
- Simulation batch : `MatchManager.emit_game_events = false` — ne pollue plus StatsService / Audio / Session
- Bouton « Réinitialiser stats » dans Configuration
- Bouton « Lune soupçonnée » masqué en début de manche (avant pli 3 si Cœurs non défoncés)
- Overlays menu : backdrop plus opaque (α 0,78) — plus de fuite visuelle du menu
- Hot seat : reset du dim bullet-time après handoff
- Hot seat privacy overlay : `set_process(false)` quand fermé (IDEA-00004)
- Menu principal : double titre retiré (Label masqué, branding splash seul)
- Warnings GDScript : shadows (`peer_connected`, `are_hearts_broken`, `target_size`, `ease_type`, …) + params unused préfixés `_`
- Scène orpheline `scenes/menus/dialog_template.tscn` retirée (copie archive seule) — IDEA-00003

### Changed
- Skill `godot-pixel-ui-button` : pipeline vivant = `NinePatchButton` / `button_template` (PixelButton = legacy)
- `ui/Components.md` + `AGENTS.md` alignés sur le pipeline bouton réel
- **Pack A (2026-07-21)** : overlays menu — fade/scale open-close (`ModalOverlayScreen` + `UiOffsetAnim`) ; HandEnd/Confirm/MatchEnd entrée unifiée
- **Pack B (2026-07-21)** : `NinePatchButton` hover scale 1.04 / pressed 0.97 + or ; top bar StyleBoxFlat coins 0 + bordure or + ombres labels
- **IDEA-00009 (2026-07-21)** : `NetworkService` façade — `NetworkLobbyBook`, `NetworkMatchDisconnectCoordinator`, `NetworkOnlineBridge` (API publique inchangée)
- **Pack C (2026-07-21)** : `UiStyleFactory` banners/overlays pixel (coins 0) ; micro-scale entrée banners ; score pop discret `PlayerSeat`
- **IDEA-00021 (2026-07-21)** : polish visuel natif L1–L9 — `UiThemeCatalog` (type variations), panneau menu, sections config, descriptions modes, HUD séparateurs + pulse tour, scores animés, cartes (ombre/rim/shake/land), `PixelNotification`, vignette shader Compatibility ; pass 2 chrome NinePatch menus/modales
- **IDEA-00010 (2026-07-21)** : découpe lobby — `MultiplayerLobbySessions` / `InviteCode` / `PublicIp` ; écran ~425 L ; fix recherche online `_sessions` → `item_count`
- Projet déplacé vers CreativeOS `projects/Games/DameDePique` (2026-07-16)
- Docs STATUS / NEXT / PROJECT_STATUS alignés audit pré-1.0
- TopMenuBar : boutons MUSIQUE / SUIVANT retirés (contrôle audio dans Configuration)
- Lobby multi : « Rejoindre par code » vs « Rejoindre (IP) » + contraste ItemList
- Assets morts / scènes orphelines déplacés vers `assets/_archive/` ; export exclut archive, reports, simulation
- Settings/Help : instantiation lazy au premier open (menu + table) — A2
- i18n : mode « Partage d'appareil » en FR (EN conserve Hot seat) — A3
- AudioService : crossfade volume court entre pistes musique — A5
- Playtest MCP : recettes D/E/F (settings, scores, moon) — A7
