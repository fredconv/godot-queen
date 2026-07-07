extends Control
## TopMenuBar
## Barre de menu supérieure (style bois) : affiche les infos de tour/scores
## et expose des signaux pour les actions des boutons. Ne contient aucune
## règle de jeu ; le câblage réel se fera plus tard via `GameEvents` ou par
## connexion directe depuis la scène qui possède cette barre.

signal hamburger_pressed
signal help_pressed
signal scores_pressed
signal new_game_pressed
signal menu_pressed
signal settings_pressed
signal music_toggle_pressed
signal music_next_pressed

const LEGACY_ICON_HAMBURGER: Rect2i = Rect2i(603, 49, 144, 128)
const LEGACY_ICON_SETTINGS: Rect2i = Rect2i(603, 592, 144, 128)

@onready var _btn_hamburger: Button = $Margin/Bar/LeftButtons/BtnHamburger
@onready var _btn_help: Button = $Margin/Bar/LeftButtons/BtnHelp
@onready var _btn_scores: Button = $Margin/Bar/LeftButtons/BtnScores
@onready var _turn_label: Label = $Margin/Bar/CenterInfo/TurnLabel
@onready var _score_label: Label = $Margin/Bar/CenterInfo/ScoreLabel
@onready var _btn_new: Button = $Margin/Bar/RightButtons/BtnNew
@onready var _btn_toggle_music: Button = $Margin/Bar/RightButtons/BtnToggleMusic
@onready var _btn_next_music: Button = $Margin/Bar/RightButtons/BtnNextMusic
@onready var _btn_menu: Button = $Margin/Bar/RightButtons/BtnMenu
@onready var _btn_settings: Button = $Margin/Bar/RightButtons/BtnSettings

const PIXEL_THEME: Theme = preload("res://resources/themes/pixel_theme.tres")

var _music_enabled: bool = true
var _text_buttons: Array[Button] = []
var _all_buttons: Array[Button] = []


func _ready() -> void:
	theme = PIXEL_THEME
	_text_buttons = [_btn_help, _btn_scores, _btn_new, _btn_toggle_music, _btn_next_music, _btn_menu]
	_all_buttons = [
		_btn_hamburger,
		_btn_help,
		_btn_scores,
		_btn_new,
		_btn_toggle_music,
		_btn_next_music,
		_btn_menu,
		_btn_settings,
	]
	_apply_compact_button_styles()
	UiFocusNav.chain_horizontal(_all_buttons)
	LocaleAware.bind(self, refresh_locale)
	refresh_locale()


func set_turn_text(text: String) -> void:
	_turn_label.text = text


func set_score_text(text: String) -> void:
	_score_label.text = text


func set_music_enabled_display(enabled: bool) -> void:
	_music_enabled = enabled
	_btn_toggle_music.text = TableCopy.music_toggle_label(enabled)


func refresh_locale() -> void:
	_btn_help.text = tr(TableKeys.TOP_HELP)
	_btn_scores.text = tr(TableKeys.TOP_SCORES)
	_btn_new.text = tr(TableKeys.TOP_NEW)
	_btn_menu.text = tr(TableKeys.TOP_MENU)
	_btn_next_music.text = tr(TableKeys.TOP_MUSIC_NEXT)
	_btn_hamburger.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MENU)
	_btn_toggle_music.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MUSIC)
	_btn_next_music.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MUSIC_NEXT)
	_btn_settings.tooltip_text = tr(TableKeys.TOP_TOOLTIP_SETTINGS)
	_turn_label.add_theme_font_size_override("font_size", LocaleFonts.MENU_TURN_FONT_SIZE)
	_score_label.add_theme_font_size_override("font_size", LocaleFonts.MENU_SCORE_FONT_SIZE)
	_turn_label.add_theme_color_override("font_color", UiPalette.CREAM)
	_score_label.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
	for btn: Button in _text_buttons:
		btn.add_theme_font_size_override("font_size", LocaleFonts.TOP_BAR_BUTTON_FONT_SIZE)
	set_music_enabled_display(_music_enabled)


func _apply_compact_button_styles() -> void:
	var bar_height: int = LocaleFonts.TOP_BAR_BUTTON_HEIGHT
	var icon_size: int = LocaleFonts.TOP_BAR_ICON_BUTTON_SIZE
	for btn: Button in _text_buttons:
		btn.custom_minimum_size = Vector2(0, bar_height)
		_apply_flat_button_states(btn)
	_btn_hamburger.custom_minimum_size = Vector2(icon_size, bar_height)
	_btn_settings.custom_minimum_size = Vector2(icon_size, bar_height)
	UiStyleFactory.configure_legacy_icon_button(_btn_hamburger, LEGACY_ICON_HAMBURGER, 26)
	UiStyleFactory.configure_legacy_icon_button(_btn_settings, LEGACY_ICON_SETTINGS, 26)


func _apply_flat_button_states(btn: Button) -> void:
	for style_name: StringName in ["normal", "hover", "pressed", "focus", "disabled"]:
		var stylebox: StyleBox = PIXEL_THEME.get_stylebox(style_name, &"Button")
		if stylebox != null:
			btn.add_theme_stylebox_override(style_name, stylebox)


func _on_btn_hamburger_pressed() -> void:
	hamburger_pressed.emit()


func _on_btn_help_pressed() -> void:
	help_pressed.emit()


func _on_btn_scores_pressed() -> void:
	scores_pressed.emit()


func _on_btn_new_pressed() -> void:
	new_game_pressed.emit()


func _on_btn_menu_pressed() -> void:
	menu_pressed.emit()


func _on_btn_settings_pressed() -> void:
	settings_pressed.emit()


func _on_btn_toggle_music_pressed() -> void:
	music_toggle_pressed.emit()


func _on_btn_next_music_pressed() -> void:
	music_next_pressed.emit()
