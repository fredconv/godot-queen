extends Control
## Table
## Contrôleur léger de la scène table : assemble le contexte partagé et
## délègue la logique aux modules `scripts/ui/table/*` (main humaine, coups,
## distribution, affichage, effets FX, cycle de partie). Voir
## docs/DECISIONS.md ADR-020/ADR-021 pour le câblage `MatchManager` et les
## animations.

enum ConfirmAction { NONE, LEAVE_MATCH, RESTART_MATCH }

## Overlays Settings / Help : instanciés au premier `open()` (A2).
const _SETTINGS_SCENE: PackedScene = preload("res://scenes/menus/settings_screen.tscn")
const _HELP_SCENE: PackedScene = preload("res://scenes/menus/help_screen.tscn")

var _ctx: TableContext
var _confirm_action: ConfirmAction = ConfirmAction.NONE
var _settings_screen: Control
var _help_screen: Control
var _context_shell: ContextShellHost

@onready var _ui_layer: CanvasLayer = $UILayer
@onready var _player_bottom_hand: Control = $HumanHandArea/PlayerBottomHand
@onready var _animation_layer: Control = $AnimationLayer
@onready var _top_menu_bar: Control = $UILayer/TopMenuBar
@onready var _confirm_dialog: Control = $UILayer/ConfirmDialog
@onready var _match_end_dialog: Control = $UILayer/MatchEndDialog
@onready var _hand_end_dialog: Control = $UILayer/HandEndDialog
@onready var _match_scoreboard: Control = $UILayer/MatchScoreboard
@onready var _scores_screen: Control = $UILayer/ScoresScreen
@onready var _human_hand_area: Control = $HumanHandArea
@onready var _hot_seat_overlay: HotSeatPrivacyOverlay = $HotSeatLayer/HotSeatPrivacyOverlay
@onready var _moon_suspicion_button: MoonSuspicionActionButton = $UILayer/MoonSuspicionButton
@onready var _trick_area: Control = $TrickArea
@onready var _player_seats: Control = $PlayerSeats
@onready var _background_color: ColorRect = $Background/ColorFill
@onready var _background_texture: TextureRect = $Background/TextureFill
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


func _ready() -> void:
	UiThemeCatalog.ensure_project_theme_enriched()
	_ctx = _build_context()
	TableFx.apply_table_theme(_ctx)
	TableFx.setup(_ctx)
	_ensure_table_vignette()
	_ensure_context_shell()
	_ensure_trick_slot_markers()
	_top_menu_bar.menu_pressed.connect(_on_top_menu_bar_menu_pressed)
	_top_menu_bar.scores_pressed.connect(_on_top_menu_bar_scores_pressed)
	_top_menu_bar.tricks_pressed.connect(_on_top_menu_bar_tricks_pressed)
	_top_menu_bar.new_game_pressed.connect(_on_top_menu_bar_new_game_pressed)
	_top_menu_bar.hamburger_pressed.connect(_on_top_menu_bar_hamburger_pressed)
	_top_menu_bar.help_pressed.connect(_on_top_menu_bar_help_pressed)
	_top_menu_bar.settings_pressed.connect(_on_top_menu_bar_settings_pressed)
	_moon_suspicion_button.pressed.connect(_on_moon_suspicion_button_pressed)
	_confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	_match_end_dialog.replay_requested.connect(_on_match_end_replay_requested)
	_match_end_dialog.quit_requested.connect(_on_match_end_quit_requested)
	NetworkMatchRelay.play_rejected.connect(_on_network_play_rejected)
	TableChrome.setup_music_controls(_ctx)
	LocaleAware.bind(self, _on_locale_changed)
	TableLocale.refresh_seat_names(_ctx)
	call_deferred("_start_new_match")


func _ensure_table_vignette() -> void:
	if has_node("VignetteOverlay"):
		return
	var vignette := ColorRect.new()
	vignette.name = "VignetteOverlay"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.z_index = 0
	var shader: Shader = load("res://assets/shaders/ui_vignette.gdshader") as Shader
	if shader != null:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("intensity", 0.28)
		mat.set_shader_parameter("softness", 0.85)
		vignette.material = mat
	else:
		vignette.color = UiPalette.VIGNETTE
	add_child(vignette)
	move_child(vignette, _background_texture.get_index() + 1)


## Phase a Context Shell : hosts + insets ; bottom bar slot inactif jusqu’à phase d.
func _ensure_context_shell() -> void:
	_context_shell = get_node_or_null("ContextShellHost") as ContextShellHost
	if _context_shell == null:
		_context_shell = ContextShellHost.new()
		_context_shell.name = "ContextShellHost"
		_context_shell.z_index = 5
		add_child(_context_shell)
		## Au-dessus des régions de jeu, sous UILayer (CanvasLayer).
		move_child(_context_shell, _animation_layer.get_index() + 1)
	_context_shell.bottom_bar_slot_active = true
	if not _context_shell.layout_applied.is_connected(_on_context_shell_layout_applied):
		_context_shell.layout_applied.connect(_on_context_shell_layout_applied)
	_context_shell.bind_play_regions([
		_player_seats,
		_trick_area,
		_human_hand_area,
		_animation_layer,
	])
	TableContextShell.setup(_ctx, _context_shell)


func get_context_shell() -> ContextShellHost:
	return _context_shell


func _unhandled_input(event: InputEvent) -> void:
	if TableContextShell.handle_unhandled_key(_ctx, event):
		get_viewport().set_input_as_handled()


func _on_context_shell_layout_applied(insets: Vector4) -> void:
	if _ctx == null:
		return
	# Le grand médaillon supérieur descend davantage que l'ancien avatar.
	# Décaler le pli dans tous les modes garde sa carte haute hors de la plaque,
	# avec encore assez d'air avant la main humaine et la barre inférieure.
	_trick_area.position.y += 32.0
	ReactionManager.apply_shell_insets(_ctx, insets)
	## Différé : laisser Godot appliquer les nouveaux offsets avant resync.
	call_deferred("_sync_after_shell_layout")


func _sync_after_shell_layout() -> void:
	if _ctx == null or not is_inside_tree():
		return
	TableTrickDisplay.sync_card_positions(_ctx)
	# L'éventail est construit à partir de la largeur utile. Le reconstruire
	# après ouverture/fermeture du tiroir garde la main et le siège humain dans
	# le même référentiel, y compris après qu'une carte a été jouée.
	if _ctx.match_manager != null and not _ctx.hand_card_views.is_empty():
		TableHumanHand.rebuild(_ctx)
	TableFx.refresh_lead_suit_indicator(_ctx)


func _ensure_trick_slot_markers() -> void:
	for slot: Control in _trick_slots:
		if slot == null or slot.get_node_or_null("SlotMarker") != null:
			continue
		var marker := Panel.new()
		marker.name = "SlotMarker"
		marker.set_anchors_preset(Control.PRESET_FULL_RECT)
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.draw_center = true
		style.bg_color = Color(0.02, 0.08, 0.04, 0.12)
		style.border_color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.22)
		style.set_border_width_all(1)
		style.set_corner_radius_all(0)
		marker.add_theme_stylebox_override("panel", style)
		slot.add_child(marker)
		slot.move_child(marker, 0)


func _exit_tree() -> void:
	if _ctx == null:
		return
	_ctx.scene_exiting = true
	NetworkMatchRelay.unregister_table()
	TableFx.on_exit(_ctx)


func _on_network_play_rejected(_error_code: StringName) -> void:
	if _ctx == null:
		return
	_ctx.unlock_turn()
	TableDisplay.refresh_turn_ui(_ctx)


func _build_context() -> TableContext:
	var ctx := TableContext.new()
	ctx.host = self
	ctx.player_bottom_hand = _player_bottom_hand
	ctx.animation_layer = _animation_layer
	ctx.top_menu_bar = _top_menu_bar
	ctx.confirm_dialog = _confirm_dialog
	ctx.match_end_dialog = _match_end_dialog
	ctx.hand_end_dialog = _hand_end_dialog
	ctx.match_scoreboard = _match_scoreboard
	ctx.trick_area = _trick_area
	ctx.background_color = _background_color
	ctx.background_texture = _background_texture
	ctx.seats = _seats
	ctx.trick_slots = _trick_slots
	ctx.human_hand_area = _human_hand_area
	ctx.hot_seat_overlay = _hot_seat_overlay
	ctx.moon_suspicion_button = _moon_suspicion_button
	return ctx


func _start_new_match() -> void:
	await TableMatchFlow.start_new_match(_ctx)


func _dispatch_human_card_selected(card_view: Control, card: CardModel) -> void:
	TablePlayFlow.on_human_card_selected(_ctx, card_view, card)


func _on_top_menu_bar_scores_pressed() -> void:
	TableContextShell.open_tab(_ctx, "POINTS")


func _on_top_menu_bar_tricks_pressed() -> void:
	TableContextShell.open_tab(_ctx, "PLIS")


func _on_moon_suspicion_button_pressed() -> void:
	await MoonSuspicionManager.on_button_pressed(_ctx)


func _on_top_menu_bar_new_game_pressed() -> void:
	if not TableServiceAccess.session(self).match_in_progress:
		await TableMatchFlow.on_replay_requested(_ctx)
		return
	_confirm_action = ConfirmAction.RESTART_MATCH
	_confirm_dialog.open(DialogCopy.restart_match_confirm())


func _on_top_menu_bar_hamburger_pressed() -> void:
	## Phase b : hamburger ouvre/ferme le Context Shell (scoreboard docké dedans).
	if _context_shell != null:
		TableContextShell.toggle_sidebar(_ctx)
	else:
		_match_scoreboard.visible = not _match_scoreboard.visible


func _on_top_menu_bar_help_pressed() -> void:
	TableContextShell.open_tab(_ctx, "AIDE")


func _on_top_menu_bar_settings_pressed() -> void:
	_ensure_settings_screen().open()


func _ensure_settings_screen() -> Control:
	if _settings_screen != null and is_instance_valid(_settings_screen):
		return _settings_screen
	_settings_screen = _SETTINGS_SCENE.instantiate() as Control
	_settings_screen.visible = false
	_ui_layer.add_child(_settings_screen)
	return _settings_screen


func _ensure_help_screen() -> Control:
	if _help_screen != null and is_instance_valid(_help_screen):
		return _help_screen
	_help_screen = _HELP_SCENE.instantiate() as Control
	_help_screen.visible = false
	_ui_layer.add_child(_help_screen)
	return _help_screen


func _on_locale_changed(_locale: String = "") -> void:
	if _ctx != null:
		TableLocale.apply(_ctx)


func _on_top_menu_bar_menu_pressed() -> void:
	if TableServiceAccess.session(self).match_in_progress:
		_confirm_action = ConfirmAction.LEAVE_MATCH
		_confirm_dialog.open(DialogCopy.leave_match_confirm())
	else:
		TableMatchFlow.return_to_main_menu(_ctx)


func _on_confirm_dialog_confirmed() -> void:
	match _confirm_action:
		ConfirmAction.LEAVE_MATCH:
			TableMatchFlow.on_leave_match_confirmed(_ctx)
		ConfirmAction.RESTART_MATCH:
			await TableMatchFlow.on_replay_requested(_ctx)
	_confirm_action = ConfirmAction.NONE


func _on_match_end_replay_requested() -> void:
	await TableMatchFlow.on_replay_requested(_ctx)


func _on_match_end_quit_requested() -> void:
	TableMatchFlow.on_quit_requested(_ctx)
