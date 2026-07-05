extends Control
## Écran Configuration : volumes, musique, thème de table et langue.
## Overlay modal du menu principal (voir `main_menu.gd`).

signal closed

@onready var _sfx_slider: HSlider = $Panel/Margin/VBox/SfxRow/SfxSlider
@onready var _sfx_value_label: Label = $Panel/Margin/VBox/SfxRow/SfxValueLabel
@onready var _music_slider: HSlider = $Panel/Margin/VBox/MusicRow/MusicSlider
@onready var _music_value_label: Label = $Panel/Margin/VBox/MusicRow/MusicValueLabel
@onready var _music_toggle: CheckButton = $Panel/Margin/VBox/MusicToggle
@onready var _theme_option: OptionButton = $Panel/Margin/VBox/ThemeRow/ThemeOption
@onready var _language_option: OptionButton = $Panel/Margin/VBox/LanguageRow/LanguageOption


func _ready() -> void:
	visible = false
	_build_theme_options()
	_build_language_options()
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_music_toggle.toggled.connect(_on_music_toggle_changed)
	_theme_option.item_selected.connect(_on_theme_option_selected)
	_language_option.item_selected.connect(_on_language_option_selected)


func open() -> void:
	_load_from_config()
	show()


func close() -> void:
	hide()
	closed.emit()


func _build_theme_options() -> void:
	_theme_option.clear()
	for theme_id in TableThemePaths.THEME_IDS:
		_theme_option.add_item(TableThemePaths.get_label(theme_id), _theme_option.item_count)


func _build_language_options() -> void:
	_language_option.clear()
	_language_option.add_item("Français", 0)
	_language_option.set_item_metadata(0, "fr")


func _load_from_config() -> void:
	_sfx_slider.set_value_no_signal(ConfigService.get_volume() * 100.0)
	_music_slider.set_value_no_signal(ConfigService.get_music_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(ConfigService.get_music_enabled())
	_set_slider_label(_sfx_value_label, _sfx_slider.value)
	_set_slider_label(_music_value_label, _music_slider.value)
	_select_theme_option(ConfigService.get_table_theme())
	_language_option.select(0)


func _select_theme_option(theme_id: StringName) -> void:
	var normalized: StringName = TableThemePaths.normalize_theme_id(theme_id)
	for index in _theme_option.item_count:
		if TableThemePaths.THEME_IDS[index] == normalized:
			_theme_option.select(index)
			return
	_theme_option.select(0)


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
	if language is String:
		ConfigService.set_language(language)


func _on_btn_back_pressed() -> void:
	close()
