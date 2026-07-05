extends Control
## Écran Configuration : volumes, musique, thème de table et langue.
## Overlay modal du menu principal (voir `main_menu.gd`).

signal closed

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _sfx_label: Label = $Panel/Margin/VBox/SfxRow/SfxLabel
@onready var _sfx_slider: HSlider = $Panel/Margin/VBox/SfxRow/SfxSlider
@onready var _sfx_value_label: Label = $Panel/Margin/VBox/SfxRow/SfxValueLabel
@onready var _music_label: Label = $Panel/Margin/VBox/MusicRow/MusicLabel
@onready var _music_slider: HSlider = $Panel/Margin/VBox/MusicRow/MusicSlider
@onready var _music_value_label: Label = $Panel/Margin/VBox/MusicRow/MusicValueLabel
@onready var _music_toggle: CheckButton = $Panel/Margin/VBox/MusicToggle
@onready var _theme_label: Label = $Panel/Margin/VBox/ThemeRow/ThemeLabel
@onready var _theme_option: OptionButton = $Panel/Margin/VBox/ThemeRow/ThemeOption
@onready var _language_label: Label = $Panel/Margin/VBox/LanguageRow/LanguageLabel
@onready var _language_option: OptionButton = $Panel/Margin/VBox/LanguageRow/LanguageOption
@onready var _btn_back: Button = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	visible = false
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_music_toggle.toggled.connect(_on_music_toggle_changed)
	_theme_option.item_selected.connect(_on_theme_option_selected)
	_language_option.item_selected.connect(_on_language_option_selected)
	LocaleAware.bind(self, _refresh_locale)


func open() -> void:
	_load_from_config()
	_refresh_locale()
	show()
	call_deferred("_btn_back.grab_focus")


func close() -> void:
	hide()
	closed.emit()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.SETTINGS_TITLE)
	_sfx_label.text = tr(MenuKeys.SETTINGS_SFX_VOLUME)
	_music_label.text = tr(MenuKeys.SETTINGS_MUSIC_VOLUME)
	_music_toggle.text = tr(MenuKeys.SETTINGS_MUSIC_ENABLED)
	_theme_label.text = tr(MenuKeys.SETTINGS_TABLE_THEME)
	_language_label.text = tr(MenuKeys.SETTINGS_LANGUAGE)
	_btn_back.text = tr(CommonKeys.BACK)
	_build_theme_options()
	_build_language_options()
	_select_language_option(ConfigService.get_language())
	_set_slider_label(_sfx_value_label, _sfx_slider.value)
	_set_slider_label(_music_value_label, _music_slider.value)


func _build_theme_options() -> void:
	var selected_index: int = _theme_option.selected
	_theme_option.clear()
	for theme_id in TableThemePaths.THEME_IDS:
		_theme_option.add_item(TableThemePaths.get_label(theme_id), _theme_option.item_count)
	if selected_index >= 0 and selected_index < _theme_option.item_count:
		_theme_option.select(selected_index)
	else:
		_select_theme_option(ConfigService.get_table_theme())


func _build_language_options() -> void:
	var selected_language: String = ConfigService.get_language()
	_language_option.clear()
	_language_option.add_item(tr(MenuKeys.SETTINGS_LANG_FR), 0)
	_language_option.set_item_metadata(0, "fr")
	_language_option.add_item(tr(MenuKeys.SETTINGS_LANG_EN), 1)
	_language_option.set_item_metadata(1, "en")
	_select_language_option(selected_language)


func _load_from_config() -> void:
	_sfx_slider.set_value_no_signal(ConfigService.get_volume() * 100.0)
	_music_slider.set_value_no_signal(ConfigService.get_music_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(ConfigService.get_music_enabled())
	_select_theme_option(ConfigService.get_table_theme())
	_select_language_option(ConfigService.get_language())


func _select_theme_option(theme_id: StringName) -> void:
	var normalized: StringName = TableThemePaths.normalize_theme_id(theme_id)
	for index in _theme_option.item_count:
		if TableThemePaths.THEME_IDS[index] == normalized:
			_theme_option.select(index)
			return
	_theme_option.select(0)


func _select_language_option(language: String) -> void:
	var normalized: String = ConfigService.normalize_language(language)
	_language_option.set_block_signals(true)
	for index in _language_option.item_count:
		if _language_option.get_item_metadata(index) == normalized:
			_language_option.select(index)
			_language_option.set_block_signals(false)
			return
	_language_option.select(0)
	_language_option.set_block_signals(false)


func _set_slider_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(round(value))


func _on_sfx_slider_changed(value: float) -> void:
	ConfigService.set_volume(value / 100.0)
	_set_slider_label(_sfx_value_label, value)


func _on_music_slider_changed(value: float) -> void:
	ConfigService.set_music_volume(value / 100.0)
	AudioService.refresh_music_volume()
	_set_slider_label(_music_value_label, value)


func _on_music_toggle_changed(enabled: bool) -> void:
	AudioService.set_music_enabled(enabled)


func _on_theme_option_selected(index: int) -> void:
	if index < 0 or index >= TableThemePaths.THEME_IDS.size():
		return
	ConfigService.set_table_theme(TableThemePaths.THEME_IDS[index])


func _on_language_option_selected(index: int) -> void:
	var language: Variant = _language_option.get_item_metadata(index)
	if language is String and language != ConfigService.get_language():
		ConfigService.set_language(language)


func _on_btn_back_pressed() -> void:
	close()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
