# Journal des décisions (ADR) — Dame de Pique

Registre des décisions d'architecture importantes, au format court : contexte, décision, conséquences.

---

## ADR-001 — Renderer GL Compatibility

**Contexte** : le jeu est un jeu de cartes 2D, sans besoin de rendu 3D avancé ni d'effets nécessitant Forward+.

**Décision** : utiliser le renderer **GL Compatibility** (`renderer/rendering_method="gl_compatibility"`), avec driver D3D12 sur Windows.

**Conséquences** : compatibilité matérielle plus large (machines modestes, intégré graphique), légère limitation sur certains effets de rendu avancés — non bloquant pour un jeu de cartes 2D.

---

## ADR-002 — `MatchManager` n'est pas un autoload

**Contexte** : une manche/partie de Dame de Pique a un cycle de vie propre, borné dans le temps (de l'entrée sur la table à la sortie de la partie).

**Décision** : `MatchManager` est instancié comme nœud enfant de la scène de table (`table.tscn`), **pas** comme autoload.

**Conséquences** : pas d'état global résiduel entre deux parties, tests d'intégration plus simples (on peut instancier plusieurs `MatchManager` isolés), obligation de passer explicitement les références nécessaires (via signaux `GameEvents` ou injection directe) plutôt que d'y accéder globalement.

---

## ADR-003 — Code en anglais, documentation en français

**Contexte** : l'équipe communique en français, mais les conventions de code Godot/GDScript sont majoritairement en anglais dans l'écosystème.

**Décision** : tous les identifiants de code (variables, fonctions, fichiers, classes, signaux) sont en **anglais**. La documentation (`docs/`), les commentaires et les messages destinés au joueur peuvent être en **français**.

**Conséquences** : cohérence avec les conventions Godot/GDScript standard, meilleure lisibilité pour d'éventuelles contributions externes ou packages tiers, tout en gardant la documentation accessible à l'équipe francophone.

---

## ADR-004 — Séparation stricte règles / orchestration / présentation

**Contexte** : éviter un script monolithique mêlant règles du jeu, gestion du tour et affichage.

**Décision** : les règles pures vivent dans `scripts/rules/` (sans dépendance à un nœud Godot ni à l'UI), l'orchestration dans `scripts/match/`, la présentation dans `scenes/` et `scripts/ui/`. La communication entre couches passe par les signaux de `GameEvents`.

**Conséquences** : règles testables unitairement sans instancier de scène, UI remplaçable sans toucher à la logique de jeu, mais nécessite de la discipline pour ne pas court-circuiter cette séparation au fil du développement.

---

## ADR-005 — Dos de carte canonique : `card_back_red`

**Contexte** : le pack `assets/cards/kerenel_Cards_seperated/` fournit deux dos de carte (`card_back_red`, `card_back_blue`). Il faut un dos unique et cohérent pour représenter les mains adverses (face cachée) partout dans l'UI.

**Décision** : `card_back_red.png` est le dos de carte canonique du projet. Toute vue de carte face cachée (`CardView` en `scenes/components/`) utilise cette texture par défaut. `card_back_blue.png` reste disponible en asset mais n'est pas utilisé pour l'instant (thème alternatif potentiel, hors scope MVP).

**Conséquences** : cohérence visuelle garantie via une constante unique dans `card_view.gd` (pas de duplication du chemin de texture) ; changer de dos plus tard (option cosmétique) ne nécessite de toucher qu'un seul endroit.

---

## ADR-006 — Mobile first, orientation paysage, résolution de référence 1280x720

**Contexte** : le jeu doit être jouable confortablement sur mobile en priorité, avec une table à 4 joueurs (adversaires en haut/gauche/droite, joueur humain en bas) qui a besoin d'espace horizontal pour afficher les 4 sièges et la zone de pli centrale.

**Décision** : l'orientation **paysage est l'orientation principale** (portrait envisagé plus tard si l'ergonomie le permet, non prioritaire pour le MVP). La résolution de référence reste **1280x720**, avec `window/stretch/mode="canvas_items"` et `window/stretch/aspect="expand"` (déjà configurés dans `project.godot`). La disposition de la table (`scenes/table/table.tscn`) est construite avec des ancrages relatifs (`Control` + anchors, pas de positions absolues) pour rester lisible sur différents ratios d'écran mobiles.

**Conséquences** : toute nouvelle scène UI doit être pensée avec des `Control` ancrés (pas de `Node2D` avec positions en dur pour l'UI) ; un futur mode portrait nécessitera une réorganisation des ancrages mais pas une réécriture de la logique d'affichage (séparation données/-présentation respectée).

---

## ADR-007 — Référence de mise en page UI (maquette table de jeu)

**Contexte** : une maquette utilisateur définit la disposition cible de la table de jeu (table de cartes 4 joueurs, barre de menu façon bois en haut, zone de pli centrale en croix, main du joueur en éventail en bas).

**Décision** : la structure de scène `scenes/table/table.tscn` suit cette maquette : fond feutre vert, `TopMenuBar` (barre bois avec boutons AIDE/SCORES/NOUVEAU/MENU/réglages + zone d'info centrale dynamique), 4 `PlayerSeat` (haut/gauche/droite/bas avec avatar, nom, score entre parenthèses, indicateur de pénalité cœur), `TrickArea` en croix (une carte par direction), `HumanHandArea` avec la main du joueur en éventail face visible. Détail complet en `docs/TECHNICAL_DESIGN.md`.

**Conséquences** : la maquette sert de référence stable pour l'implémentation UI des prochaines étapes (interactions, animations) ; les noms de nœuds (`TurnLabel`, `ScoreLabel`, `PlayerBottomHand`, `TrickArea`, `BtnMenu`, etc.) sont fixés pour rester stables face à de futurs tests automatisés.

---

## ADR-008 — Direction artistique UI : pixel art coloré et lisible

**Contexte** : le joueur fournit de nouvelles références visuelles (cartes en pixel art, table de jeu en pixel art, menu de réglages orné en pixel art) pour orienter l'habillage graphique du jeu. Trois exigences guident cette direction : **pixel art** (esthétique rétro à pixels nets), **coloré** (palette vive, pas de tons délavés) et **clarté** (lisibilité à taille mobile, contraste élevé, rangs/couleurs de carte et textes UI facilement identifiables). Le pack de cartes actuel (`assets/cards/kerenel_Cards_seperated/`) n'est **pas** dessiné en pixel art (illustrations lissées) ; le remplacer est un chantier séparé, non trivial (52 cartes + dos), hors scope de cette mise à jour.

**Décision** :
- La direction pixel art s'applique en priorité au **chrome UI** (barre de menu, boutons, panneaux, cadres, menu de réglages, surbrillances de sélection), pas aux sprites de carte pour l'instant. Le pack `kerenel_Cards_seperated` reste utilisé tel quel en MVP ; il pourra être remplacé par un pack pixel art dans une itération dédiée (voir section « Pipeline art » de `docs/TECHNICAL_DESIGN.md`).
- Filtrage de texture **Nearest** (pixels nets, pas de flou d'interpolation linéaire) comme filtre par défaut du projet (`rendering/textures/canvas_textures/default_texture_filter=0` dans `project.godot`). Ce choix généralise un comportement déjà présent : `scenes/components/card_view.tscn` applique déjà `texture_filter = 1` (Nearest) sur sa `TextureRect`, donc ce changement n'altère pas le rendu des cartes existantes — il rend simplement cohérent le rendu Nearest par défaut pour tous les futurs éléments UI pixel art (boutons, panneaux, icônes), qui n'auront pas besoin de surcharger le filtre nœud par nœud.
- La palette doit rester **vive et contrastée** (voir palette proposée dans `docs/TECHNICAL_DESIGN.md`), pas de tons pastel/désaturés.
- Les surbrillances de sélection de carte suivent la référence utilisateur : **coins en crochet** (« corner brackets ») bleu ou jaune superposés sur la carte sélectionnée, plutôt qu'un halo ou un changement de couleur de fond.
- Un thème Godot dédié (`resources/themes/pixel_theme.tres`) sert de point d'entrée unique pour les futurs styles pixel art (StyleBox de boutons/panneaux, police pixel, couleurs). Il est créé en stub minimal dans cette itération et sera enrichi au fil de l'intégration des assets pixel art réels.

**Conséquences** : aucune régression visuelle sur le pack de cartes actuel (filtre déjà Nearest par nœud) ; les futurs éléments UI pixel art profitent d'un rendu net par défaut sans configuration répétée ; nécessite de documenter clairement, tant que le pack de cartes n'est pas remplacé, que « pixel art » désigne le style du chrome UI et non (encore) celui des cartes, pour éviter toute confusion lors de l'ajout de nouveaux assets ; le stub `pixel_theme.tres` n'a pas d'effet visuel tant qu'il n'est pas peuplé de styles (rôle purement préparatoire à ce stade).

---

## ADR-009 — Intégration police « Pixelify Sans » et feuille de sprites de boutons UI

**Contexte** : deux nouveaux assets pixel art ont été fournis pour amorcer l'habillage prévu par l'ADR-008 : une police (`assets/fonts/PixelifySans-VariableFont_wght.ttf`, déjà importée par Godot) et une feuille de sprites de boutons (`assets/sprites/8bit-color-retro-pixel-art-buttons-interface-menu-icons-old-video-game-symbols.png`, 2000×770 px, déjà importée).

**Décision — police** :
- `Pixelify Sans` est déclarée comme `default_font` de `resources/themes/pixel_theme.tres`. Comme `table.tscn` assigne déjà ce thème sur son nœud racine `Table`, tous les `Label`/`Button` descendants (dont ceux de `TopMenuBar`) héritent automatiquement de la police sans modification supplémentaire des scènes.
- La taille de police par défaut du moteur n'est **pas** surchargée (`default_font_size` non défini) pour ne prendre aucun risque de débordement dans les conteneurs existants (ex. `PlayerSeat` à taille fixe 160×150) — pur changement de police, pas de changement de taille.
- Les réglages d'import de la police (`antialiasing=1`, `hinting=3`) sont conservés tels quels : `Pixelify Sans` est une police vectorielle au style pixel, pas une police bitmap pure ; désactiver l'antialiasing la rendrait moins lisible à certaines tailles UI mobiles sans bénéfice visuel réel.

**Décision — feuille de sprites de boutons** :
- La feuille contient une grille **irrégulière** de 5 colonnes (limites en pixels, image source 2000×770) :
  - Colonne 1 (x 88–566) et colonne 3 (x 788–1156) : boutons "pilule" avec **texte anglais incrusté dans l'image** (`START`, `CLOSE`, `BACK`, `LEVEL`, `STOP`, `EXIT`, `NEXT`, `PLAY`), 4 lignes (y 49–177 / 230–358 / 411–539 / 592–720).
  - Colonne 2 (x 603–747) : 4 **cercles unis sans texte ni icône** (violet, orange, rose, bleu — mêmes lignes que ci-dessus). Seule cette colonne est réutilisable telle quelle pour des boutons icône génériques.
  - Colonne 4 (x 1195–1674) : 3 grands boutons "pilule" avec texte incrusté (`SETTING`, `OPTIONS`, `RESTART`), lignes y 49–230 / 294–475 / 539–720.
  - Colonne 5 (x 1714–1911) : 3 badges carrés avec icône incrustée (cœur, croix, power), mêmes lignes que la colonne 4.
  - Chaque sprite n'existe qu'en **un seul état visuel** (pas de variante hover/pressed par couleur).
- Comme les boutons "pilule"/badges portent du texte ou des icônes anglais figés dans l'image (`START`, `SETTING`, cœur, croix...), ils ne peuvent pas être réutilisés tels quels comme fond générique derrière les libellés français existants (`AIDE`, `SCORES`, `NOUVEAU`, `MENU`) sans afficher un texte incohérent superposé.
- **Intégration minimale retenue** : seuls les 2 boutons icône sans libellé de `TopMenuBar` sont habillés avec un cercle de la colonne 2, via un `AtlasTexture` (région découpée dans la feuille) + `StyleBoxTexture` appliqué directement en `theme_override_styles/normal` sur le nœud (pas via le thème global, pour ne pas affecter les boutons texte) :
  - `BtnHamburger` (☰) → cercle violet (région `Rect2(603, 49, 144, 128)`).
  - `BtnSettings` (⚙) → cercle bleu (région `Rect2(603, 592, 144, 128)`).
- Seul l'état `normal` est câblé (pas de `hover`/`pressed` dédiés, faute d'état visuel disponible dans la feuille) : ces boutons retombent sur le style par défaut du moteur pour le survol/l'appui, ce qui est visuellement incohérent mais non bloquant.

**TODO (polish futur, hors scope de cette itération)** :
- Ajouter un retour visuel de survol/appui pour `BtnHamburger`/`BtnSettings` (piste simple : teinte via `self_modulate` au survol/appui dans `top_menu_bar.gd`, sans nouvel asset).
- Les boutons texte (`AIDE`, `SCORES`, `NOUVEAU`, `MENU`) restent sur le `StyleBoxFlat` par défaut du moteur : aucun fond "pilule" texte-libre n'est disponible dans la feuille actuelle. Une prochaine itération devra soit obtenir un pack de boutons pixel art sans texte incrusté, soit construire un `StyleBoxFlat`/`StyleBoxTexture` dédié cohérent avec la palette de l'ADR-008 (bords nets, sans coins arrondis).
- Les 2 cercles restants de la colonne 2 (orange, rose) ne sont pas utilisés pour l'instant ; disponibles pour de futurs boutons icône (ex. options de manche, aide contextuelle).

---

## ADR-010 — Mapping des effets sonores de carte

**Contexte** : 4 fichiers audio ont été fournis dans `assets/audio/` : `Card Dealing one card.wav`, `Card Dealing multiple.wav`, `Card Playing launching one card.wav` et `Card Playing launching one card alt.wav`. Le besoin couvre 4 événements de jeu : distribution, survol, pose d'une carte, ramassage d'un pli — soit deux événements de plus que de fichiers réellement dédiés (aucun asset n'est nommé "hover" ou "collect").

**Décision** :
- `Card Dealing one card.wav` → distribution d'une carte individuelle (`AudioService.play_deal_card()`), appelée une fois par carte dans une séquence étalée dans le temps.
- `Card Dealing multiple.wav` → distribution en bloc (`play_deal_burst()`) **et** ramassage du pli (`play_trick_collect()`) : les deux événements correspondent au même geste sonore (plusieurs cartes qui se déplacent ensemble), aucun asset dédié au ramassage n'ayant été fourni.
- `Card Playing launching one card.wav` → carte posée sur la table (`play_card_played()`).
- `Card Playing launching one card alt.wav` → réutilisé pour le survol (`play_card_hover()`), joué à volume réduit (`HOVER_VOLUME_SCALE = 0.6`) : cette variante "alt" du son de pose est plus légère qu'un doublon exact, et se prête mieux à un retour tactile discret et répétitif.
- Le mapping complet (chemins de fichiers) vit dans `scripts/core/audio_paths.gd` (constante `AudioPaths`), point de vérité unique référencé par `AudioService`.
- Le survol respecte un cooldown de 120 ms (`HOVER_COOLDOWN_SEC`) pour ne pas saturer l'oreille quand le pointeur traverse rapidement plusieurs cartes de la main.
- `AudioService` écoute directement `GameEvents.card_played` et `GameEvents.trick_resolved` (voir ADR-004) : un futur `MatchManager` n'a rien de spécial à faire pour l'audio de base, émettre ces signaux suffit. Les méthodes publiques (`play_card_played()`, etc.) restent disponibles pour les appels directs depuis l'UI (ex. démo sans `MatchManager`).
- En l'absence d'animation de distribution réelle, la démo de `table.gd` (`_populate_demo_hand`) joue quand même la séquence sonore de distribution (étalée via des `Timer`), pour donner un aperçu audio en attendant l'implémentation visuelle.

**Conséquences** : deux événements (`hover`, `trick_collect`) reposent sur des sons réaffectés plutôt que dédiés — acceptable pour le MVP, mais à remplacer si des assets dédiés sont fournis plus tard (un seul point de modification : `AudioPaths`). Le format `.wav` fourni est adapté au bureau ; un export Web/mobile devra idéalement obtenir des versions `.ogg` (plus légères) des mêmes sons — voir section « Audio » de `docs/TECHNICAL_DESIGN.md`.

---

## ADR-011 — `CardModel` : couple suit+rank plutôt qu'un simple int id

**Contexte** : une carte à jouer peut être modélisée soit par un couple `(suit, rank)` explicite, soit par un unique entier id (0-51, calculé à partir de la couleur et du rang). Les deux approches sont utilisées dans l'écosystème des jeux de cartes : l'id compact est pratique pour la sérialisation/le réseau, le couple explicite est plus lisible et direct pour la logique de jeu (règles, IA, affichage).

**Décision** : `CardModel` (`scripts/gameplay/cards/card_model.gd`) porte `suit: int` et `rank: int` comme **source de vérité**, avec un id dérivé exposé via `get_id()` (et reconstructible via `CardModel.from_id(id)`) pour les cas qui en ont besoin (indexation dans un tableau de 52 cases, hachage, future sérialisation compacte).

**Conséquences** :
- Le code de règles/IA (étapes 3 et 5) manipule directement `card.suit`/`card.rank` sans décoder un id à chaque accès (ex. `card.is_heart()`, `card.compare_rank(other)`), ce qui reste lisible même pour une personne peu familière du calcul d'id.
- L'id reste disponible partout où un entier compact est utile (ex. `Deck`/`PlayerHand` internes actuels n'en ont pas besoin, mais un futur `MatchManager` réseau ou une sauvegarde compacte via `SaveService` pourraient s'en servir sans dupliquer la logique de calcul).
- Léger surcoût mémoire (deux `int` au lieu d'un seul) totalement négligeable pour 52 cartes en mémoire ; pas de compromis de performance réel pour ce projet.
- `Rank` utilise des valeurs entières **explicites** 2 à 14 (pas 0-based) précisément pour que `get_id()` et les comparaisons de rang restent lisibles sans offset cognitif supplémentaire.

---

## ADR-012 — Installation de GdUnit4 en branche `master` (pré-v6.2) pour compatibilité Godot 4.7

**Contexte** : le projet cible Godot **4.7 stable** (`config/features` dans `project.godot`). Au moment de l'intégration (étape 2), la dernière version taguée de GdUnit4 (`v6.1.3`) annonce une compatibilité officielle seulement jusqu'à Godot 4.6.2 ; le support de Godot 4.7 (beta5/rc2) est en cours sur la branche `master`, en vue d'une future release `v6.2`.

**Décision** : installer GdUnit4 depuis la branche `master` du dépôt officiel (`github.com/MikeSchulze/gdUnit4`, miroir `godot-gdunit-labs/gdUnit4`) plutôt que le dernier tag stable, en copiant uniquement le dossier `addons/gdUnit4/` (pas tout le dépôt) dans le projet. Version obtenue : `6.2.0-rc2` (`addons/gdUnit4/plugin.cfg`).

**Conséquences** :
- Le plugin fonctionne correctement avec Godot 4.7 stable (validé : 24 tests unitaires exécutés avec succès en CLI headless, voir `docs/TEST_PLAN.md`).
- Étant une pré-version (`rc2`, pas encore taguée `v6.2.0` finale), une mise à jour vers le tag stable équivalent sera à envisager dès sa publication (remplacer le contenu de `addons/gdUnit4/` par la nouvelle version, aucun changement de code de test attendu si l'API reste stable).
- Le dossier `test/` interne de GdUnit4 (tests du framework lui-même, ~1 Mo) a été conservé tel quel (vendoring simple, pas de modification du plugin) plutôt que retiré, pour rester au plus près de la distribution officielle et faciliter une future mise à jour par simple remplacement de dossier.
- `addons/gdUnit4/plugin.cfg` est activé dans `project.godot` (`[editor_plugins] enabled=...`).

---

## ADR-013 — Musique d'ambiance : playlist mélangée, volume bas par défaut, préférence persistée

**Contexte** : 4 musiques d'ambiance ont été fournies dans `assets/audio/musics/` (`Lantern Table.mp3`, `Lantern Table_alt.mp3`, `Mossy Shuffle.mp3`, `Mossy Shuffle_alt.mp3`). Le besoin : une musique de fond qui démarre seule au lancement du jeu, enchaîne automatiquement les pistes, reste discrète par rapport aux SFX de carte (ADR-010), et peut être coupée/changée par le joueur depuis `TopMenuBar`.

**Décision** :
- **Playlist mélangée** : `AudioService.play_random()` mélange `AudioPaths.MUSIC_TRACKS` et lit les pistes séquentiellement ; à la fin d'une piste (signal `finished` du lecteur), la piste suivante de l'ordre mélangé s'enchaîne automatiquement (`_on_music_finished()` → `_play_track_at_playlist_pos()`). Une fois la playlist épuisée, elle est re-mélangée et la lecture continue en boucle. Un seul `AudioStreamPlayer` dédié à la musique (`_music_player`), séparé du pool SFX existant.
- **Démarrage automatique + filet de sécurité** : `AudioService._ready()` appelle `ensure_music_playing()`, qui lance `play_random()` si `ConfigService.get_music_enabled()` est vrai et qu'aucune piste n'est déjà en cours — la musique démarre donc dès le lancement du jeu (scène `Bootstrap`) et continue sans interruption pendant la partie (`AudioService` est un autoload, son état survit aux changements de scène). `main_menu.gd` rappelle aussi `ensure_music_playing()` dans son propre `_ready()` : appel idempotent, sans effet si la musique tourne déjà, qui garantit que la musique a bien démarré au plus tard à l'arrivée sur le menu même si l'auto-démarrage à l'initialisation du moteur a été trop tôt pour prendre effet de façon fiable.
- **Volume musique nettement plus bas que les SFX** : `ConfigService.DEFAULT_MUSIC_VOLUME = 0.35` contre `DEFAULT_SFX_VOLUME = 1.0`, pour que les sons de carte (distribution, pose, ramassage) restent toujours audibles par-dessus la musique de fond. Conversion en dB via `_music_volume_to_db()`, indépendante de `_volume_scale_to_db()` (SFX) pour ne pas mélanger les deux échelles de volume.
- **Bouton "MUSIQUE" (toggle)** : coupe/reprend la musique via `AudioStreamPlayer.stream_paused` (pause, pas arrêt complet) — reprise au même point plutôt que redémarrage. L'état est persisté via `ConfigService.set_music_enabled()`.
- **Bouton "SUIVANT"** : `AudioService.play_next()` avance immédiatement à la piste suivante de l'ordre mélangé (garantie différente de la piste courante, sauf playlist à une seule piste) ; ne réactive pas la musique si elle était coupée.
- **Persistance** : `ConfigService` charge/sauvegarde `sfx_volume`, `music_volume`, `music_enabled` et `language` via `SaveService` (`user://savegame.json`, clé `"config"`), avec chargement paresseux (`_ensure_loaded()`) conservé en filet de sécurité. `ConfigService` est déclaré avant `AudioService` dans `project.godot` (qui lit la configuration musique dès son propre `_ready()`), mais le chargement paresseux évite de dépendre strictement de cet ordre.

**Conséquences** : ajout de deux boutons stables dans `TopMenuBar` (`BtnToggleMusic`, `BtnNextMusic`, libellés français "MUSIQUE : ON/OFF" et "SUIVANT") câblés depuis `table.gd` ; aucun changement sur les SFX existants (pool et volume SFX inchangés). Le format `.mp3` (musiques, fichiers longs) diffère du `.wav` utilisé pour les SFX (ADR-010) — choix cohérent avec l'usage (musique longue compressée vs SFX courts non compressés). Une future UI de réglages (sliders de volume) pourra réutiliser `ConfigService.get_music_volume()`/`set_music_volume()` sans changement d'`AudioService`.

---

## ADR-014 — Avatars joueur animés à partir de feuilles de sprites `Char_00X.png`

**Contexte** : 4 feuilles de sprites ont été fournies dans `assets/sprites/` (`Char_001.png` à `Char_004.png`), chacune en grille 4x4 de frames 48x48 (192x192 au total). Seule la première ligne (4 frames) représente une animation d'idle exploitable ; les 3 autres lignes ne sont pas exploitées pour l'instant (contenu/usage non défini). L'avatar de `PlayerSeat` était jusqu'ici un simple `ColorRect` gris (placeholder).

**Décision** :
- Nouveau composant `scenes/components/player_avatar.tscn` + `scripts/components/player_avatar.gd` (`PlayerAvatar`), encapsulant un `AnimatedSprite2D` unique. La ressource `SpriteFrames` est construite **par code** (pas de `.tres` par personnage) à partir de 4 `AtlasTexture` découpant la ligne 0 de la feuille (régions `(0,0)`, `(48,0)`, `(96,0)`, `(144,0)`, taille 48x48) : une seule animation `"idle"`, en boucle, à 8 fps.
- `character_index` (0-3, `@export_range`) sélectionne la feuille via une constante `CHARACTER_SHEETS` interne au script ; `set_character_sheet(path)` reste disponible pour charger une feuille hors de cette liste.
- `PlayerSeat` expose `character_id: int` (0-3) qui pousse la valeur vers l'avatar enfant (nœud `Avatar`, toujours sous `InfoBox/AvatarPlaceholder`, aux côtés de `TurnHighlight` qui reste inchangé). Affectation dans `table.tscn` : `SeatBottom` (joueur humain) = `Char_001`, `SeatTop` = `Char_002`, `SeatLeft` = `Char_003`, `SeatRight` = `Char_004`.
- Filtrage **Nearest** explicite sur l'`AnimatedSprite2D` (`texture_filter = 1`), cohérent avec `default_texture_filter=0` déjà défini au niveau projet (ADR-008) — redondant mais explicite, à l'image de `card_view.tscn`. Frame affichée à 64x64 (`scale = 1.3333`) pour remplir le même espace que l'ancien placeholder.

**Conséquences** : le nœud `Avatar` change de type (`ColorRect` → instance de `PlayerAvatar`) mais conserve son nom, donc aucun autre script ne référence de chemin cassé. Ajouter un 5e personnage ne nécessite qu'une entrée dans `CHARACTER_SHEETS` (et éventuellement relever la borne de `character_id`/`character_index`). Les lignes 1 à 3 des feuilles (animations non-idle) restent disponibles pour une future itération (ex. animation de jeu de carte) sans changement de structure de fichier.

---

## ADR-015 — `TopMenuBar`/`ConfirmDialog` sur un `CanvasLayer` dédié (fiabilité du dessin par-dessus la table)

**Contexte** : un bug rapporté par un utilisateur montrait la barre de menu supérieure (`TopMenuBar`) absente à l'exécutable exporté alors qu'elle s'affichait correctement en éditeur (F5/F6). L'ancienne organisation reposait uniquement sur l'ordre des nœuds enfants de `Table` (`TopMenuBar`/`ConfirmDialog` placés en derniers pour se dessiner par-dessus `Background`/`PlayerSeats`/`TrickArea`/`HumanHandArea`) : ce mécanisme est correct mais fragile, car il dépend entièrement de l'ordre des nœuds dans `table.tscn` — un futur ajout de nœud, une réorganisation, ou un export utilisant une version en cache de la scène peut silencieusement casser l'ordre de dessin sans erreur visible.

**Décision** : `TopMenuBar` et `ConfirmDialog` sont désormais des enfants d'un `CanvasLayer` dédié (`UILayer`, `layer = 10`) plutôt que des enfants directs de `Table`. Un `CanvasLayer` se dessine indépendamment de la hiérarchie de `CanvasItem` de son parent, au-dessus de tout contenu de layer inférieur (le contenu de jeu reste sur le layer implicite `0`) — l'ordre de dessin ne dépend donc plus de la position des nœuds dans l'arbre. Les ancres/offsets de `TopMenuBar`/`ConfirmDialog` sont inchangés (un `CanvasLayer` sans transform ne modifie pas le système de coordonnées de ses enfants `Control`), et les deux nœuds gardent leurs noms stables (`table.gd` référence désormais `$UILayer/TopMenuBar` et `$UILayer/ConfirmDialog`).

**Conséquences** : le chrome UI de la table est garanti visible au-dessus du reste quel que soit l'ordre futur des autres nœuds, en éditeur comme à l'export. Toute future itération ajoutant d'autres overlays (ex. écran de fin de manche affiché par-dessus la table) devrait suivre le même principe (`CanvasLayer` dédié) plutôt que de dépendre de l'ordre des enfants.

---

## ADR-016 — Variante Hearts retenue : "shoot the moon" et restriction du premier pli

**Contexte** : l'étape 3 (moteur de règles pur, `scripts/rules/`) doit implémenter des points de règle où plusieurs variantes de Hearts coexistent dans l'écosystème du jeu : le traitement exact du « shooting the moon » (qui marque quoi), l'étendue de la restriction du premier pli (Dame de Pique seule, ou toutes les cartes à points), et la définition précise de « Cœurs défoncés ».

**Décision** :
- **Shoot the moon** : un joueur qui capture les 26 points d'une manche (les 13 Cœurs **et** la Dame de Pique) marque **0 point** ; chacun des 3 autres joueurs marque **26 points** (`HeartsRules.TOTAL_POINTS_PER_HAND`). C'est la variante déjà décrite dans `docs/GDD.md` (section « Règles du jeu ») ; cette ADR la formalise pour l'implémentation de `RuleEngine.score_hand()`. Alternative écartée : créditer le joueur de -26 (score négatif) — rejetée pour rester cohérente avec un score de manche toujours positif ou nul, plus simple à additionner et à afficher.
- **Premier pli, restriction élargie aux cartes à points (pas seulement la Dame de Pique)** : au tout premier pli d'une manche, aucune carte à points (Cœur **ou** Dame de Pique) ne peut être jouée — ni pour l'entamer, ni en défausse — sauf si le joueur concerné n'a plus **que** des cartes à points en main (Cœurs et/ou Dame de Pique), auquel cas il y est forcé faute d'alternative. C'est une extension volontaire de la règle habituellement énoncée uniquement pour la Dame de Pique (« Dame de Pique interdite au premier pli »), afin d'éviter qu'un joueur défausse un Cœur dès le premier pli et défonce prématurément les Cœurs sans raison de jeu (comportement standard dans de nombreuses implémentations informatiques de Hearts). Implémenté par un mécanisme de repli unique dans `RuleEngine._legal_leads()` / `_legal_follows()` : si le filtrage des règles ne laisse aucune carte légale, la main entière redevient jouable (couvre uniformément tous les cas « aucun autre choix », y compris une main 100% Cœurs qui doit pouvoir entamer malgré la restriction Cœurs-non-défoncés).
- **Cœurs défoncés par la Dame de Pique** : jouer la Dame de Pique (même si le joueur suit une autre couleur) défonce les Cœurs au même titre qu'un Cœur, car c'est aussi une carte à points capturable. C'est cohérent avec le fait que la Dame de Pique est interdite au premier pli pour la même raison que les Cœurs, et évite un état incohérent où la Dame de Pique aurait été jouée mais où un joueur ne pourrait toujours pas entamer avec elle... alors qu'elle n'existe qu'en un seul exemplaire (donc sans conséquence pratique sur l'entame, mais garde la règle simple à énoncer : « toute carte à points jouée défonce les Cœurs »).

**Conséquences** : `RuleEngine` (`scripts/rules/rule_engine.gd`) et `HeartsRules` (`scripts/rules/hearts_rules.gd`) implémentent ces trois points exactement tels que décrits ci-dessus (voir `docs/TECHNICAL_DESIGN.md` pour le détail de l'API). `docs/GDD.md` est mis à jour pour refléter la restriction élargie du premier pli. Toute IA future (étape 5) qui s'appuie sur `RuleEngine.get_legal_plays()` hérite automatiquement de ces règles sans les réimplémenter.

---

## ADR-017 — Fond de `TopMenuBar`/`ConfirmDialog` : `Panel`+`StyleBoxFlat` et `custom_minimum_size` au lieu de `ColorRect`+`offset_bottom` seul (fiabilité à l'export)

**Contexte** : malgré la correction ADR-015 (`CanvasLayer` dédié `UILayer`), un utilisateur a signalé que la barre de menu supérieure (`TopMenuBar`) restait affichée sans son fond marron à l'exécutable exporté (Windows, export release), alors que les boutons/labels s'affichaient correctement et que tout semblait normal en éditeur (F5/F6). Un export headless + capture d'écran automatisée (via `get_viewport().get_texture().get_image()` piloté par un flag `--debug-screenshot` temporaire) a permis de reproduire le bug de façon déterministe et d'en isoler la cause exacte par dichotomie :
- Le nœud racine `TopMenuBar` (instance de `top_menu_bar.tscn`, placé sous `UILayer/`) a pour ancres `anchor_top = 0`, `anchor_bottom = 0` et `offset_bottom = 64.0` — une hauteur fixe de 64px indépendante de la taille du viewport. **En exécutable exporté, cette hauteur calculée retombe à 0** (confirmé par un dump de `get_rect()`/`offset_bottom` en jeu), alors que la même scène chargée directement (hors du flux `bootstrap → main_menu → table`) ou l'ajout d'un `Control` ad hoc avec les mêmes propriétés directement dans `table.tscn` calculent la hauteur correctement (64px). Le problème est donc spécifique à la combinaison « racine de scène instanciée sous un `CanvasLayer` » + « hauteur définie uniquement via `offset_bottom` (anchor à 0) », qui ne survit pas de façon fiable à la compilation de la scène lors de l'export.
- Conséquence en cascade : `Margin` (le `MarginContainer` contenant les boutons/labels) reste visible malgré la hauteur nulle de son parent, car un `Container` impose son **propre minimum de taille** calculé à partir de ses enfants (boutons/labels), indépendamment du rect hérité par ancres — d'où l'illusion trompeuse que « la barre marche, juste sans son fond ». À l'inverse, `Background` (`ColorRect` puis `Panel`, sans enfants, donc sans minimum de taille propre) hérite du rect à hauteur nulle de son parent et ne dessine donc rien, quel que soit son type de nœud (`ColorRect` et `Panel` ont exactement le même symptôme — ce n'est pas un problème spécifique à `ColorRect`). Le même mécanisme affectait le voile `Backdrop` de `ConfirmDialog`, invisible à l'export bien que le `Panel` de la boîte de dialogue (positionné par ancres fixes indépendantes de la taille du parent) s'affichait normalement.

**Décision** :
- Le fond de `TopMenuBar` (`Background`) et le voile de `ConfirmDialog` (`Backdrop`) passent de `ColorRect` à `Panel` + `StyleBoxFlat` (cohérent avec le reste du projet — `TrickCardTop/Bottom/Left/Right`, `ConfirmDialog/Panel` utilisent déjà ce pattern), par hygiène générale même si le type de nœud n'était pas la cause du bug.
- **Correctif réel** : `TopMenuBar` (nœud racine de `top_menu_bar.tscn`) reçoit un `custom_minimum_size = Vector2(0, 64)` explicite, en plus de son `offset_bottom = 64.0` existant. `custom_minimum_size` force un plancher de taille **toujours respecté par le moteur** (`size = max(taille_calculée_par_ancres, custom_minimum_size)`), avec la même garantie que celle qui sauvait déjà `Margin` du même bug — sans dépendre du calcul d'ancres/offsets fragile à l'export. `ConfirmDialog`/`Backdrop` n'a pas besoin de cette béquille : ses ancres couvrent tout l'écran sur les deux axes (`anchor_right = anchor_bottom = 1.0`, sans offset), un cas qui n'est pas affecté par ce bug (seule la combinaison anchor=0 + offset fixe semble en cause).
- Le code de diagnostic temporaire (flags `--debug-table`/`--debug-screenshot`, dump de rects) ajouté pour isoler le bug a été entièrement retiré après correction ; aucune trace n'en subsiste dans `bootstrap.gd`/`table.gd`.

**Conséquences** : `TopMenuBar` affiche désormais son fond bois de façon fiable en éditeur **et** à l'export, vérifié par capture d'écran automatisée sur un export Windows réel (pas seulement un contrôle visuel manuel). Règle générale à retenir pour tout futur composant UI dont la taille sur un axe dépend uniquement d'un `offset_*` (anchor à 0 ou 1 sur cet axe, sans container parent) : accompagner cet `offset_*` d'un `custom_minimum_size` correspondant, surtout pour les nœuds racines de scènes instanciées sous un `CanvasLayer`, par précaution jusqu'à ce que la cause exacte de cette régression d'ancrage à l'export soit comprise/corrigée côté moteur (Godot 4.7).
