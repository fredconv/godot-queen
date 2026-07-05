extends Control
## MainMenu
## Écran de menu principal (étape 7 de docs/ROADMAP.md). Contrôleur minimal :
## lance une partie de démonstration sur `table.tscn`, quitte le jeu, ou
## affiche les écrans Scores / Configuration.
## Aucune règle de jeu ici, uniquement de la navigation entre scènes.

@onready var _title_label: Label = $CenterContainer/Menu/TitleLabel
@onready var _btn_new_game: Button = $CenterContainer/Menu/BtnNewGame
@onready var _btn_scores: Button = $CenterContainer/Menu/BtnScores
@onready var _btn_settings: Button = $CenterContainer/Menu/BtnSettings
@onready var _btn_quit: Button = $CenterContainer/Menu/BtnQuit
@onready var _menu_root: Control = $CenterContainer/Menu
@onready var _settings_screen: Control = $SettingsScreen
@onready var _scores_screen: Control = $ScoresScreen

var _menu_buttons: Array[Button] = []


func _ready() -> void:
	_menu_buttons = [_btn_new_game, _btn_scores, _btn_settings, _btn_quit]
	_settings_screen.closed.connect(_on_overlay_closed)
	_scores_screen.closed.connect(_on_overlay_closed)
	LocaleAware.bind(self, _refresh_locale)
	_refresh_locale()
	AudioService.ensure_music_playing()
	call_deferred("_focus_default_button")


func _refresh_locale() -> void:
	_title_label.text = tr(UiKeys.MENU_TITLE)
	_btn_new_game.text = tr(UiKeys.MENU_NEW_GAME)
	_btn_scores.text = tr(UiKeys.MENU_SCORES)
	_btn_settings.text = tr(UiKeys.MENU_SETTINGS)
	_btn_quit.text = tr(UiKeys.MENU_QUIT)


func _focus_default_button() -> void:
	if _is_overlay_open():
		return
	_btn_new_game.grab_focus()


func _set_menu_interactive(enabled: bool) -> void:
	_menu_root.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	for button in _menu_buttons:
		button.disabled = not enabled


func _is_overlay_open() -> bool:
	return _settings_screen.visible or _scores_screen.visible


func _on_btn_new_game_pressed() -> void:
	if _is_overlay_open():
		return
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")


func _on_btn_scores_pressed() -> void:
	_open_overlay(_scores_screen)


func _on_btn_settings_pressed() -> void:
	_open_overlay(_settings_screen)


func _open_overlay(overlay: Control) -> void:
	_set_menu_interactive(false)
	overlay.open()


func _on_overlay_closed() -> void:
	_set_menu_interactive(true)
	call_deferred("_focus_default_button")


func _on_btn_quit_pressed() -> void:
	if _is_overlay_open():
		return
	get_tree().quit()
