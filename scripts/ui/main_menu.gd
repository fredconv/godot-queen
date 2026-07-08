extends Control
## MainMenu
## Écran de menu principal (étape 7 de docs/ROADMAP.md). Contrôleur minimal :
## lance une partie de démonstration sur `table.tscn`, quitte le jeu, ou
## affiche les écrans Scores / Configuration / Crédits.

@onready var _title_label: Label = $CenterContainer/MenuColumn/TitleLabel
@onready var _btn_new_game: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnNewGame
@onready var _btn_scores: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnScores
@onready var _btn_settings: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnSettings
@onready var _btn_credits: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnCredits
@onready var _btn_quit: NinePatchButton = $CenterContainer/MenuColumn/ButtonStack/BtnQuit
@onready var _menu_root: Control = $CenterContainer/MenuColumn
@onready var _player_label: Label = $PlayerLabel
@onready var _settings_screen: Control = $SettingsScreen
@onready var _scores_screen: Control = $ScoresScreen
@onready var _credits_screen: Control = $CreditsScreen
@onready var _profile_setup_screen: Control = $ProfileSetupScreen
@onready var _game_mode_screen: Control = $GameModeScreen
@onready var _hot_seat_lobby_screen: Control = $HotSeatLobbyScreen
@onready var _multiplayer_lobby_screen: Control = $MultiplayerLobbyScreen

var _menu_buttons: Array[BaseButton] = []


func _ready() -> void:
	_menu_buttons = [_btn_new_game, _btn_scores, _btn_settings, _btn_credits, _btn_quit]
	for button: BaseButton in _menu_buttons:
		UiOffsetAnim.prepare_hidden(button)
	UiFocusNav.chain_vertical(_menu_buttons)
	_settings_screen.closed.connect(_on_overlay_closed)
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
	_refresh_locale()
	AudioService.ensure_music_playing()
	call_deferred("_after_ready")


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.TITLE)
	_btn_new_game.set_button_text(tr(MenuKeys.NEW_GAME))
	_btn_scores.set_button_text(tr(MenuKeys.SCORES))
	_btn_settings.set_button_text(tr(MenuKeys.SETTINGS))
	_btn_credits.set_button_text(tr(MenuKeys.CREDITS))
	_btn_quit.set_button_text(tr(MenuKeys.QUIT))
	_refresh_player_label()


func _refresh_player_label() -> void:
	if not _player_label:
		return
	_player_label.text = PlayerProfileService.get_display_name()


func _after_ready() -> void:
	if PlayerProfileService.needs_setup():
		_set_menu_interactive(false)
		_profile_setup_screen.open()
	else:
		PlayerProfileService.touch_last_used()
		_play_menu_entrance()
		_focus_default_button()


func _play_menu_entrance() -> void:
	UiOffsetAnim.stagger_scale_in(_menu_buttons)


func _on_profile_setup_completed() -> void:
	_set_menu_interactive(true)
	_play_menu_entrance()
	_focus_default_button()


func _focus_default_button() -> void:
	if _profile_setup_screen.visible:
		return
	if _is_overlay_open():
		return
	_btn_new_game.grab_focus()


func _set_menu_interactive(enabled: bool) -> void:
	_menu_root.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	for button in _menu_buttons:
		button.disabled = not enabled


func _is_overlay_open() -> bool:
	return (
		_settings_screen.visible
		or _scores_screen.visible
		or _credits_screen.visible
		or _profile_setup_screen.visible
		or _game_mode_screen.visible
		or _hot_seat_lobby_screen.visible
		or _multiplayer_lobby_screen.visible
	)


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


func _on_btn_settings_pressed() -> void:
	_open_overlay(_settings_screen)


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
