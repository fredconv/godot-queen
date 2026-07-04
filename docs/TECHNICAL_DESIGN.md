# Technical Design — Dame de Pique

## Vue d'ensemble

Le projet suit une architecture en couches : **services transverses (autoloads)** ↔ **orchestration de partie (non-autoload)** ↔ **règles du jeu (pures)** ↔ **présentation (scènes/UI)**. Le code est écrit en **anglais** (variables, fonctions, fichiers), les commentaires et la documentation peuvent être en français.

## Arborescence

```
scenes/
  bootstrap/     # scène d'entrée (Bootstrap), vérifie les autoloads
  menus/         # menu principal, écrans de fin de manche/partie
  table/         # scène de table de jeu (plateau, mains, plis)
  components/    # composants de scène réutilisables (carte visuelle, jeton score...)

scripts/
  core/          # utilitaires génériques, types de base partagés (Carte, Enums...)
  gameplay/cards/# logique liée aux cartes (deck, tri, comparaison)
  rules/         # règles pures du jeu (validation de coup, calcul de score)
  match/         # orchestration d'une manche/partie (MatchManager, non-autoload)
  ai/            # stratégie des joueurs IA
  services/      # autoloads (GameEvents, SaveService, AudioService, ConfigService, DebugService)
  ui/            # logique des écrans (contrôleurs de menu, HUD)
  components/    # scripts de composants réutilisables

resources/
  data/          # ressources de données (.tres) : configuration de règles, decks...
  themes/        # thèmes UI Godot (Theme resources)

assets/
  cards/         # sprites des cartes
  audio/         # sons et musiques
  fonts/         # polices
  vfx/           # effets visuels (particules, shaders)

tests/
  unit/          # tests unitaires (règles, scoring, deck)
  integration/   # tests d'intégration (déroulement d'une manche complète)

docs/            # documentation de conception et de suivi
```

## Autoloads (services transverses)

Les autoloads sont volontairement limités à des **services sans état de partie** :

| Autoload        | Rôle                                                              |
|------------------|--------------------------------------------------------------------|
| `GameEvents`     | Bus de signaux global (découplage UI ↔ logique ↔ services)        |
| `SaveService`     | Lecture/écriture de la sauvegarde locale (`user://`)              |
| `AudioService`    | Lecture des sons/musiques                                          |
| `ConfigService`   | Options utilisateur (volume, langue)                               |
| `DebugService`    | Logging centralisé (`push_warning`/`push_error`), flag debug       |

## MatchManager : pourquoi PAS un autoload

Le `MatchManager` (orchestrateur d'une manche/partie : distribution, tour de jeu, calcul des scores) **n'est volontairement pas un autoload**. Une partie a un cycle de vie propre (créée quand on entre sur la table, détruite quand on la quitte) : en faire un autoload créerait un état global persistant inutile et compliquerait les tests (impossible d'instancier plusieurs parties isolées, état résiduel entre les parties). Il sera instancié comme nœud de la scène `table.tscn`.

## Flux de signaux (`GameEvents`)

```
MatchManager            GameEvents                 UI / AI
    |--- match_started ----->|------------------------>|  (affiche la table, réinitialise les scores)
    |--- card_played ------->|------------------------>|  (anime la carte jouée, met à jour la main)
    |--- trick_resolved ---->|------------------------>|  (anime le ramassage du pli, MAJ score courant)
    |--- score_updated ----->|------------------------>|  (MAJ affichage des scores)
    |--- match_ended -------->|------------------------>|  (affiche l'écran de fin de partie)
```

Le `MatchManager` émet les événements via `GameEvents`, les écrans UI et les IA s'y abonnent sans dépendance directe entre eux.

## Séparation des responsabilités

- **`scripts/rules/`** : fonctions pures (pas de nœud Godot), testables sans scène (validation de coup, calcul de score, détection du « shooting the moon »).
- **`scripts/match/`** : orchestration avec état (tour courant, plis, scores cumulés) — dépend de `rules/` et `gameplay/cards/`.
- **`scripts/ai/`** : stratégie de choix de carte pour les joueurs IA, dépend de `rules/` pour connaître les coups valides.
- **`scripts/ui/`** : contrôleurs d'écran, ne contiennent aucune règle de jeu, réagissent aux signaux de `GameEvents`.

## Modèle de données — cartes (étape 2)

Types purs (`RefCounted`, sans nœud Godot), testables sans instancier de scène (voir `docs/TEST_PLAN.md` et `tests/unit/`).

### `Suit` — `scripts/core/suit.gd`

Enum non nommé porté par `class_name Suit` : `Suit.CLUBS`, `Suit.DIAMONDS`, `Suit.SPADES`, `Suit.HEARTS` (valeurs 0-3, ordre stable utilisé pour l'id de carte). `Suit.ALL` liste les 4 valeurs ; `Suit.to_display_name(suit)` renvoie le libellé français ("Trèfle", "Carreau", "Pique", "Cœur").

### `Rank` — `scripts/core/rank.gd`

Même pattern, valeurs entières **explicites 2 à 14** (`Rank.TWO`...`Rank.ACE`) plutôt qu'un enum 0-based : la valeur correspond directement au rang réel, ce qui rend les comparaisons de force lisibles sans offset caché. `Rank.MIN`/`Rank.MAX`/`Rank.ALL` et `Rank.to_display_name(rank)` ("Valet", "Dame", "Roi", "As", ou le nombre).

### `CardModel` — `scripts/gameplay/cards/card_model.gd`

`class_name CardModel extends RefCounted`. Source de vérité : `suit` + `rank` (voir ADR-011 pour le choix face à un simple int id). API :

- `get_id() -> int` : id dérivé 0-51 (`suit * 13 + (rank - Rank.MIN)`), pratique pour l'indexation/hachage, pas la source de vérité.
- `equals(other)`, `is_heart()`, `is_spade()`, `is_queen_of_spades()`.
- `compare_rank(other)` : compare la force de deux cartes de la **même** couleur (utilitaire de modèle de données, pas une règle de jeu — la résolution de pli avec couleur demandée est prévue en étape 3, `scripts/rules/`).
- `_to_string()` (override natif utilisé par `str()`) : libellé lisible, ex. `"Dame de Pique"`.
- Statiques : `CardModel.from_id(id)`, `CardModel.all_cards()` (les 52 cartes, ordre canonique couleur puis rang, sans mélange).

### `Deck` — `scripts/gameplay/cards/deck.gd`

`class_name Deck extends RefCounted`. Représente l'ordre courant de pioche (tableau interne, le "dessus" du paquet est la fin du tableau).

- `Deck.create_standard_52()` : fabrique statique, 52 cartes non mélangées.
- `shuffle(seed_value := -1)` : Fisher-Yates en place ; `seed_value >= 0` donne un mélange déterministe (tests, replays), sinon `randomize()`.
- `deal(count) -> Array[CardModel]`, `draw() -> CardModel` (ou `null` si vide), `peek()`, `size()`, `is_empty()`, `reset()`.

### `PlayerHand` — `scripts/gameplay/cards/player_hand.gd`

`class_name PlayerHand extends RefCounted`. Maintient les cartes **triées** (couleur puis rang croissant) après chaque `add_card()`, pour un affichage stable sans logique de tri côté UI. `remove_card()` (par égalité de valeur, pas de référence), `contains()`, `cards()` (copie), `count()`, `is_empty()`.

## Moteur de règles — cartes (étape 3)

Types purs (`RefCounted`, sans nœud Godot), testables sans instancier de scène (voir `tests/unit/test_rule_engine.gd`). Variante Hearts retenue documentée en détail dans `docs/DECISIONS.md` (ADR-016).

### `HeartsRules` — `scripts/rules/hearts_rules.gd`

`class_name HeartsRules extends RefCounted`. Constantes et requêtes pures **sans état** (pas de notion de pli en cours ni de Cœurs défoncés — voir `RuleEngine` pour l'état) :

- Constantes : `PLAYER_COUNT` (4), `CARDS_PER_HAND` (13), `HEART_POINTS` (1), `QUEEN_OF_SPADES_POINTS` (13), `TOTAL_POINTS_PER_HAND` (26).
- `is_two_of_clubs(card)`, `is_penalty_card(card)` (Cœur ou Dame de Pique), `card_points(card)` (0, 1 ou 13).
- `has_only_hearts(cards)`, `has_only_penalty_cards(cards)` : détectent les cas « aucun autre choix » (mains 100% Cœurs, ou 100% cartes à points).

### `RuleEngine` — `scripts/rules/rule_engine.gd`

`class_name RuleEngine extends RefCounted`. Une instance porte l'état d'**une manche en cours** ; les méthodes de résolution de pli et de score sont **statiques et pures** (aucune dépendance à l'état d'instance, réutilisables telles quelles par une future IA).

**État d'instance** (géré par l'orchestrateur, `MatchManager`, étape 4) :

- `hearts_broken: bool` — `true` dès qu'une carte à points a été jouée dans la manche.
- `trick_number: int` (1-based), `is_first_trick: bool` (`trick_number == 1`).
- `reset_for_new_hand()` : remet l'état à zéro pour une nouvelle manche.
- `advance_to_next_trick()` : à appeler après chaque pli résolu (incrémente `trick_number`).
- `record_card_played(card)` : à appeler après chaque carte posée sur la table (défonce les Cœurs si `card` est une carte à points, voir ADR-016).

**Validation d'un coup** (méthodes d'instance, dépendent de `hearts_broken`/`is_first_trick`) :

- `get_legal_plays(hand, lead_suit, is_leading) -> Array[CardModel]` : liste des cartes jouables. `lead_suit` (`Suit.*`, `int`) est ignoré si `is_leading` est `true`. Ne retourne jamais un tableau vide tant que `hand` contient au moins une carte : les cas « aucun autre choix » (main 100% Cœurs, ou 100% cartes à points au premier pli) retombent sur la main entière via un mécanisme de repli unique (voir ADR-016).
- `validate_play(card, hand, lead_suit, is_leading) -> ValidationResult` : `VALID` si le coup est légal, sinon le code de la première règle enfreinte (`CARD_NOT_IN_HAND`, `MUST_PLAY_TWO_OF_CLUBS`, `MUST_FOLLOW_SUIT`, `CANNOT_LEAD_HEARTS_UNBROKEN`, `CANNOT_PLAY_PENALTY_ON_FIRST_TRICK`).

**Résolution de pli et scoring** (méthodes statiques, pures) :

- `can_lead_suit(suit, hand, hearts_broken) -> bool` : variante statique de la règle « Cœurs non défoncés », utilisable indépendamment d'une instance (IA, tests isolés).
- `get_trick_winner(trick: Array[Dictionary]) -> int` : `trick` est un tableau ordonné de `{"player_index": int, "card": CardModel}` (le premier élément définit la couleur demandée) ; retourne l'index du joueur vainqueur (carte la plus forte de la couleur demandée, pas d'atout).
- `score_trick(cards: Array[CardModel]) -> int` : somme des points (Cœurs + Dame de Pique) d'un pli remporté.
- `score_hand(tricks_taken_per_player: Array) -> Dictionary` : `tricks_taken_per_player` indexé par `player_index`, chaque entrée regroupant toutes les cartes capturées par ce joueur pendant la manche ; retourne `{player_index -> points}`, avec gestion du « shoot the moon » (voir ADR-016).

Règles couvertes : 2 de Trèfle obligatoire au premier pli, suivi de couleur obligatoire, interdiction d'entamer un pli avec un Cœur avant qu'il soit défoncé (sauf main 100% Cœurs), interdiction de jouer une carte à points au premier pli (sauf main 100% cartes à points), détermination du vainqueur d'un pli, calcul du score de manche avec détection du « shoot the moon ». Pas de gestion de la passe de cartes (3 cartes) à cette étape — prévue avec l'orchestration de manche (étape 4).

## Rendu et plateforme

- Renderer : **GL Compatibility** (compatibilité large), driver Windows en D3D12.
- Résolution de référence : **1280x720**, stretch mode `canvas_items` / aspect `expand`.

## Architecture UI — table de jeu

### Stratégie responsive

- Cible **mobile first**, orientation **paysage prioritaire** (portrait envisagé plus tard, voir ADR-006).
- Résolution/canevas de référence : **1280x720**.
- `window/stretch/mode="canvas_items"` + `window/stretch/aspect="expand"` (déjà configuré dans `project.godot`) : l'UI est construite en unités du canevas de référence, Godot met à l'échelle et laisse déborder/adapter selon le ratio réel de l'écran.
- Toute scène UI utilise des `Control` avec **ancrages relatifs** (pas de positions/tailles absolues codées en dur), pour rester lisible sur différents ratios d'écran (16:9, 18:9, tablette...).
- Pas d'`InputMap` custom pour l'instant (aucune interaction clavier/manette requise en étape UI) ; des actions (`play_card`, `open_menu`...) seront ajoutées à `project.godot` lorsque les interactions joueur seront implémentées (étape 6/7 de `docs/ROADMAP.md`).

### Arborescence de scène — `scenes/table/table.tscn`

```
Table (Control, full rect)
├── Background (ColorRect, feutre vert)
├── TopMenuBar (instance scenes/components/top_menu_bar.tscn)
│   └── Margin/Bar (HBoxContainer)
│       ├── LeftButtons (HBoxContainer) : BtnHamburger, BtnHelp (AIDE), BtnScores (SCORES)
│       ├── CenterInfo (VBoxContainer, expand) : TurnLabel, ScoreLabel
│       └── RightButtons (HBoxContainer) : BtnNew (NOUVEAU), BtnMenu (MENU), BtnSettings (réglages)
├── PlayerSeats (Control, full rect, non interactif)
│   ├── SeatTop (instance scenes/components/player_seat.tscn)
│   ├── SeatLeft (instance scenes/components/player_seat.tscn)
│   ├── SeatRight (instance scenes/components/player_seat.tscn)
│   └── SeatBottom (instance scenes/components/player_seat.tscn) — "Vous"
├── TrickArea (Control, centré, disposition en croix)
│   ├── TrickCardTop / TrickCardBottom / TrickCardLeft / TrickCardRight (Panel, emplacement fantôme)
└── HumanHandArea (Control, ancré en bas)
    └── PlayerBottomHand (Control, cartes générées en éventail par table.gd)
```

### Composants réutilisables — `scenes/components/`

| Scène | Script | Rôle |
|---|---|---|
| `card_view.tscn` | `card_view.gd` | Affiche une carte (dos `card_back_red` par défaut, ou texture recto via `front_texture` + `face_up`). Purement visuel. |
| `player_seat.tscn` | `player_seat.gd` | Affiche un siège joueur : avatar (placeholder `ColorRect`), nom, score `(n)`, pénalité cœur, rangée de dos de carte représentant la main restante. |
| `top_menu_bar.tscn` | `top_menu_bar.gd` | Barre de menu supérieure (style bois) : boutons d'action (signaux `hamburger_pressed`, `help_pressed`, `scores_pressed`, `new_game_pressed`, `menu_pressed`, `settings_pressed`) + zone d'info centrale (`TurnLabel`, `ScoreLabel`) pilotable via `set_turn_text()` / `set_score_text()`. |

`table.gd` reste **volontairement minimal** : il instancie la main du joueur en éventail (données de démonstration) et ne contient aucune règle de jeu. Le câblage réel (scores, tour courant, cartes jouées) se fera via les signaux `GameEvents` lorsque `MatchManager` existera (étape 4).

### Conventions de nommage des nœuds (stabilité pour les tests)

Les noms de nœuds suivants sont **stables** et ne doivent pas être renommés sans mettre à jour les tests/outils qui s'y réfèrent (GdUnit4, éventuel Playwright sur export web) : `TurnLabel`, `ScoreLabel`, `PlayerBottomHand`, `TrickArea`, `BtnMenu`, `BtnNew`, `BtnHelp`, `BtnScores`, `BtnSettings`, `BtnHamburger`, `SeatTop`, `SeatLeft`, `SeatRight`, `SeatBottom`, `ConfirmDialog`, `BtnConfirmYes`, `BtnConfirmNo`, `MainMenu`, `BtnNewGame`.

### Limites connues du scaffold actuel (polish futur)

- Les rangées de dos de carte des sièges gauche/droite sont horizontales comme celle du haut (pas encore orientées verticalement) — polish visuel à faire à l'étape 8.
- La disposition en éventail de la main du joueur est approximative (constantes ajustables en tête de `table.gd`) et n'anime rien pour l'instant.
- Aucune interaction (clic sur carte, drag & drop) n'est câblée : c'est un rendu statique de démonstration.

## Direction artistique UI — pixel art

Voir `docs/DECISIONS.md` (ADR-008) pour le contexte complet de cette décision. Cette section détaille les implications techniques.

### Filtrage de texture

- Réglage projet : `rendering/textures/canvas_textures/default_texture_filter=0` (Nearest) dans `project.godot`, section `[rendering]`.
- Ce réglage généralise le comportement déjà en place sur `scenes/components/card_view.tscn` (`TextureRect.texture_filter = 1`, Nearest) : le rendu des cartes actuelles ne change donc pas, seuls les nouveaux éléments UI (boutons, panneaux, icônes pixel art) héritent de Nearest par défaut sans surcharge manuelle par nœud.
- Un futur composant utilisant volontairement un filtre lissé (ex. un fond photo/illustration non pixel art) devra surcharger explicitement `texture_filter = 2` (Linear) sur son propre nœud `CanvasItem`.

### Stretch / résolution (inchangé, note pixel art)

- `window/stretch/mode="canvas_items"` + `window/stretch/aspect="expand"` restent inchangés (voir ADR-006) : priorité mobile first, adaptation fluide à tous les ratios d'écran.
- Alternative écartée pour l'instant : `window/stretch/scale_mode="integer"` (mise à l'échelle entière stricte, classique en pixel art pour éviter tout artefact de sous-pixel). Écartée car elle introduirait des bandes noires (letterboxing) sur les ratios d'écran mobiles non multiples entiers de la résolution de référence, ce qui contredit la priorité mobile first (ADR-006). À reconsidérer uniquement si l'UI devient un ensemble de sprites pixel art à résolution fixe (ex. HUD entièrement en spritesheet basse résolution) plutôt que des `Control`/`StyleBox` vectoriels comme actuellement.

### Thème — `resources/themes/pixel_theme.tres`

- `Theme` Godot servant de point d'ancrage unique aux styles pixel art : `default_font` (police pixel, voir ci-dessous) déjà câblé ; `StyleBoxFlat`/`StyleBoxTexture` pour boutons et panneaux à bords nets (pas de `corner_radius` arrondi, préférer des bordures pixel de 2-4px ou des `NinePatchRect` pixel art) restent à faire.
- Assigné à la racine des scènes UI (`table.tscn`, nœud `Table`) pour propager le style automatiquement à tous les descendants (dont `TopMenuBar` instancié comme enfant).
- Le thème n'est plus vide (police par défaut appliquée) mais reste un point d'extension : aucun `StyleBox` de bouton/panneau n'est encore défini au niveau du thème (voir ADR-009 pour l'état détaillé et les TODO).

### Police pixel

- Emplacement : `assets/fonts/PixelifySans-VariableFont_wght.ttf` (police variable vectorielle au style pixel, libre de droits).
- Importée par Godot en `FontFile` (réglages d'import par défaut conservés : `antialiasing=1`, `hinting=3`, `oversampling=0.0` — voir justification en ADR-009) et référencée comme `default_font` de `pixel_theme.tres`. `default_font_size` n'est pas surchargé (garde la taille par défaut du moteur) pour ne pas perturber les mises en page existantes.
- Tous les `Label`/`Button` des scènes héritant de `pixel_theme.tres` (ex. `table.tscn` et ses enfants `TopMenuBar`, `PlayerSeat`) affichent donc déjà cette police sans modification supplémentaire.

### Feuille de sprites de boutons UI

- Emplacement : `assets/sprites/8bit-color-retro-pixel-art-buttons-interface-menu-icons-old-video-game-symbols.png` (2000×770 px).
- Grille irrégulière à 5 colonnes documentée en détail dans `docs/DECISIONS.md` (ADR-009) : boutons "pilule"/badges avec texte ou icônes incrustés dans l'image (colonnes 1, 3, 4, 5 — non réutilisables tels quels pour les libellés français du jeu), et une colonne de 4 cercles unis sans texte incrusté (colonne 2, x 603–747) réutilisable pour des boutons icône génériques.
- Intégration actuelle (minimale, normal state uniquement) : `scenes/components/top_menu_bar.tscn` découpe 2 régions de la colonne 2 via `AtlasTexture` et les applique en `StyleBoxTexture` (`theme_override_styles/normal`) directement sur `BtnHamburger` (cercle violet) et `BtnSettings` (cercle bleu). Les boutons texte (`AIDE`, `SCORES`, `NOUVEAU`, `MENU`) ne sont pas concernés par cette feuille (pas d'asset "pilule" texte-libre disponible) et restent sur le style par défaut du moteur.
- TODO de polish (voir ADR-009) : états hover/pressed dédiés pour les boutons icône, habillage des boutons texte avec un futur asset ou `StyleBoxFlat` cohérent avec la palette ci-dessous.

### Chrome UI en style pixel art

Le style pixel art s'applique aux éléments d'interface (pas encore aux sprites de carte, voir ADR-008) :

- **Barre de menu** (`top_menu_bar.tscn`) : boutons icône (hamburger, réglages) déjà habillés avec la feuille de sprites (voir ci-dessus) ; fond de barre toujours en `ColorRect` uni (texture bois pixel art à venir), boutons texte (AIDE/SCORES/NOUVEAU/MENU) toujours sans `StyleBox` dédié.
- **Panneaux/emplacements** (ex. `StyleBoxFlat_slot` de `TrickArea`) : remplacer les coins arrondis (`corner_radius_*`) par des coins droits ou des bordures pixel à motif, cohérent avec l'esthétique générale.
- **Menu de réglages** (à venir, `scenes/menus/`) : habillage orné pixel art façon la référence utilisateur (cadre décoratif, boutons ornés), construit sur `pixel_theme.tres`.

### Surbrillance de sélection de carte

- Référence utilisateur : coins en crochet (« corner brackets ») **bleu** ou **jaune** superposés aux 4 coins de la carte sélectionnée, plutôt qu'un halo lumineux ou un changement de teinte de fond.
- Implémentation prévue (étape 6/8, interactions joueur) : un export `selected: bool` sur `CardView` (`scripts/components/card_view.gd`) qui affiche/masque 4 `TextureRect` (ou un unique `NinePatchRect`) de crochets de coin pixel art, positionnés en surcouche de la carte. Couleur bleue = carte jouable sélectionnée, jaune = mise en évidence contextuelle (ex. suggestion IA/tutoriel), à confirmer lors de l'implémentation des interactions.

### Palette de couleurs proposée

Palette vive et à fort contraste (à raffiner à l'intégration des assets réels, valeurs de départ) :

| Usage | Couleur | Hex approx. |
|---|---|---|
| Feutre de table (fond) | Vert vif | `#2D5A27` à `#3C8C3F` (actuel `Background` : `#0B5E2C`, à éclaircir légèrement pour plus de vivacité) |
| Boutons d'action principaux | Or / jaune chaud | `#D4AF37` à `#FFC93C` |
| Bordures / accents pixel | Bleu vif (sélection) | `#3B82F6` |
| Bordures / accents pixel | Jaune vif (highlight) | `#FFD93D` |
| Texte UI sur fond sombre (bois, feutre) | Blanc cassé / crème | `#F5F0E6` |
| Texte d'alerte (pénalité cœur, erreurs) | Rouge vif | `#E63946` |

Ces couleurs sont des points de départ pour le futur `pixel_theme.tres` et les assets pixel art à venir ; elles ne remplacent pas immédiatement les couleurs actuelles du scaffold (changement visuel différé pour rester dans le scope « documentation + réglages » de cette itération).

### Pipeline art — cartes vs chrome UI

Deux pistes pour la suite, à trancher avant l'étape 8 (polish visuel) :

1. **Chrome UI pixel art + pack de cartes actuel conservé** : le plus rapide, cohérence visuelle partielle (cartes détaillées/lisses dans un cadre pixel art coloré). Risque : contraste de styles entre cartes et UI si le pixel art du chrome est très marqué.
2. **Remplacement complet du pack de cartes par un set pixel art** : cohérence visuelle totale avec les références utilisateur, mais chantier important (52 cartes + dos + éventuels alt arts, mise à jour d'ADR-005 pour le nouveau dos canonique) et risque sur la **clarté** (rangs/couleurs doivent rester lisibles à petite taille en pixel art, ce qui demande un pack de qualité, pas un simple retexturage).

Recommandation : commencer par la piste 1 (chrome UI pixel art, cartes actuelles conservées) pour un résultat visible rapidement sans bloquer le développement des règles/orchestration, puis réévaluer la piste 2 une fois le gameplay complet (après étape 5), en fonction du temps disponible et de la disponibilité d'un pack de cartes pixel art de qualité suffisante.

## Audio

Voir `docs/DECISIONS.md` (ADR-010) pour le mapping événement → fichier et son raisonnement. Cette section détaille l'implémentation technique.

### Fichiers sources

`assets/audio/` (format `.wav`, déjà importés par Godot en `AudioStreamWAV`) :

| Fichier | Événement(s) mappé(s) |
|---|---|
| `Card Dealing one card.wav` | Distribution d'une carte individuelle |
| `Card Dealing multiple.wav` | Distribution en bloc **+** ramassage de pli |
| `Card Playing launching one card.wav` | Carte posée sur la table |
| `Card Playing launching one card alt.wav` | Survol de carte (volume réduit) |

### `scripts/core/audio_paths.gd` — `AudioPaths`

Point de vérité unique des chemins `res://assets/audio/...`, sous forme de constantes (`DEAL_SINGLE_CARD`, `DEAL_BURST`, `CARD_PLAYED`, `CARD_PLAYED_ALT`, plus les alias `TRICK_COLLECT`/`CARD_HOVER`). Aucun autre script ne doit coder un chemin audio en dur.

### `scripts/services/audio_service.gd` — `AudioService` (autoload)

- Précharge tous les flux (`AudioPaths.ALL_PATHS`) une fois dans `_ready()`, puis les joue via un pool de 6 `AudioStreamPlayer` (permet à plusieurs SFX courts de se chevaucher, ex. cartes distribuées coup sur coup ; round-robin si le pool est saturé).
- Volume : `_volume_scale_to_db()` combine `ConfigService.get_volume()` (volume utilisateur, 0-1) et un facteur d'appel (ex. `HOVER_VOLUME_SCALE = 0.6` pour le survol), converti en décibels via `linear_to_db`.
- Cooldown de survol : `HOVER_COOLDOWN_SEC = 0.12` (120 ms), basé sur `Time.get_ticks_msec()`, pour éviter le spam sonore quand le pointeur traverse rapidement plusieurs cartes.
- API publique typée : `play_deal_card()`, `play_deal_burst()`, `play_card_hover()`, `play_card_played()`, `play_trick_collect()` (`play_sfx()` générique conservé pour compatibilité mais non mappé).
- **Découplage via `GameEvents`** : `AudioService._ready()` se connecte directement à `GameEvents.card_played` et `GameEvents.trick_resolved`. Conséquence pratique : un futur `MatchManager` n'a **rien** à faire de spécial pour déclencher les sons de base — émettre ces signaux (déjà prévu, voir flux de signaux plus haut) suffit à jouer `play_card_played()`/`play_trick_collect()` automatiquement.
- **Musique d'ambiance** (voir `docs/DECISIONS.md` ADR-013) : `play_random()`, `play_next()`, `stop_music()`, `set_music_enabled()` gèrent une playlist mélangée (`AudioPaths.MUSIC_TRACKS`) jouée sur un `AudioStreamPlayer` dédié, démarrée automatiquement au lancement du jeu, à volume plus bas que les SFX (`ConfigService.get_music_volume()`, défaut `0.35`).

### Câblage actuel (démo UI, sans `MatchManager`)

- **Survol** (câblé, actif) : `card_view.gd` appelle `AudioService.play_card_hover()` dans le setter de `hovered` (uniquement au passage à `true`).
- **Distribution** (câblé, démo) : `table.gd::_populate_demo_hand()` joue une séquence de `AudioService.play_deal_card()` étalée dans le temps (`DEMO_DEAL_SFX_STAGGER_SEC = 0.09s` par carte, via des `Timer`) à l'ouverture de la table. Les cartes de démo apparaissent instantanément (pas encore d'animation visuelle de distribution) ; seul le son préfigure la future séquence. Méthode publique `play_deal_demo()` exposée pour rejouer la séquence indépendamment.
- **Carte jouée / ramassage de pli** (préparé, pas déclenché par une interaction démo) : la sélection d'une carte dans la main de démo (`_toggle_demo_card_selection`) reste **purement visuelle**, volontairement non reliée à `play_card_played()` (sélectionner une carte de démo n'est pas « la jouer »). Ces deux sons sont déjà opérationnels via l'écoute `GameEvents` ci-dessus ; en attendant `MatchManager`, `table.gd::_unhandled_key_input()` expose deux raccourcis debug (actifs seulement si `DebugService.is_debug_enabled()`) pour les tester manuellement en F6 : **P** simule `GameEvents.card_played`, **T** simule `GameEvents.trick_resolved`. À retirer une fois `MatchManager` branché sur la table.

### Export Web/mobile

Les fichiers fournis sont en `.wav` (non compressé, correct pour un export desktop). Pour un export Web/mobile, préférer des versions `.ogg` (Vorbis, taille nettement réduite) des mêmes sons si elles deviennent disponibles ; il suffirait de mettre à jour les chemins dans `AudioPaths` (point de modification unique), aucun autre script n'étant à toucher.
