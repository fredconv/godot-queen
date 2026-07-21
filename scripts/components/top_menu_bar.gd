extends Control
## TopMenuBar
## Barre de menu supérieure (style bois) : affiche les infos de tour/scores
## et expose des signaux pour les actions des boutons. Ne contient aucune
## règle de jeu ; le câblage se fait par connexion directe depuis la scène
## propriétaire (`table.gd`, `main_menu.gd`), pas via `GameEvents`.

signal hamburger_pressed
signal help_pressed
signal scores_pressed
signal tricks_pressed
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
@onready var _btn_tricks: Button = $Margin/Bar/LeftButtons/BtnTricks
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
	UiThemeCatalog.ensure_project_theme_enriched()
	# Audio (MUSIQUE / SUIVANT) reste dans Configuration — masqué pour alléger la barre en jeu.
	_btn_toggle_music.visible = false
	_btn_next_music.visible = false
	_text_buttons = [_btn_help, _btn_scores, _btn_tricks, _btn_new, _btn_menu]
	_all_buttons = [
		_btn_hamburger,
		_btn_help,
		_btn_scores,
		_btn_tricks,
		_btn_new,
		_btn_menu,
		_btn_settings,
	]
	_apply_bar_background_style()
	_apply_compact_button_styles()
	_ensure_bar_separators()
	UiFocusNav.chain_horizontal(_all_buttons)
	LocaleAware.bind(self, refresh_locale)
	refresh_locale()


func _apply_bar_background_style() -> void:
	var bg: Panel = $Background as Panel
	if bg == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.15, 0.09, 1.0)
	style.border_color = UiPalette.GOLD
	style.border_width_bottom = 3
	style.border_width_top = 1
	style.border_width_left = 0
	style.border_width_right = 0
	style.set_corner_radius_all(0)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	bg.add_theme_stylebox_override("panel", style)


func _ensure_bar_separators() -> void:
	var bar: HBoxContainer = $Margin/Bar as HBoxContainer
	if bar == null or bar.get_node_or_null("SepLeft") != null:
		return
	var sep_left := _make_separator("SepLeft")
	var sep_right := _make_separator("SepRight")
	bar.add_child(sep_left)
	bar.move_child(sep_left, $Margin/Bar/CenterInfo.get_index())
	bar.add_child(sep_right)
	bar.move_child(sep_right, $Margin/Bar/RightButtons.get_index())


func _make_separator(node_name: String) -> ColorRect:
	var sep := ColorRect.new()
	sep.name = node_name
	sep.custom_minimum_size = Vector2(2, 28)
	sep.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.4)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return sep


func set_turn_text(text: String) -> void:
	var previous: String = _turn_label.text
	_turn_label.text = text
	if text != previous and not text.is_empty():
		_pulse_turn_label()


func set_score_text(text: String) -> void:
	_score_label.text = text


func _pulse_turn_label() -> void:
	## Feedback court « à vous / tour » — scale léger, pas d’élastique.
	UiOffsetAnim.enable_on(_turn_label)
	_turn_label.offset_transform_scale = Vector2(1.0, 1.0)
	_turn_label.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
	var tween: Tween = create_tween()
	tween.tween_property(_turn_label, "offset_transform_scale", Vector2(1.06, 1.06), 0.1) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_turn_label, "offset_transform_scale", Vector2.ONE, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if is_instance_valid(_turn_label):
			_turn_label.add_theme_color_override("font_color", UiPalette.CREAM)
	)


func set_music_enabled_display(enabled: bool) -> void:
	_music_enabled = enabled
	_btn_toggle_music.text = TableCopy.music_toggle_label(enabled)


func refresh_locale() -> void:
	_btn_help.text = tr(TableKeys.TOP_HELP)
	_btn_scores.text = tr(TableKeys.TOP_SCORES)
	_btn_tricks.text = tr(TableKeys.TOP_TRICKS)
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
	_turn_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	_score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	_turn_label.add_theme_constant_override("shadow_offset_x", 1)
	_turn_label.add_theme_constant_override("shadow_offset_y", 1)
	_score_label.add_theme_constant_override("shadow_offset_x", 1)
	_score_label.add_theme_constant_override("shadow_offset_y", 1)
	for btn: Button in _text_buttons:
		btn.add_theme_font_size_override("font_size", LocaleFonts.TOP_BAR_BUTTON_FONT_SIZE)
		_fit_text_button_width(btn)
	set_music_enabled_display(_music_enabled)


func _fit_text_button_width(btn: Button) -> void:
	var font: Font = btn.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size: int = btn.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = LocaleFonts.TOP_BAR_BUTTON_FONT_SIZE
	var text_w: float = font.get_string_size(btn.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var needed: int = NinePatchButton.snap_width_up(int(ceili(text_w)) + 24)
	btn.custom_minimum_size.x = float(maxi(needed, 56))
	btn.custom_minimum_size.y = float(LocaleFonts.TOP_BAR_BUTTON_HEIGHT)


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
	## Style pixel premium : coins 0, bordure or, états hover/pressed/focus distincts.
	UiThemeCatalog.apply_variation(btn, UiThemeCatalog.V_SMALL_HUD_BUTTON)
	btn.add_theme_stylebox_override("normal", UiStyleFactory.pixel_bar_button_style(
		UiPalette.BTN_BG, UiPalette.PANEL_BORDER, 2
	))
	btn.add_theme_stylebox_override("hover", UiStyleFactory.pixel_bar_button_style(
		UiPalette.BTN_BG_HOVER, UiPalette.GOLD_BRIGHT, 2
	))
	btn.add_theme_stylebox_override("pressed", UiStyleFactory.pixel_bar_button_style(
		UiPalette.BTN_BG_PRESSED, UiPalette.GOLD, 2
	))
	btn.add_theme_stylebox_override("focus", UiStyleFactory.pixel_bar_focus_style())
	btn.add_theme_stylebox_override("disabled", UiStyleFactory.pixel_bar_button_style(
		Color(0.08, 0.1, 0.09, 0.7), Color(0.4, 0.4, 0.35, 1.0), 1
	))
	btn.add_theme_color_override("font_color", UiPalette.CREAM)
	btn.add_theme_color_override("font_hover_color", UiPalette.GOLD_BRIGHT)
	btn.add_theme_color_override("font_pressed_color", UiPalette.GOLD)
	btn.add_theme_color_override("font_focus_color", UiPalette.GOLD_BRIGHT)


func _on_btn_hamburger_pressed() -> void:
	hamburger_pressed.emit()


func _on_btn_help_pressed() -> void:
	help_pressed.emit()


func _on_btn_scores_pressed() -> void:
	scores_pressed.emit()


func _on_btn_tricks_pressed() -> void:
	tricks_pressed.emit()


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
