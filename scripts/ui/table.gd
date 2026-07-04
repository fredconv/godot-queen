extends Control
## Table
## Échafaudage visuel de la table de jeu (étape UI uniquement). Ne contient
## aucune règle de jeu ni orchestration de manche : ces responsabilités
## reviendront à `MatchManager` (scripts/match/) et aux règles pures
## (scripts/rules/) lors des prochaines étapes de `docs/ROADMAP.md`.
## Pour l'instant, ce script se contente de disposer une main de démonstration
## en éventail ; sièges et barre de menu affichent des données statiques
## définies directement dans les scènes de composants.
##
## Direction artistique (voir docs/DECISIONS.md ADR-008 et
## docs/TECHNICAL_DESIGN.md) : le chrome UI de cette table (barre de menu,
## panneaux, futures surbrillances de sélection) évolue vers un style
## pixel art coloré et lisible, via `resources/themes/pixel_theme.tres`
## (référencé sur la racine `Table` de `table.tscn`). Les sprites de carte
## (pack `kerenel_Cards_seperated`) restent inchangés pour le MVP : ce
## pack n'est pas dessiné en pixel art, un remplacement éventuel est une
## itération séparée (voir « Pipeline art » dans TECHNICAL_DESIGN.md).

const CardViewScene: PackedScene = preload("res://scenes/components/card_view.tscn")
const MAIN_MENU_SCENE_PATH: String = "res://scenes/menus/main_menu.tscn"

const DEMO_HAND_TEXTURE_PATHS: Array[String] = [
	"res://assets/cards/kerenel_Cards_seperated/spades_ace.png",
	"res://assets/cards/kerenel_Cards_seperated/hearts_king.png",
	"res://assets/cards/kerenel_Cards_seperated/diamonds_queen.png",
	"res://assets/cards/kerenel_Cards_seperated/clubs_jack.png",
	"res://assets/cards/kerenel_Cards_seperated/hearts_10.png",
	"res://assets/cards/kerenel_Cards_seperated/spades_9.png",
	"res://assets/cards/kerenel_Cards_seperated/diamonds_8.png",
]

const HAND_FAN_SPREAD_DEG: float = 34.0
const HAND_FAN_RADIUS: float = 370.0
const HAND_CARD_SCALE: float = 1.9
const CARD_BASE_SIZE: Vector2 = Vector2(56.0, 80.0)

## Distance (px) au-dessus du bas de l'écran où se situe le point de pivot bas
## de la carte centrale de l'éventail. `_player_bottom_hand` est ancré au bas
## de l'écran (voir `table.tscn::HumanHandArea`) : comme sa hauteur locale
## s'annule exactement avec la position de son coin haut-gauche dans le calcul
## du centre de l'éventail, seule cette constante contrôle la position
## verticale réelle de la main à l'écran (modifier la taille de
## `HumanHandArea` dans `table.tscn` n'a aucun effet visuel). Une valeur
## négative pousse la main sous le bas de l'écran (rognage volontaire du bas
## des cartes), afin qu'elle ne chevauche plus `TrickCardBottom`.
const HAND_FAN_BOTTOM_MARGIN: float = -30.0

## Délai (secondes) entre deux sons de distribution lors de la séquence audio
## de démo jouée à l'ouverture de la table (voir `_play_deal_demo_sfx`). Les
## cartes de démo apparaissent instantanément (pas encore d'animation de
## distribution) ; seul le son est étalé dans le temps pour préfigurer la
## future séquence visuelle+audio de `MatchManager`.
const DEMO_DEAL_SFX_STAGGER_SEC: float = 0.09

@onready var _player_bottom_hand: Control = $HumanHandArea/PlayerBottomHand
@onready var _seat_bottom: Control = $PlayerSeats/SeatBottom
@onready var _top_menu_bar: Control = $UILayer/TopMenuBar
@onready var _confirm_dialog: Control = $UILayer/ConfirmDialog

## Carte actuellement sélectionnée dans la main de démonstration (une seule à
## la fois). Purement visuel : aucune règle de jeu n'est appliquée ici.
var _selected_demo_card: Control = null

func _ready() -> void:
	call_deferred("_populate_demo_hand")
	_seat_bottom.set_active_turn(true)
	_top_menu_bar.menu_pressed.connect(_on_top_menu_bar_menu_pressed)
	_confirm_dialog.confirmed.connect(_on_leave_match_confirmed)
	_setup_music_controls()

## Câble les boutons musique de `TopMenuBar` sur `AudioService` (voir
## docs/DECISIONS.md ADR-013). La musique elle-même démarre indépendamment,
## dès le lancement du jeu, depuis `AudioService._ready()` : cette table n'a
## qu'à synchroniser l'affichage du bouton et relayer les actions.
func _setup_music_controls() -> void:
	_top_menu_bar.set_music_enabled_display(ConfigService.get_music_enabled())
	_top_menu_bar.music_toggle_pressed.connect(_on_music_toggle_pressed)
	_top_menu_bar.music_next_pressed.connect(_on_music_next_pressed)

func _on_music_toggle_pressed() -> void:
	var enabled: bool = not ConfigService.get_music_enabled()
	AudioService.set_music_enabled(enabled)
	_top_menu_bar.set_music_enabled_display(enabled)

func _on_music_next_pressed() -> void:
	AudioService.play_next()

## Rejoue la séquence audio de distribution sans re-peupler la main. Exposée
## publiquement pour qu'un futur `MatchManager` (ou un test manuel) puisse la
## déclencher indépendamment du peuplement de la main de démo.
func play_deal_demo() -> void:
	_play_deal_demo_sfx(DEMO_HAND_TEXTURE_PATHS.size())

## Bouton "MENU" de la barre supérieure : retour au menu principal. Si une
## partie est en cours (`GameSession.match_in_progress`), demande confirmation
## avant de quitter ; sinon (partie non démarrée ou déjà terminée), retour
## direct sans confirmation.
func _on_top_menu_bar_menu_pressed() -> void:
	if GameSession.match_in_progress:
		_confirm_dialog.open("Voulez-vous quitter la partie en cours ?")
	else:
		_return_to_main_menu()

func _on_leave_match_confirmed() -> void:
	GameSession.end_match()
	_return_to_main_menu()

func _return_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _populate_demo_hand() -> void:
	var count: int = DEMO_HAND_TEXTURE_PATHS.size()
	var step: float = HAND_FAN_SPREAD_DEG / maxf(count - 1, 1.0)
	var start_angle_deg: float = -HAND_FAN_SPREAD_DEG / 2.0
	var fan_center: Vector2 = Vector2(
		_player_bottom_hand.size.x / 2.0,
		_player_bottom_hand.size.y + HAND_FAN_RADIUS - HAND_FAN_BOTTOM_MARGIN
	)
	for i in count:
		var card: Control = CardViewScene.instantiate()
		card.face_up = true
		card.front_texture = load(DEMO_HAND_TEXTURE_PATHS[i])
		card.scale = Vector2(HAND_CARD_SCALE, HAND_CARD_SCALE)
		card.pivot_offset = Vector2(CARD_BASE_SIZE.x / 2.0, CARD_BASE_SIZE.y)
		_player_bottom_hand.add_child(card)

		var angle_rad: float = deg_to_rad(start_angle_deg + step * i)
		var point_on_fan: Vector2 = fan_center + Vector2(sin(angle_rad), -cos(angle_rad)) * HAND_FAN_RADIUS
		card.position = point_on_fan - card.pivot_offset
		card.rotation = angle_rad

		card.mouse_entered.connect(_on_demo_card_mouse_entered.bind(card))
		card.mouse_exited.connect(_on_demo_card_mouse_exited.bind(card))
		card.gui_input.connect(_on_demo_card_gui_input.bind(card))

	_play_deal_demo_sfx(count)

## Joue un son de distribution par carte, étalé dans le temps (voir
## `DEMO_DEAL_SFX_STAGGER_SEC`), pour donner un aperçu audio de la distribution
## en attendant l'animation réelle de `MatchManager`.
func _play_deal_demo_sfx(count: int) -> void:
	for i in count:
		get_tree().create_timer(i * DEMO_DEAL_SFX_STAGGER_SEC).timeout.connect(AudioService.play_deal_card)

func _on_demo_card_mouse_entered(card: Control) -> void:
	card.set_hovered(true)

func _on_demo_card_mouse_exited(card: Control) -> void:
	card.set_hovered(false)

func _on_demo_card_gui_input(event: InputEvent, card: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_demo_card_selection(card)

## Sélectionne `card` en désélectionnant la précédente (une seule carte
## sélectionnée à la fois) ; cliquer sur la carte déjà sélectionnée la
## désélectionne.
func _toggle_demo_card_selection(card: Control) -> void:
	if _selected_demo_card == card:
		card.set_selected(false)
		_selected_demo_card = null
		return
	if _selected_demo_card:
		_selected_demo_card.set_selected(false)
	card.set_selected(true)
	_selected_demo_card = card

## --- Hooks de test audio (temporaires, en attendant `MatchManager`) ---
## `AudioService` écoute déjà `GameEvents.card_played`/`trick_resolved` (voir
## `scripts/services/audio_service.gd`) : quand `MatchManager` émettra ces
## signaux pour de vrai, les sons "carte jouée" et "ramassage de pli" se
## déclencheront automatiquement, sans rien changer ici. En attendant, ces
## raccourcis debug permettent de vérifier les deux sons manuellement en F6 :
## - P : simule `card_played` (son de carte posée)
## - T : simule `trick_resolved` (son de ramassage de pli)
## À retirer une fois `MatchManager` branché sur la table.
func _unhandled_key_input(event: InputEvent) -> void:
	if not DebugService.is_debug_enabled():
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_P:
			GameEvents.card_played.emit(0, null)
		KEY_T:
			GameEvents.trick_resolved.emit(0, 0)
