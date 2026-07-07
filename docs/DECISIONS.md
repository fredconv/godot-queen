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

---

## ADR-018 — Passe de cartes (3 cartes) hors scope du MVP à l'étape 4

**Contexte** : la variante classique de Hearts inclut une phase de passe de 3 cartes avant chaque manche (rotation gauche / droite / en face / pas de passe selon le numéro de manche), mentionnée comme optionnelle dans `docs/GDD.md` (« Selon la variante... »). L'étape 4 (`MatchManager`) doit décider si cette phase fait partie de l'orchestration de manche dès maintenant ou est reportée.

**Décision** : la passe de cartes n'est **pas implémentée** à l'étape 4. `MatchManager.start_new_hand()` distribue directement 13 cartes par joueur et démarre la phase `PLAYING` (pas de phase `PASSING_CARDS` dans l'enum `Phase`, qui se limite à `DEALING`, `PLAYING`, `HAND_END`, `MATCH_END`). Le MVP retient donc la variante « pas de passe », déjà listée comme une des rotations valides dans `docs/GDD.md`.

**Conséquences** : une manche complète est jouable de bout en bout sans cette phase, ce qui simplifie l'étape 4 (pas d'état supplémentaire, pas de règle de sélection/validation des 3 cartes à passer, pas de rotation à calculer selon le numéro de manche). Si la passe de cartes est ajoutée dans une itération future, elle s'insérera comme une nouvelle valeur de `Phase` entre `DEALING` et `PLAYING`, avec sa propre validation dans `RuleEngine` ou un module dédié — sans remise en cause de l'architecture actuelle (`TrickManager`/`ScoreManager` ne sont pas concernés). `docs/GDD.md` n'a pas besoin d'être modifié : la variante « pas de passe » y est déjà couverte.

---

## ADR-019 — IA de l'étape 5 : `AiStrategy` polymorphe, contexte explicite, convention de sièges

**Contexte** : l'étape 4 a livré un stub IA (`AiPlayer.choose_card(legal_plays, rng)`, méthode statique) qui choisit une carte au hasard, uniquement pour permettre à `tests/integration/test_match_manager.gd` de dérouler une manche complète sans UI. L'étape 5 doit remplacer ce stub par une IA "solide" (au moins un choix stratégique au-delà du hasard pur), tout en restant déterministe (seedable) et en garantissant qu'elle ne propose jamais un coup illégal — sans pour autant dupliquer la logique de `RuleEngine` côté IA, ni transformer `AiPlayer` en objet complexe.

**Décision** :
- **Séparation stratégie / porteur d'état** : `AiPlayer` (`scripts/ai/ai_player.gd`, `RefCounted`) devient une instance (plus une méthode statique) qui porte un `RandomNumberGenerator` seedé et délègue le choix effectif à un objet `AiStrategy` (`scripts/ai/ai_strategy.gd`), interface minimale avec une seule méthode `choose_card(legal_plays, context, rng) -> CardModel`. Deux stratégies concrètes : `RandomLegalStrategy` (choix uniforme, ex-comportement du stub, conservée comme référence/baseline pour les tests) et `HeuristicStrategy` (stratégie par défaut, voir ci-dessous). Ce découpage permet d'ajouter une future stratégie (ex. plusieurs niveaux de difficulté) sans toucher à `AiPlayer` ni à son intégration dans `MatchManager`.
- **`AiPlayer` ne recalcule jamais la légalité** : il reçoit `legal_plays` déjà calculé par `MatchManager.get_legal_plays()` (lui-même délégué à `RuleEngine`) et retourne toujours un élément de cette liste (court-circuit direct si elle ne contient qu'une carte). Aucune stratégie ne peut donc structurellement proposer un coup illégal : la garantie vient de la construction de l'API, pas d'une vérification a posteriori. Testé par croisement direct avec `RuleEngine`/`MatchManager` dans `tests/unit/test_ai_player.gd` (manches complètes simulées, coup choisi toujours vérifié présent dans `legal_plays`).
- **`HeuristicStrategy`, heuristique simple et déterministe** (pas de recherche en profondeur, pas de suivi des probabilités de cartes adverses — volontairement pour rester lisible/testable, cf. philosophie MVP du projet) :
  - **En tête de pli** : joue la carte la plus basse parmi les cartes non "à points" (ni Cœur ni Dame de Pique) si l'une d'elles est disponible, sinon retombe sur la main entière (cas déjà rare, `RuleEngine` filtrant déjà les Cœurs non défoncés/cartes à points au premier pli).
  - **En réponse, si elle peut suivre la couleur demandée** : "ducke" (joue la plus haute carte de la couleur qui ne remporte pas le pli) quand c'est possible, pour se délester de cartes hautes sans prendre le pli ; si elle est de toute façon forcée de le remporter (toutes ses cartes de la couleur battent la meilleure carte déjà posée), joue la plus basse carte gagnante pour conserver ses cartes fortes.
  - **En réponse, si elle ne peut pas suivre la couleur demandée** (donc ne peut de toute façon pas remporter le pli, seule la couleur demandée le peut, voir `RuleEngine.get_trick_winner`) : défausse en priorité la Dame de Pique si elle l'a, sinon le Cœur le plus haut, sinon la carte la plus haute toutes couleurs confondues — décharge les cartes dangereuses dès que c'est gratuit.
  - Les égalités de rang (cartes de couleurs différentes) sont départagées par le `RandomNumberGenerator` fourni, pour garder un peu de variété d'une partie à l'autre sans perdre le déterminisme par seed.
- **Contexte explicite plutôt qu'un couplage direct à `MatchManager`/`RuleEngine`** : `choose_card(legal_plays, context)` reçoit un dictionnaire (`trick_number`, `hearts_broken`, `is_leading`, `lead_suit`, `trick_cards`, `hand_size`) construit par `MatchManager.build_ai_context()`. `AiStrategy`/`AiPlayer` n'importent ni ne référencent `MatchManager` : ils restent testables avec de simples dictionnaires à la main (voir `tests/unit/test_ai_player.gd`), et une future UI ou un futur mode replay peut construire ce contexte différemment sans toucher à l'IA. `trick_cards` (ajout de `TrickManager.get_plays()`, qui garde l'index du joueur contrairement à `get_cards()`) permet à `HeuristicStrategy` de retrouver la meilleure carte déjà posée dans le pli en cours.
- **Convention de sièges, portée par `MatchManager`, pas imposée** : par convention le siège **0 est le joueur humain** (bas de table) et les sièges **1 à 3 sont des adversaires IA** (voir `docs/TECHNICAL_DESIGN.md` pour la disposition des sièges de la maquette table). `MatchManager` n'impose pas cette convention en dur : `set_ai_player(player_index, ai_player)` assigne un `AiPlayer` à n'importe quel siège (`null` pour repasser un siège en contrôle humain), `is_ai_controlled(player_index)` l'interroge, `play_ai_turn()` joue le tour du joueur courant s'il est piloté par une IA (ne fait rien sinon) et `advance_ai_turns()` enchaîne les tours IA jusqu'au prochain tour humain ou la fin de manche/partie. Une simulation à 4 IA (tests) assigne simplement un `AiPlayer` aux 4 sièges, y compris le siège 0.

**Conséquences** :
- Le stub étape 4 change de signature (`AiPlayer.choose_card()` n'est plus statique et prend un contexte au lieu d'un `rng` explicite) : `tests/integration/test_match_manager.gd` a été mis à jour pour instancier `AiPlayer` (avec `RandomLegalStrategy`, pour continuer à tester le cas "baseline aléatoire") et utiliser `MatchManager.play_ai_turn()` plutôt que d'appeler `play_card()` manuellement — ce test exerce donc aussi la nouvelle intégration `MatchManager`↔IA.
- `tests/integration/test_match_ai_simulation.gd` (nouveau) couvre le scénario "4 IA avec la stratégie par défaut" : manche complète sans erreur (plusieurs seeds), partie complète jusqu'au seuil de 100 points, et déterminisme de bout en bout (même seed → même score final, même vainqueur).
- `HeuristicStrategy` reste un choix glouton "un pli à la fois" : elle ne planifie pas plusieurs plis à l'avance (pas de comptage de cartes adverses, pas d'anticipation du "shoot the moon"). C'est un compromis volontaire MVP ; une IA plus forte (ex. estimation du risque de prise de la Dame de Pique compte tenu des cartes déjà vues) pourrait être ajoutée comme une nouvelle `AiStrategy` sans changer l'API existante.
- Aucun changement à `RuleEngine`/`HeartsRules` : l'IA consomme leur sortie telle quelle (`get_legal_plays()`), respectant strictement ADR-004 (règles pures / orchestration / IA découplées).

---

## ADR-020 — Câblage `table.gd` ↔ `MatchManager` (étape 6) : source de vérité unique, pas de délai côté `MatchManager`, réutilisation de `ConfirmDialog`

**Contexte** : l'étape 6 doit rendre `table.tscn` réellement jouable en la connectant à `MatchManager` (étape 4) et à l'IA (étape 5), sans redesigner la maquette visuelle existante (voir `docs/TECHNICAL_DESIGN.md`, section « Architecture UI — table de jeu ») ni transformer `MatchManager` en autoload (ADR-002). Trois problèmes de conception se posent : (1) comment garder l'affichage du pli en cours synchronisé avec `TrickManager` sans dupliquer d'état côté UI, (2) comment rythmer les coups de l'IA (pause visible entre chaque coup) sans modifier `MatchManager`, (3) comment afficher une fin de partie sans construire un nouvel écran dédié.

**Décision** :
- **`table.gd` instancie et possède `MatchManager`** (`_match_manager: MatchManager`, créé dans `_start_new_match()`), avec un `AiPlayer` (`HeuristicStrategy`) assigné aux sièges 1-3 ; le siège 0 reste toujours humain (voir ADR-019). Convention de correspondance siège ↔ position à l'écran : joueur 0 = `SeatBottom`/`TrickCardBottom` (humain), 1 = `SeatLeft`/`TrickCardLeft`, 2 = `SeatTop`/`TrickCardTop`, 3 = `SeatRight`/`TrickCardRight` (ordre de jeu humain → gauche → haut → droite, jamais renommé dans `table.tscn`, seulement mappé côté script).
- **Aucun état de pli dupliqué côté UI** : `_refresh_trick_area()` reconstruit entièrement l'affichage du pli à partir de `MatchManager.trick_manager.get_plays()` à chaque fois (appelée depuis l'écouteur `GameEvents.card_played`). C'est possible car `MatchManager.play_card()` émet `card_played` **avant** de réinitialiser `TrickManager` en cas de pli complet (voir `_resolve_trick()`) : l'écouteur voit donc bien les 4 cartes d'un pli complet le temps qu'un prochain coup soit joué, sans qu'aucun minuteur de "collecte" dédié ne soit nécessaire côté UI — le prochain coup (après la pause `AI_TURN_DELAY_SEC`, voir ci-dessous) déclenche naturellement le rafraîchissement qui vide la zone. Un minuteur de collecte séparé, déclenché depuis l'écouteur `trick_resolved`, a été explicitly écarté : il aurait pu se chevaucher avec le prochain coup joué (le coup suivant peut arriver avant l'expiration du minuteur si celui-ci est mal calibré), effaçant par erreur le début du pli suivant.
- **Le rythme des tours IA est géré entièrement par `table.gd`, pas par `MatchManager.advance_ai_turns()`** : `_run_ai_turns()` réimplémente une boucle équivalente (mêmes conditions d'arrêt : tour humain, fin de manche, fin de partie) mais avec un `await get_tree().create_timer(AI_TURN_DELAY_SEC).timeout` avant chaque coup, pour que l'enchaînement reste visuellement suivable. `MatchManager.advance_ai_turns()` (étape 5) reste inchangée et continue d'être utilisée telle quelle par les tests d'intégration (`tests/integration/test_match_manager.gd`, `test_match_ai_simulation.gd`), qui n'ont pas besoin de ce rythme.
- **Pas de nouvel écran de fin de partie à cette étape** : `_confirm_dialog` (`scenes/components/confirm_dialog.tscn`, déjà utilisé pour confirmer l'abandon d'une partie en cours) est réutilisé pour afficher le message de fin de partie (vainqueur + scores). Un état `DialogPurpose` (`LEAVE_MATCH_CONFIRM` / `MATCH_END_ACK`) distingue les deux usages : dans le cas `MATCH_END_ACK`, les deux boutons ("Oui"/"Non", libellés non modifiés pour rester dans le scope de cette étape) ramènent tous les deux au menu principal, faute d'action alternative sensée une fois la partie terminée. Un écran de fin de partie dédié (ADR potentiel futur) reste prévu à l'étape 7 (`docs/ROADMAP.md`, Menus & UX).
- **Surbrillance de jouabilité plutôt que sélection à deux temps** : contrairement au scaffold de démonstration (sélection d'une carte puis désélection possible), un clic sur une carte légale de la main humaine la joue immédiatement (`_on_human_card_selected` → `MatchManager.play_card()`), sans étape de confirmation intermédiaire. Seules les cartes légales (`MatchManager.get_legal_plays()`) restent pleinement opaques et réagissent au survol/clic ; les cartes illégales sont grisées (`ILLEGAL_CARD_ALPHA`) et non connectées à aucun signal d'entrée, pour éviter toute interaction fantôme.

**Conséquences** :
- `scripts/ui/table.gd` passe d'un scaffold visuel statique à un contrôleur d'état réactif aux signaux `GameEvents`, tout en respectant la séparation établie (ADR-004) : il ne contient aucune règle de jeu, uniquement de la lecture d'état (`MatchManager`) et de l'affichage.
- Les 86 tests GdUnit4 existants (étapes 2-5) restent inchangés et verts : aucune modification n'a été nécessaire côté `scripts/rules/`, `scripts/match/` ou `scripts/ai/`. Aucun nouveau test automatisé n'a été ajouté pour `table.gd` à cette étape (logique fortement couplée à l'arbre de scène Godot et à des minuteurs asynchrones, priorité plus basse dans `docs/TEST_PLAN.md` — section « Priorités » place les tests UI/e2e en dernier) ; la validation s'est faite par une exécution manuelle (F5) et une exécution headless (`--quit-after`) vérifiant l'absence d'erreur de script sur plusieurs manches jouées automatiquement par les 3 IA jusqu'au premier tour humain.
- Limite connue : si le joueur quitte la partie (bouton MENU) pendant qu'un minuteur de pause IA est en attente, ce minuteur peut tenter de reprendre son exécution après le changement de scène (risque marginal de coroutine orpheline, comportement générique de Godot avec `await`/`SceneTreeTimer` non spécifique à ce projet) ; jugé acceptable au vu de la fenêtre de risque très courte (`AI_TURN_DELAY_SEC` ≈ 0,8s) et non traité explicitement pour rester dans le scope MVP de cette étape.

---

## ADR-021 — Animations de pose/ramassage de pli et popup de fin de partie : deux écarts assumés par rapport à ADR-020

**Contexte** : le câblage `table.gd` ↔ `MatchManager` décrit en ADR-020 (convention de sièges, rythme des tours IA via `AI_TURN_DELAY_SEC`, surbrillance des cartes illégales) est repris tel quel. Deux nouvelles exigences UX viennent cependant s'y ajouter : (1) chaque carte jouée doit glisser visuellement de la main/du siège d'origine jusqu'à son emplacement de pli en ~0.3s, et une fois le pli complet, la carte gagnante doit être mise en évidence, le pli rester visible au moins 2s, puis les 4 cartes doivent glisser ensemble vers le siège du vainqueur et disparaître d'un coup ; (2) la fin de partie doit afficher un popup dédié (avatar du vainqueur, flèche pointant vers son siège, scores de tous les joueurs, bouton "Rejouer"), plutôt que de réutiliser `ConfirmDialog`.

**Décision** :
- **État du pli en cours dupliqué côté UI, par exception à ADR-020** : `table.gd` maintient désormais `_trick_card_views` (dictionnaire `player_index -> CardView`), rempli/vidé explicitement par la séquence de jeu/résolution, plutôt que d'être reconstruit à chaque `GameEvents.card_played` à partir de `TrickManager.get_plays()`. Raison : la séquence demandée (surbrillance → pause 2s → glissement → disparition) doit s'exécuter de façon strictement séquentielle et verrouillée (`_turn_locked`) entre la résolution d'un pli et le coup suivant ; or `MatchManager.play_card()` émet `card_played` et `trick_resolved` de façon synchrone l'un après l'autre, donc deux écouteurs de signaux indépendants et asynchrones (l'un pour animer la pose, l'autre pour la résolution) s'exécuteraient en concurrence sans garantie d'ordre. `table.gd` pilote donc directement toute la séquence (pose → résolution → collecte) depuis un seul point d'entrée par coup joué (`_on_human_card_selected`/`_run_ai_turns`), ce qui élimine structurellement ce risque de chevauchement (au lieu de le gérer via un minuteur, explicitement écarté par ADR-020 pour cette même raison).
- **Calcul de position des cartes animées sans dépendre de `pivot_offset`/`global_position` combinés** : les cartes créées pour l'animation (`_spawn_traveling_card`) gardent une rotation nulle et un `pivot_offset` par défaut `(0, 0)` ; leur centre visuel est alors toujours `global_position + size * scale / 2`, une relation stable quelle que soit la version de Godot (la sémantique exacte de `global_position` vis-à-vis du pivot a varié entre versions du moteur). Les positions de départ/arrivée (main, siège, emplacement de pli) sont lues via `get_global_transform_with_canvas()`, une API de transform pure non ambiguë.
- **Nouveau `MatchEndDialog` (`scenes/components/match_end_dialog.tscn`) plutôt que `ConfirmDialog` réutilisé** : affiche l'avatar et le nom du vainqueur, une flèche parmi 4 (haut/bas/gauche/droite, même convention de siège qu'ADR-020) pointant vers son siège, la liste des scores de tous les joueurs, et un bouton "Rejouer" qui redémarre une nouvelle partie sur la même scène de table (`table.gd::_start_new_match()`, qui recrée `MatchManager` et réassigne les `AiPlayer`). Remplace l'usage `MATCH_END_ACK` de `ConfirmDialog` envisagé en ADR-020 (qui restait de toute façon prévu comme provisoire, un écran dédié étant annoncé pour l'étape 7).

**Conséquences** :
- `TableAnimations` (`scripts/ui/table_animations.gd`) regroupe les trois animations (pose, surbrillance, collecte) en fonctions statiques sans état, appelées depuis `table.gd`.
- Les 86 tests GdUnit4 existants restent inchangés et verts : aucune modification dans `scripts/rules/`, `scripts/match/` ou `scripts/ai/`.
- Limite connue : comme en ADR-020, aucun test automatisé dédié à `table.gd`/`TableAnimations` (logique couplée à l'arbre de scène et à des `Tween`/minuteurs asynchrones, priorité UI/e2e la plus basse selon `docs/TEST_PLAN.md`).

---

## ADR-022 — Préparation multijoueur : actions, snapshots et sauvegarde profil v1

**Contexte** : objectif long terme = 4 joueurs humains en ligne/LAN avec serveur autoritaire. Le gameplay solo ne doit pas être cassé ; le réseau ne doit pas être intégré prématurément dans `table.gd`.

**Décision** :
- Introduire `PlayCardAction` / `ActionResult` et `LocalMatchController` comme couche entre UI et `MatchManager` (phases 1 et 4).
- Événements et snapshots sérialisables (`scripts/game_events/`, `GameSnapshotBuilder`) pour la synchro future (phases 2-3).
- Identités siège (`PlayerProfile`, `LobbyService`) distinctes du profil local persisté (`LocalPlayerProfile` + `PlayerProfileService` autoload).
- Sauvegarde `user://savegame.json` versionnée (`GameSaveStore` v1) : `player_profile`, `settings`, `stats`, `score_history` ; migration depuis l'ancienne clé `config`.
- `player_id` local stable ≠ `display_name` ; stats locales solo ≠ stats serveur futures.
- Champs auth/newsletter réservés dans le profil (`auth_provider = "local"`, pas d'OAuth ni d'email marketing).
- `NetworkService` reste un stub ; ENet reporté à la phase 7.

**Conséquences** : `table_play_flow.gd` passe par `match_controller.submit_action()` ; tests unitaires sur actions, snapshots, sauvegarde et lobby. Voir `docs/MULTIPLAYER_DESIGN.md` et `docs/MULTIPLAYER_AUDIT.md`.

---

## ADR-023 — Architecture IA gameplay : faisabilité, décision, exécution, messages implicites

**Contexte** : l'IA doit gérer la chasse à la Lune, la contre-Lune, les personnalités (chasseur, passif, équilibré), un score de confiance et des messages table rares — sans dévoiler la tactique ni annoncer l'intention à chaque pli.

**Décision** :
- **Quatre modules distincts** dans `scripts/ai/` :
  - `MoonFeasibility` — règles + maths : qui *peut* encore viser la Lune ;
  - `MoonSuspicion` — heuristique : quel adversaire semble dangereux ;
  - `AdaptiveAiStrategy` — hiérarchie de modes (`MINIMIZE` / `CHASE_MOON` / `BREAK_MOON`) et file d'annonces ;
  - stratégies d'exécution (`MoonShooterStrategy`, `MoonBreakerStrategy`, `PassiveStrategy`, `HeuristicStrategy`).
- **Règles Lune** :
  - si un autre joueur a ≥ 1 point, les trois autres ne peuvent pas chasser ;
  - si ≥ 2 joueurs ont des points, la Lune est morte pour tous ;
  - seul le détenteur unique des points peut encore l'envisager (sans obligation — perte accidentelle d'un pli) ;
  - récupération après points pris : contrôle de main + confiance (`_recovery_path_viable`).
- **Messages table** (via `TableAiAnnouncement`) : uniquement `more_aggressive` et `suspect_moon` ; formulation observationnelle (« pense que … vise la Lune ») ; max 1 bandeau par manche, espacement ≥ 5 plis ; pas d'annonce de contre-Lune ni de chasse explicite.
- **Contexte unique** : `MatchManager.build_ai_context()` alimente toutes les IA (`moon_feasible`, `moon_busted`, confiance, scores, historique plis).
- **Documentation agent** : skill `.cursor/skills/dame-de-pique-ai-gameplay/`, règle `.cursor/rules/ai-gameplay.mdc`, hook post-édition `.cursor/hooks/after-ai-gameplay-edit.ps1`.

**Conséquences** : toute évolution IA/Lune/messages doit mettre à jour les tests `test_moon_feasibility`, `test_adaptive_ai_strategy`, `test_moon_suspicion` et, si seuils modifiés, la simulation batch (`simulation/`). Skill personnel réutilisable : `card-game-ai-design` (~/.cursor/skills/).

**Télémétrie décisions (2026-07)** : `AiTelemetryCollector` branché sur `MatchManager.telemetry` enregistre tentatives/détections/cassages Lune, regret stratégique, rentabilité, sacrifices, Dame de Pique. Sorties simulation : `telemetry.json`, `telemetry_by_seat.csv`, `telemetry_report.txt`. Catalogue : `.cursor/skills/dame-de-pique-ai-gameplay/telemetry-metrics.md`.
