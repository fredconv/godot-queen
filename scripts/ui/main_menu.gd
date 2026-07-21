extends Control
## MainMenu
## Écran de menu principal : intro visuelle puis navigation vers la table ou les overlays.


const BG_HOLD_SEC: float = 2.4
const OVERLAY_FADE_SEC: float = 0.85
const MENU_FADE_SEC: float = 0.55
const MENU_BUTTON_FILL: Color = Color(0.05, 0.16, 0.09, 1.0)
## Overlays Settings / Help : instanciés au premier `open()` (A2).
const _SETTINGS_SCENE: PackedScene = preload("res://scenes/menus/settings_screen.tscn")
const _HELP_SCENE: PackedScene = preload("res://scenes/menus/help_screen.tscn")

@onready var _background_texture: TextureRect = $BackgroundTexture
@onready var _dark_overlay: ColorRect = $DarkOverlay
@onready var _center_container: CenterContainer = $CenterContainer
## Titre UI masqué : branding déjà dans `accueil-bg.png` (évite double titre I5).
@onready var _title_label: Label = $CenterContainer/MenuColumn/TitleLabel
@onready var _btn_new_game: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnNewGame
@onready var _btn_rules: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnRules
@onready var _btn_scores: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnScores
@onready var _btn_settings: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnSettings
@onready var _btn_credits: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnCredits
@onready var _btn_quit: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnQuit
@onready var _menu_root: Control = $CenterContainer/MenuColumn
@onready var _player_label: Label = $PlayerLabel
@onready var _scores_screen: Control = $ScoresScreen
@onready var _credits_screen: Control = $CreditsScreen
@onready var _profile_setup_screen: Control = $ProfileSetupScreen
@onready var _game_mode_screen: Control = $GameModeScreen
@onready var _hot_seat_lobby_screen: Control = $HotSeatLobbyScreen
@onready var _multiplayer_lobby_screen: Control = $MultiplayerLobbyScreen

var _settings_screen: Control
var _help_screen: Control
var _menu_buttons: Array[BaseButton] = []


func _ready() -> void:
	_menu_buttons = [_btn_new_game, _btn_rules, _btn_scores, _btn_settings, _btn_credits, _btn_quit]
	for button: BaseButton in _menu_buttons:
		UiOffsetAnim.prepare_hidden(button)
	UiFocusNav.chain_vertical(_menu_buttons)
	_scores_screen.closed.connect(_on_overlay_closed)
	_credits_screen.closed.connect(_on_overlay_closed)
	_profile_setup_screen.completed.connect(_on_profile_setup_completed)
	_game_mode_screen.solo_selected.connect(_on_game_mode_solo_selected)
	_game_mode_screen.hot_seat_selected.connect(_on_game_mode_hot_seat_selected)
	_game_mode_screen.online_selected.connect(_on_game_mode_online_selected)
	_game_mode_screen.closed.connect(_on_overlay_closed)
	_hot_seat_lobby_screen.start_requested.connect(_on_hot_seat_start_requested)
	_hot_seat_lobby_screen.closed.connect(_on_overlay_closed)
	_multiplayer_lobby_screen.closed.connect(_on_overlay_closed)
	LocaleAware.bind(self, _refresh_locale)
	PlayerProfileService.profile_changed.connect(_refresh_player_label)
	UiThemeCatalog.ensure_project_theme_enriched()
	_ensure_button_stack_panel()
	_ensure_vignette()
	_refresh_locale()
	_setup_intro_state()
	_apply_menu_button_styles()
	AudioService.enable_music_for_home_screen()
	call_deferred("_after_ready")


func _ensure_button_stack_panel() -> void:
	var column: VBoxContainer = $CenterContainer/MenuColumn as VBoxContainer
	if column == null:
		return
	var existing: PanelContainer = column.get_node_or_null("ButtonStackPanel") as PanelContainer
	if existing != null:
		UiStyleFactory.apply_pixel_panel(existing, UiStyleFactory.menu_button_stack_panel_style())
		return
	var stack: VBoxContainer = column.get_node_or_null("ButtonStack") as VBoxContainer
	if stack == null:
		return
	var index: int = stack.get_index()
	var panel := PanelContainer.new()
	panel.name = "ButtonStackPanel"
	UiStyleFactory.apply_pixel_panel(panel, UiStyleFactory.menu_button_stack_panel_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	var line_top := _make_gold_rule()
	var line_bottom := _make_gold_rule()
	column.remove_child(stack)
	inner.add_child(line_top)
	inner.add_child(stack)
	inner.add_child(line_bottom)
	margin.add_child(inner)
	panel.add_child(margin)
	column.add_child(panel)
	column.move_child(panel, index)


func _make_gold_rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.55)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


func _ensure_vignette() -> void:
	if has_node("VignetteOverlay"):
		return
	var vignette := ColorRect.new()
	vignette.name = "VignetteOverlay"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.color = Color(1, 1, 1, 1)
	var shader: Shader = load("res://assets/shaders/ui_vignette.gdshader") as Shader
	if shader != null:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("intensity", 0.52)
		mat.set_shader_parameter("softness", 0.68)
		vignette.material = mat
	else:
		vignette.color = UiPalette.VIGNETTE
	## Au-dessus du fond, sous le menu (avant CenterContainer).
	add_child(vignette)
	move_child(vignette, _dark_overlay.get_index() + 1)


func _apply_menu_button_styles() -> void:
	for button: BaseButton in _menu_buttons:
		var menu_button := button as NinePatchButton
		if menu_button != null:
			menu_button.ensure_opaque_background(MENU_BUTTON_FILL, UiPalette.GOLD, 0)
	## Premier bouton = accent primaire (bordure or plus marquée au repos).
	if _btn_new_game != null:
		_btn_new_game.ensure_opaque_background(
			Color(0.08, 0.18, 0.1, 1.0),
			UiPalette.GOLD_BRIGHT,
			0
		)
	## Quit = danger.
	if _btn_quit != null:
		_btn_quit.ensure_opaque_background(
			Color(0.2, 0.07, 0.07, 1.0),
			UiPalette.DANGER_BORDER,
			0
		)
		_btn_quit.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _setup_intro_state() -> void:
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_title_label.visible = false
	_dark_overlay.modulate.a = 0.0
	_center_container.modulate.a = 0.0
	_player_label.modulate.a = 0.0
	_set_menu_interactive(false)


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.TITLE)
	_btn_new_game.set_button_text(tr(MenuKeys.NEW_GAME))
	_btn_rules.set_button_text(tr(MenuKeys.RULES))
	_btn_scores.set_button_text(tr(MenuKeys.SCORES))
	_btn_settings.set_button_text(tr(MenuKeys.SETTINGS))
	_btn_credits.set_button_text(tr(MenuKeys.CREDITS))
	_btn_quit.set_button_text(tr(MenuKeys.QUIT))
	NinePatchButton.uniform_fit_group(_menu_buttons)
	_refresh_player_label()


func _refresh_player_label() -> void:
	if not _player_label:
		return
	_player_label.text = PlayerProfileService.get_display_name()


func _after_ready() -> void:
	await _play_home_intro()
	if PlayerProfileService.needs_setup():
		_profile_setup_screen.open()
	else:
		PlayerProfileService.touch_last_used()
		await _reveal_menu()
		_focus_default_button()


func _play_home_intro() -> void:
	await get_tree().create_timer(BG_HOLD_SEC).timeout
	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_property(_dark_overlay, "modulate:a", 1.0, OVERLAY_FADE_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await overlay_tween.finished


func _reveal_menu() -> void:
	var menu_tween: Tween = create_tween().set_parallel(true)
	menu_tween.tween_property(_center_container, "modulate:a", 1.0, MENU_FADE_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	menu_tween.tween_property(_player_label, "modulate:a", 1.0, MENU_FADE_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await menu_tween.finished
	_set_menu_interactive(true)
	_play_menu_entrance()


func _play_menu_entrance() -> void:
	UiOffsetAnim.stagger_scale_in(_menu_buttons)


func _on_profile_setup_completed() -> void:
	await _reveal_menu()
	_focus_default_button()


func _focus_default_button() -> void:
	if _profile_setup_screen.visible:
		return
	if _is_overlay_open():
		return
	if not _btn_new_game.is_inside_tree():
		return
	_btn_new_game.grab_focus()


func _set_menu_interactive(enabled: bool) -> void:
	_menu_root.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	for button in _menu_buttons:
		button.disabled = not enabled


func _is_overlay_open() -> bool:
	return (
		(_settings_screen != null and _settings_screen.visible)
		or _scores_screen.visible
		or _credits_screen.visible
		or _profile_setup_screen.visible
		or _game_mode_screen.visible
		or _hot_seat_lobby_screen.visible
		or _multiplayer_lobby_screen.visible
		or (_help_screen != null and _help_screen.visible)
	)


func _ensure_settings_screen() -> Control:
	if _settings_screen != null and is_instance_valid(_settings_screen):
		return _settings_screen
	_settings_screen = _SETTINGS_SCENE.instantiate() as Control
	_settings_screen.visible = false
	add_child(_settings_screen)
	_settings_screen.closed.connect(_on_overlay_closed)
	return _settings_screen


func _ensure_help_screen() -> Control:
	if _help_screen != null and is_instance_valid(_help_screen):
		return _help_screen
	_help_screen = _HELP_SCENE.instantiate() as Control
	_help_screen.visible = false
	add_child(_help_screen)
	_help_screen.closed.connect(_on_overlay_closed)
	return _help_screen


func _on_btn_new_game_pressed() -> void:
	if _is_overlay_open():
		return
	_open_overlay(_game_mode_screen)


func _on_game_mode_solo_selected() -> void:
	GameSession.set_launch_config(
		SeatSetup.create_solo(
			PlayerProfileService.get_display_name(),
			PlayerProfileService.get_player_id()
		)
	)
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")


func _on_game_mode_hot_seat_selected() -> void:
	_set_menu_interactive(false)
	_hot_seat_lobby_screen.open()


func _on_game_mode_online_selected() -> void:
	_set_menu_interactive(false)
	_multiplayer_lobby_screen.open()


func _on_hot_seat_start_requested(config: MatchLaunchConfig) -> void:
	GameSession.set_launch_config(config)
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")


func _on_btn_scores_pressed() -> void:
	_open_overlay(_scores_screen)


func _on_btn_rules_pressed() -> void:
	_open_overlay(_ensure_help_screen())


func _on_btn_settings_pressed() -> void:
	_open_overlay(_ensure_settings_screen())


func _on_btn_credits_pressed() -> void:
	_open_overlay(_credits_screen)


func _open_overlay(overlay: Control) -> void:
	_set_menu_interactive(false)
	overlay.open()


func _on_overlay_closed() -> void:
	_set_menu_interactive(true)
	_refresh_locale()
	call_deferred("_focus_default_button")


func _on_btn_quit_pressed() -> void:
	if _is_overlay_open():
		return
	get_tree().quit()
