extends Control
## Table
## Contrôleur de la table de jeu : possède un `MatchManager` (étape 4) et lui
## assigne un `AiPlayer` (étape 5, stratégie par défaut) aux sièges 1 à 3 (le
## siège 0 reste toujours humain, voir docs/DECISIONS.md ADR-019). Traduit
## l'état de la manche en affichage (main du joueur, dos de carte des
## adversaires, pli en cours, scores) et anime le jeu d'une carte ainsi que le
## ramassage d'un pli (voir docs/DECISIONS.md ADR-020/ADR-021 pour le détail
## des choix de câblage et d'animation). Ne contient aucune règle de jeu :
## uniquement de la lecture d'état (`MatchManager`) et de la présentation.
##
## Direction artistique (voir docs/DECISIONS.md ADR-008 et
## docs/TECHNICAL_DESIGN.md) : le chrome UI de cette table (barre de menu,
## panneaux, surbrillances de sélection) suit un style pixel art coloré et
## lisible, via `resources/themes/pixel_theme.tres` (référencé sur la racine
## `Table` de `table.tscn`). Les sprites de carte (pack
## `kerenel_Cards_seperated`) restent inchangés pour le MVP.

const CardViewScene: PackedScene = preload("res://scenes/components/card_view.tscn")
const MAIN_MENU_SCENE_PATH: String = "res://scenes/menus/main_menu.tscn"
const AudioServiceScript = preload("res://scripts/services/audio_service.gd")
const GameSessionScript = preload("res://scripts/services/game_session.gd")
const DebugServiceScript = preload("res://scripts/services/debug_service.gd")

## Index du siège humain (voir docs/DECISIONS.md ADR-019 : siège 0 = humain,
## sièges 1-3 = IA).
const HUMAN_INDEX: int = 0

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

## Décalage initial des cartes de la main humaine (distribution depuis le bas).
const HUMAN_HAND_DEAL_OFFSET: Vector2 = Vector2(0.0, 480.0)

## Pause avant chaque coup joué par une IA (voir docs/DECISIONS.md ADR-020) :
## rend l'enchaînement des tours adverses suivable à l'œil plutôt
## qu'instantané. `MatchManager.advance_ai_turns()` (sans pause) reste
## utilisée telle quelle par les tests d'intégration.
const AI_TURN_DELAY_SEC: float = 0.4

## Échelle appliquée à une carte une fois posée dans le pli (légèrement plus
## grande que dans la main, pour bien remplir l'emplacement de `TrickArea`,
## voir `table.tscn`).
const TRICK_CARD_SCALE: float = 1.5

@onready var _player_bottom_hand: Control = $HumanHandArea/PlayerBottomHand
@onready var _animation_layer: Control = $AnimationLayer
@onready var _top_menu_bar: Control = $UILayer/TopMenuBar
@onready var _confirm_dialog: Control = $UILayer/ConfirmDialog
@onready var _match_end_dialog: Control = $UILayer/MatchEndDialog
@onready var _hand_end_dialog: Control = $UILayer/HandEndDialog
@onready var _match_scoreboard: Control = $UILayer/MatchScoreboard
@onready var _trick_area: Control = $TrickArea

var _lead_suit_indicator: Label
var _victory_petals: VictoryPetals
var _bullet_time_camera: Camera2D
var _bullet_time_dim_layer: CanvasLayer
var _bullet_time_dim: ColorRect
var _queen_burst_layer: CanvasLayer
var _queen_avatar_burst: QueenOfSpadesAvatarBurst

## Sièges et emplacements de pli indexés par `player_index` (0-3), convention
## fixée en docs/DECISIONS.md ADR-020 : 0 = bas (humain), 1 = gauche, 2 = haut,
## 3 = droite (ordre de jeu humain → gauche → haut → droite).
@onready var _seats: Array[PlayerSeat] = [
	$PlayerSeats/SeatBottom,
	$PlayerSeats/SeatLeft,
	$PlayerSeats/SeatTop,
	$PlayerSeats/SeatRight,
]
@onready var _trick_slots: Array[Control] = [
	$TrickArea/TrickCardBottom,
	$TrickArea/TrickCardLeft,
	$TrickArea/TrickCardTop,
	$TrickArea/TrickCardRight,
]

## Orchestrateur de manche/partie (étape 4), possédé par cette scène (voir
## docs/DECISIONS.md ADR-002 : `MatchManager` n'est jamais un autoload).
## Recréé à chaque nouvelle partie (voir `_start_new_match()`).
var _match_manager: MatchManager

## Vues des cartes de la main humaine, dans le même ordre que
## `_hand_cards` (indices alignés), pour ajuster leur jouabilité/interactivité
## selon la légalité du coup (voir `_refresh_human_hand_legality()`).
var _hand_card_views: Array[Control] = []
var _hand_cards: Array[CardModel] = []

## Cartes actuellement posées dans le pli en cours, indexées par
## `player_index` : seule source de vérité côté UI pour l'affichage du pli
## (jamais reconstruite à partir de `TrickManager`, voir docs/DECISIONS.md
## ADR-021 pour la justification de ce choix par rapport à ADR-020).
var _trick_card_views: Dictionary = {}

## Empêche toute nouvelle action pendant qu'une séquence d'animation est en
## cours (pose de carte, résolution/ramassage d'un pli, tours IA) : évite un
## double-clic humain ou un chevauchement entre deux boucles de tours IA.
var _turn_locked: bool = false

## Vrai pendant la destruction de la scène : annule les coroutines `await`
## encore en cours pour éviter d'accéder à des nœuds libérés.
var _scene_exiting: bool = false

func _ready() -> void:
	_setup_lead_suit_indicator()
	_setup_victory_petals()
	_setup_bullet_time_fx()
	_setup_queen_avatar_burst()
	_top_menu_bar.menu_pressed.connect(_on_top_menu_bar_menu_pressed)
	_confirm_dialog.confirmed.connect(_on_leave_match_confirmed)
	_match_end_dialog.replay_requested.connect(_on_match_end_replay_requested)
	_match_end_dialog.quit_requested.connect(_on_match_end_quit_requested)
	_setup_music_controls()
	call_deferred("_start_new_match")


func _exit_tree() -> void:
	_scene_exiting = true
	if _bullet_time_camera:
		_bullet_time_camera.enabled = false
	if _bullet_time_dim:
		_bullet_time_dim.visible = false


func _is_active() -> bool:
	return is_inside_tree() and not _scene_exiting


func _setup_lead_suit_indicator() -> void:
	var panel := PanelContainer.new()
	panel.name = "LeadSuitIndicator"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_top = 8.0
	panel.offset_left = -120.0
	panel.offset_right = 120.0
	panel.offset_bottom = 40.0
	_lead_suit_indicator = Label.new()
	_lead_suit_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lead_suit_indicator.add_theme_font_size_override("font_size", 18)
	panel.add_child(_lead_suit_indicator)
	_trick_area.add_child(panel)


func _setup_victory_petals() -> void:
	_victory_petals = VictoryPetals.new()
	_victory_petals.name = "VictoryPetals"
	_victory_petals.set_anchors_preset(Control.PRESET_FULL_RECT)
	_victory_petals.z_index = 5
	add_child(_victory_petals)


func _setup_bullet_time_fx() -> void:
	_bullet_time_camera = Camera2D.new()
	_bullet_time_camera.name = "BulletTimeCamera"
	_bullet_time_camera.enabled = false
	add_child(_bullet_time_camera)

	_bullet_time_dim_layer = CanvasLayer.new()
	_bullet_time_dim_layer.name = "BulletTimeDimLayer"
	_bullet_time_dim_layer.layer = 5
	_bullet_time_dim = ColorRect.new()
	_bullet_time_dim.name = "BulletTimeDim"
	_bullet_time_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bullet_time_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bullet_time_dim.color = Color(0.02, 0.03, 0.08, 1.0)
	_bullet_time_dim.modulate.a = 0.0
	_bullet_time_dim.visible = false
	_bullet_time_dim_layer.add_child(_bullet_time_dim)
	add_child(_bullet_time_dim_layer)


func _setup_queen_avatar_burst() -> void:
	_queen_burst_layer = CanvasLayer.new()
	_queen_burst_layer.name = "QueenBurstLayer"
	_queen_burst_layer.layer = 100
	_queen_avatar_burst = QueenOfSpadesAvatarBurst.new()
	_queen_avatar_burst.name = "QueenOfSpadesAvatarBurst"
	_queen_burst_layer.add_child(_queen_avatar_burst)
	add_child(_queen_burst_layer)


func _refresh_lead_suit_indicator() -> void:
	if _lead_suit_indicator == null or _match_manager == null:
		return
	var panel: Control = _lead_suit_indicator.get_parent()
	var trick_manager: TrickManager = _match_manager.trick_manager
	if trick_manager.played_count() == 0 or trick_manager.lead_suit < 0:
		panel.visible = false
		return
	panel.visible = true
	_lead_suit_indicator.text = Suit.to_lead_indicator_text(trick_manager.lead_suit)
	match trick_manager.lead_suit:
		Suit.HEARTS:
			_lead_suit_indicator.add_theme_color_override("font_color", Color(0.95, 0.35, 0.4))
		Suit.DIAMONDS:
			_lead_suit_indicator.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		Suit.CLUBS:
			_lead_suit_indicator.add_theme_color_override("font_color", Color(0.85, 0.95, 0.85))
		Suit.SPADES:
			_lead_suit_indicator.add_theme_color_override("font_color", Color(0.88, 0.9, 1.0))
		_:
			_lead_suit_indicator.add_theme_color_override("font_color", Color.WHITE)

## Câble les boutons musique de `TopMenuBar` sur `AudioService` (voir
## docs/DECISIONS.md ADR-013). La musique elle-même démarre indépendamment,
## dès le lancement du jeu, depuis `AudioService._ready()` : cette table n'a
## qu'à synchroniser l'affichage du bouton et relayer les actions.
func _setup_music_controls() -> void:
	_top_menu_bar.set_music_enabled_display(_audio().get_music_enabled())
	_top_menu_bar.music_toggle_pressed.connect(_on_music_toggle_pressed)
	_top_menu_bar.music_next_pressed.connect(_on_music_next_pressed)

func _on_music_toggle_pressed() -> void:
	var enabled: bool = not _audio().get_music_enabled()
	_audio().set_music_enabled(enabled)
	_top_menu_bar.set_music_enabled_display(enabled)

func _on_music_next_pressed() -> void:
	_audio().play_next()

## Bouton "MENU" de la barre supérieure : retour au menu principal. Si une
## partie est en cours (`GameSession.match_in_progress`), demande confirmation
## avant de quitter ; sinon (partie non démarrée ou déjà terminée), retour
## direct sans confirmation.
func _on_top_menu_bar_menu_pressed() -> void:
	if _session().match_in_progress:
		_confirm_dialog.open("Voulez-vous quitter la partie en cours ?")
	else:
		_return_to_main_menu()

func _on_leave_match_confirmed() -> void:
	_session().end_match()
	_return_to_main_menu()

func _return_to_main_menu() -> void:
	_scene_exiting = true
	get_tree().call_deferred("change_scene_to_file", MAIN_MENU_SCENE_PATH)

# --- Cycle de vie d'une partie -----------------------------------------------

## Démarre une toute nouvelle partie : (re)crée `MatchManager`, lui assigne un
## `AiPlayer` aux sièges 1-3, puis rafraîchit tout l'affichage. Appelée au
## chargement de la table et depuis le bouton "Rejouer" de `MatchEndDialog`.
func _start_new_match(seed_value: int = -1) -> void:
	_turn_locked = false
	_match_end_dialog.close()
	_hand_end_dialog.close()
	_clear_trick_cards()

	_match_manager = MatchManager.new()
	for player_index in range(1, HeartsRules.PLAYER_COUNT):
		_match_manager.set_ai_player(player_index, AiPlayer.new())
	_match_manager.start_new_match(seed_value)

	await _deal_visual_sequence()
	if not _is_active():
		return
	_refresh_scores()
	_refresh_turn_ui()
	_run_ai_turns()

func _on_match_end_replay_requested() -> void:
	_clear_trick_cards()
	_match_end_dialog.close()
	_start_new_match()


func _on_match_end_quit_requested() -> void:
	_clear_trick_cards()
	_match_end_dialog.close()
	_return_to_main_menu()


func _clear_trick_cards() -> void:
	for card_view in _trick_card_views.values():
		(card_view as Control).queue_free()
	_trick_card_views.clear()
	if _match_manager:
		_refresh_lead_suit_indicator()

# --- Main du joueur humain ---------------------------------------------------

func _rebuild_human_hand() -> void:
	for child in _player_bottom_hand.get_children():
		_player_bottom_hand.remove_child(child)
		child.queue_free()
	_hand_card_views.clear()
	_hand_cards = _match_manager.hands[HUMAN_INDEX].cards()

	var count: int = _hand_cards.size()
	var step: float = HAND_FAN_SPREAD_DEG / maxf(count - 1, 1.0)
	var start_angle_deg: float = -HAND_FAN_SPREAD_DEG / 2.0
	var fan_center: Vector2 = Vector2(
		_player_bottom_hand.size.x / 2.0,
		_player_bottom_hand.size.y + HAND_FAN_RADIUS - HAND_FAN_BOTTOM_MARGIN
	)
	for i in count:
		var card: CardModel = _hand_cards[i]
		var card_view: Control = CardViewScene.instantiate()
		card_view.face_up = true
		card_view.front_texture = CardTexturePaths.get_front_texture(card)
		card_view.scale = Vector2(HAND_CARD_SCALE, HAND_CARD_SCALE)
		card_view.pivot_offset = Vector2(CARD_BASE_SIZE.x / 2.0, CARD_BASE_SIZE.y)
		_player_bottom_hand.add_child(card_view)

		var angle_rad: float = deg_to_rad(start_angle_deg + step * i)
		var point_on_fan: Vector2 = fan_center + Vector2(sin(angle_rad), -cos(angle_rad)) * HAND_FAN_RADIUS
		card_view.position = point_on_fan - card_view.pivot_offset
		card_view.rotation = angle_rad

		card_view.mouse_entered.connect(_on_hand_card_mouse_entered.bind(card_view))
		card_view.mouse_exited.connect(_on_hand_card_mouse_exited.bind(card_view))
		card_view.gui_input.connect(_on_hand_card_gui_input.bind(card_view, card))
		_hand_card_views.append(card_view)

	_refresh_human_hand_legality()

## Anime la distribution : une carte par joueur à la fois, chaque siège reçoit
## ses cartes depuis le bord d'écran le plus proche (gauche/haut/droite/bas).
func _deal_visual_sequence() -> void:
	_turn_locked = true
	await get_tree().process_frame
	if not _is_active():
		_unlock_turn()
		return

	_rebuild_human_hand()
	_refresh_opponent_hand_counts()
	await get_tree().process_frame
	if not _is_active():
		_unlock_turn()
		return

	var human_final_positions: Array[Vector2] = []
	for card_view in _hand_card_views:
		human_final_positions.append(card_view.position)
		card_view.position = human_final_positions[-1] + HUMAN_HAND_DEAL_OFFSET
		card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var opponent_deals: Array[Dictionary] = []
	for player_index in range(1, HeartsRules.PLAYER_COUNT):
		var seat: PlayerSeat = _seats[player_index]
		if seat.get_hand_back_card_views().is_empty():
			seat.force_refresh_hand_back()
		var cards: Array[Control] = seat.get_hand_back_card_views()
		var offset: Vector2 = seat.get_deal_start_offset()
		var final_positions: Array[Vector2] = []
		for card_view in cards:
			final_positions.append(card_view.position)
			card_view.position = final_positions[-1] + offset
		opponent_deals.append({"cards": cards, "final_positions": final_positions})

	var card_count: int = human_final_positions.size()
	for round_index in card_count:
		if not _is_active():
			_unlock_turn()
			return

		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		var tween_count := 0

		if round_index < _hand_card_views.size():
			var human_card: Control = _hand_card_views[round_index]
			if is_instance_valid(human_card):
				tween.tween_property(
					human_card,
					"position",
					human_final_positions[round_index],
					TableAnimations.DEAL_CARD_DURATION_SEC
				)
				tween_count += 1

		for deal_entry in opponent_deals:
			var cards: Array[Control] = deal_entry["cards"]
			var finals: Array[Vector2] = deal_entry["final_positions"]
			if round_index >= cards.size():
				continue
			var opponent_card: Control = cards[round_index]
			if not is_instance_valid(opponent_card):
				continue
			tween.tween_property(
				opponent_card,
				"position",
				finals[round_index],
				TableAnimations.DEAL_CARD_DURATION_SEC
			)
			tween_count += 1

		if tween_count == 0:
			continue

		_audio().play_deal_card()
		await tween.finished
		if not _is_active():
			_unlock_turn()
			return
		if round_index < card_count - 1:
			await get_tree().create_timer(TableAnimations.DEAL_CARD_STAGGER_SEC).timeout
			if not _is_active():
				_unlock_turn()
				return

	for card_view in _hand_card_views:
		card_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_unlock_turn()

func _on_hand_card_mouse_entered(card_view: Control) -> void:
	if not is_inside_tree():
		return
	if card_view.playable:
		_audio().play_card_hover()
	card_view.set_hovered(true)

func _on_hand_card_mouse_exited(card_view: Control) -> void:
	card_view.set_hovered(false)

func _on_hand_card_gui_input(event: InputEvent, card_view: Control, card: CardModel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Différé : évite de libérer la carte pendant l'émission de gui_input
		# (« Attempted to free a locked object » si _rebuild_human_hand() est appelé ici).
		call_deferred("_on_human_card_selected", card_view, card)

## Un clic sur une carte légale de la main humaine la joue immédiatement (pas
## d'étape de sélection/confirmation intermédiaire, voir docs/DECISIONS.md
## ADR-020) : les cartes illégales affichent un voile gris (`CardView`) et
## ignorent les clics (voir `_refresh_human_hand_legality()`), cette vérification reste une sécurité
## supplémentaire.
func _on_human_card_selected(card_view: Control, card: CardModel) -> void:
	if not is_instance_valid(card_view):
		return
	if _turn_locked or _match_manager.current_player != HUMAN_INDEX:
		return
	if _match_manager.is_match_over():
		return
	if not _card_in_list(card, _current_human_legal_plays()):
		return

	var result: MatchManager.PlayResult = _match_manager.play_card(HUMAN_INDEX, card)
	if not result.success:
		return

	_turn_locked = true
	var start_center: Vector2 = card_view.get_global_transform_with_canvas() * (card_view.size / 2.0)
	_rebuild_human_hand()
	await _animate_card_play(HUMAN_INDEX, card, start_center)
	if not _is_active():
		return
	await _handle_post_play(result)
	if not _is_active():
		return
	_unlock_turn()

	if _match_manager.is_match_over():
		return

	if _match_manager.phase == MatchManager.Phase.PLAYING and _match_manager.is_ai_controlled(_match_manager.current_player):
		_run_ai_turns()

# --- Tours IA -----------------------------------------------------------------

## Enchaîne les tours IA tant que le joueur courant en est un, avec une pause
## avant chaque coup (voir `AI_TURN_DELAY_SEC`). Réimplémente une boucle
## équivalente à `MatchManager.advance_ai_turns()` plutôt que de l'appeler
## directement : celle-ci joue tous les tours d'un coup, sans laisser de place
## à l'animation (voir docs/DECISIONS.md ADR-020).
func _run_ai_turns() -> void:
	if _turn_locked or _match_manager.is_match_over():
		return
	_turn_locked = true

	while _match_manager.phase == MatchManager.Phase.PLAYING and _match_manager.is_ai_controlled(_match_manager.current_player):
		await get_tree().create_timer(AI_TURN_DELAY_SEC).timeout
		if not _is_active():
			_unlock_turn()
			return

		var player_index: int = _match_manager.current_player
		var ai_player: AiPlayer = _match_manager.ai_players[player_index]
		var legal: Array[CardModel] = _match_manager.get_legal_plays(player_index)
		var context: Dictionary = _match_manager.build_ai_context(player_index)
		var card: CardModel = ai_player.choose_card(legal, context)

		var result: MatchManager.PlayResult = _match_manager.play_card(player_index, card)
		if not result.success:
			_debug().log_error("Table: l'IA du siège %d a proposé un coup invalide" % player_index)
			break

		var seat: PlayerSeat = _seats[player_index]
		var start_center: Vector2 = seat.get_global_transform_with_canvas() * (seat.size / 2.0)
		seat.hand_card_count = maxi(seat.hand_card_count - 1, 0)

		await _animate_card_play(player_index, card, start_center)
		if not _is_active():
			_unlock_turn()
			return
		await _handle_post_play(result)
		if not _is_active():
			_unlock_turn()
			return

		if result.match_completed or _match_manager.is_match_over():
			_unlock_turn()
			return

	_unlock_turn()
	_refresh_turn_ui()

# --- Animation : pose d'une carte, résolution et ramassage d'un pli ---------

## Fait glisser une carte (nouvellement créée, voir `_spawn_traveling_card`)
## depuis `start_center` (position globale, main ou siège d'origine) jusqu'à
## l'emplacement de pli de `player_index` (voir `TableAnimations`).
## Le son de pose de carte est déclenché par `MatchManager.play_card()`
## (`GameEvents.card_played` -> `AudioService`) avant même l'appel à cette
## fonction : il démarre donc bien en même temps que le glissement visuel.
func _animate_card_play(player_index: int, card: CardModel, start_center: Vector2) -> void:
	var traveling_card: Control = _spawn_traveling_card(card, start_center)
	var target_slot: Control = _trick_slots[player_index]
	var target_center: Vector2 = target_slot.get_global_transform_with_canvas() * (target_slot.size / 2.0)
	if card.is_queen_of_spades():
		_audio().play_queen_of_spades()
		_queen_avatar_burst.play(_seats[player_index].character_id)
		await TableAnimations.play_queen_bullet_time(
			self,
			traveling_card,
			target_center,
			_bullet_time_camera,
			_bullet_time_dim
		)
	else:
		await TableAnimations.play_card_to_trick(self, traveling_card, target_center)
	if not _is_active():
		return
	_trick_card_views[player_index] = traveling_card
	_refresh_lead_suit_indicator()

## Crée la carte face visible qui glissera jusqu'au pli. Reste volontairement
## sans rotation et avec `pivot_offset` à sa valeur par défaut `(0, 0)`, pour
## que son centre visuel se calcule sans ambiguïté (voir `TableAnimations`).
func _spawn_traveling_card(card: CardModel, start_global_center: Vector2) -> Control:
	var card_view: Control = CardViewScene.instantiate()
	card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_view.face_up = true
	card_view.front_texture = CardTexturePaths.get_front_texture(card)
	card_view.scale = Vector2(TRICK_CARD_SCALE, TRICK_CARD_SCALE)
	_animation_layer.add_child(card_view)
	var visual_half_size: Vector2 = CARD_BASE_SIZE * TRICK_CARD_SCALE / 2.0
	card_view.global_position = start_global_center - visual_half_size
	return card_view

## Suite d'un coup joué (humain ou IA) : rafraîchit les compteurs de main
## adverses puis, si le pli est complet, enchaîne la séquence de résolution
## (surbrillance, pause, ramassage) et la fin de manche/partie éventuelle.
func _handle_post_play(result: MatchManager.PlayResult) -> void:
	_refresh_opponent_hand_counts()

	if not result.trick_completed:
		_refresh_turn_ui()
		return

	await _resolve_trick_sequence(result.trick_winner, result.match_completed)
	if not _is_active():
		return
	_refresh_scores()

	if result.hand_completed:
		if result.match_completed or _match_manager.is_match_over():
			_show_match_end_popup()
			return
		await _show_hand_end_popup()
		if not _is_active():
			return
		_match_manager.start_new_hand()
		await _deal_visual_sequence()
		if not _is_active():
			return
		_refresh_scores()

	_refresh_turn_ui()

## Met en évidence la carte gagnante, laisse le pli visible (2 s en cours de
## partie, 4,5 s pour le dernier pli d'une partie), puis ramasse le pli sauf
## en fin de partie où les cartes restent sur la table jusqu'à la popup.
func _resolve_trick_sequence(winner_index: int, is_final_match_trick: bool = false) -> void:
	var winner_card_view: Control = _trick_card_views.get(winner_index)
	if winner_card_view:
		await TableAnimations.highlight_winning_card(self, winner_card_view)
		if not _is_active():
			return

	var visible_duration: float = (
		TableAnimations.MATCH_END_TRICK_VISIBLE_DURATION_SEC
		if is_final_match_trick
		else TableAnimations.TRICK_VISIBLE_DURATION_SEC
	)
	await get_tree().create_timer(visible_duration).timeout
	if not _is_active():
		return

	if is_final_match_trick:
		return

	var winner_seat: PlayerSeat = _seats[winner_index]
	var target_center: Vector2 = winner_seat.get_global_transform_with_canvas() * (winner_seat.size / 2.0)
	var card_views: Array[Control] = []
	for card_view in _trick_card_views.values():
		card_views.append(card_view as Control)
	await TableAnimations.collect_trick(self, card_views, target_center)
	if not _is_active():
		return
	_trick_card_views.clear()

# --- Rafraîchissement de l'affichage -----------------------------------------

func _refresh_opponent_hand_counts() -> void:
	for player_index in range(HeartsRules.PLAYER_COUNT):
		_seats[player_index].hand_card_count = _match_manager.hands[player_index].count()

func _refresh_scores() -> void:
	var hand_scores: Array = _match_manager.get_current_hand_raw_scores()
	var hearts: Array = _match_manager.get_current_hand_hearts_captured()
	for player_index in range(HeartsRules.PLAYER_COUNT):
		_seats[player_index].score = hand_scores[player_index]
		_seats[player_index].heart_penalty = hearts[player_index]
	_refresh_cumulative_scoreboard()


func _refresh_cumulative_scoreboard() -> void:
	var names: Array = []
	for seat in _seats:
		names.append(seat.player_name)
	_match_scoreboard.update_display(
		_match_manager.hand_number,
		names,
		_match_manager.score_manager.get_scores()
	)

func _unlock_turn() -> void:
	_turn_locked = false
	_refresh_human_hand_legality()


func _refresh_turn_ui() -> void:
	var playing: bool = _match_manager.phase == MatchManager.Phase.PLAYING
	for player_index in range(HeartsRules.PLAYER_COUNT):
		_seats[player_index].set_active_turn(playing and player_index == _match_manager.current_player)

	if playing:
		if _match_manager.current_player == HUMAN_INDEX:
			_top_menu_bar.set_turn_text(_human_turn_hint_text())
		else:
			_top_menu_bar.set_turn_text("%s joue..." % _seats[_match_manager.current_player].player_name)
		var hand_score: int = _match_manager.get_current_hand_raw_scores()[HUMAN_INDEX]
		var match_score: int = _match_manager.score_manager.get_score(HUMAN_INDEX)
		_top_menu_bar.set_score_text("Manche : %d pts  |  Partie : %d pts" % [hand_score, match_score])

	_refresh_human_hand_legality()
	_refresh_lead_suit_indicator()

## Message de tour pour le joueur humain : rappelle les contraintes courantes
## (2 de Trèfle au 1er pli, Cœurs non défoncés) afin d'éviter l'impression
## d'un bug quand des cartes sont grisées à tort apparent.
func _human_turn_hint_text() -> String:
	var is_leading := _match_manager.trick_manager.played_count() == 0
	var rule_engine: RuleEngine = _match_manager.rule_engine

	if is_leading and rule_engine.is_first_trick:
		var legal := _match_manager.get_legal_plays(HUMAN_INDEX)
		if legal.size() == 1 and HeartsRules.is_two_of_clubs(legal[0]):
			return "À vous — jouez le 2 de Trèfle"
		return "À vous de jouer (1er pli : pas de points)"

	if is_leading and not rule_engine.hearts_broken:
		for card in _match_manager.get_legal_plays(HUMAN_INDEX):
			if not card.is_heart():
				return "À vous — les Cœurs ne sont pas encore défoncés"

	return "À vous de jouer"

## Cartes légales pour le joueur humain dans le contexte courant (liste vide
## si ce n'est pas son tour ou si la manche n'est pas en cours).
func _current_human_legal_plays() -> Array[CardModel]:
	if _match_manager.phase != MatchManager.Phase.PLAYING or _match_manager.current_player != HUMAN_INDEX:
		return []
	return _match_manager.get_legal_plays(HUMAN_INDEX)

## Marque les cartes illégales de la main humaine (voile gris + position
## basse via `CardView.set_playable(false)`) et les rend insensibles aux
## clics/survols, pour que seules les cartes légales réagissent (voir
## docs/DECISIONS.md ADR-020).
func _refresh_human_hand_legality() -> void:
	var legal: Array[CardModel] = _current_human_legal_plays()
	var allow_play: bool = not _turn_locked
	for i in _hand_card_views.size():
		var card_view: Control = _hand_card_views[i]
		var card: CardModel = _hand_cards[i]
		var is_legal: bool = allow_play and _card_in_list(card, legal)
		card_view.modulate = Color.WHITE
		card_view.set_playable(is_legal)
		card_view.mouse_filter = Control.MOUSE_FILTER_STOP if is_legal else Control.MOUSE_FILTER_IGNORE

func _card_in_list(card: CardModel, cards: Array[CardModel]) -> bool:
	for existing_card in cards:
		if existing_card.equals(card):
			return true
	return false


func _audio() -> Node:
	return get_node("/root/AudioService") as AudioServiceScript


func _session() -> Node:
	return get_node("/root/GameSession") as GameSessionScript


func _debug() -> Node:
	return get_node("/root/DebugService") as DebugServiceScript

# --- Fin de manche / fin de partie --------------------------------------------

func _play_hand_end_seat_reactions(hand_winner_index: int) -> void:
	for player_index in range(HeartsRules.PLAYER_COUNT):
		if player_index == hand_winner_index:
			_seats[player_index].play_hand_win_reaction()
		else:
			_seats[player_index].play_hand_loss_reaction()


func _show_hand_end_popup() -> void:
	var winner_index: int = _match_manager.get_last_hand_winner()
	_play_hand_end_seat_reactions(winner_index)
	var names: Array = []
	var character_ids: Array = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		names.append(_seats[player_index].player_name)
		character_ids.append(_seats[player_index].character_id)
	_hand_end_dialog.show_result(
		winner_index,
		names,
		_match_manager.last_hand_scores,
		_match_manager.score_manager.get_scores(),
		character_ids
	)
	await _hand_end_dialog.continue_requested
	if not _is_active():
		return


func _show_match_end_popup() -> void:
	if _match_end_dialog.visible:
		return
	_refresh_turn_ui()
	var winner_index: int = _match_manager.get_match_winner()
	var names: Array = []
	var character_ids: Array = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		names.append(_seats[player_index].player_name)
		character_ids.append(_seats[player_index].character_id)
	_match_end_dialog.show_result(
		winner_index,
		names,
		_match_manager.score_manager.get_scores(),
		_match_manager.last_hand_scores,
		character_ids
	)
	if winner_index == HUMAN_INDEX:
		_victory_petals.play()
