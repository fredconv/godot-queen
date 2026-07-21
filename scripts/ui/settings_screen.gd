extends ModalOverlayScreen
## Écran Configuration : volumes, musique, thème de table et langue.
## Overlay modal du menu principal (voir `main_menu.gd`).

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
@onready var _display_name_label: Label = $Panel/Margin/VBox/DisplayNameRow/DisplayNameLabel
@onready var _display_name_edit: LineEdit = $Panel/Margin/VBox/DisplayNameRow/DisplayNameEdit
@onready var _btn_reset_stats: NinePatchButton = $Panel/Margin/VBox/BtnResetStats
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack

var _section_audio: Label
var _section_display: Label
var _section_profile: Label
var _section_data: Label
var _emotes_toggle: CheckButton


func _ready() -> void:
	super._ready()
	_ensure_sections()
	_ensure_emotes_toggle()
	_ensure_title_emblem()
	_apply_control_variations()
	_apply_settings_button_chrome()
	_btn_back.set_button_icon(UiIconCatalog.texture(UiIconCatalog.Icon.EXIT), 30)
	_language_option.add_theme_constant_override("icon_max_width", 24)
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_music_toggle.toggled.connect(_on_music_toggle_changed)
	_theme_option.item_selected.connect(_on_theme_option_selected)
	_language_option.item_selected.connect(_on_language_option_selected)
	var focus_chain: Array = [
		_sfx_slider,
		_music_slider,
		_music_toggle,
	]
	if _emotes_toggle != null:
		focus_chain.append(_emotes_toggle)
	focus_chain.append_array([
		_theme_option,
		_language_option,
		_display_name_edit,
		_btn_reset_stats,
		_btn_back,
	])
	UiFocusNav.chain_vertical(focus_chain)


func _ensure_title_emblem() -> void:
	var vbox := $Panel/Margin/VBox as VBoxContainer
	if vbox.get_node_or_null("SettingsEmblem") != null:
		return
	var emblem := UiIconCatalog.make_icon_rect(UiIconCatalog.Icon.SETTINGS, Vector2i(52, 52))
	emblem.name = "SettingsEmblem"
	vbox.add_child(emblem)
	vbox.move_child(emblem, _title_label.get_index())
	LocaleAware.bind(self, _refresh_locale)


func _ensure_emotes_toggle() -> void:
	var vbox: VBoxContainer = $Panel/Margin/VBox as VBoxContainer
	if vbox == null:
		return
	var existing: Node = vbox.get_node_or_null("EmotesToggle")
	if existing is CheckButton:
		_emotes_toggle = existing as CheckButton
	else:
		_emotes_toggle = CheckButton.new()
		_emotes_toggle.name = "EmotesToggle"
		vbox.add_child(_emotes_toggle)
		vbox.move_child(_emotes_toggle, _music_toggle.get_index() + 1)
	UiThemeCatalog.apply_variation(_emotes_toggle, UiThemeCatalog.V_PIXEL_TOGGLE)
	if not _emotes_toggle.toggled.is_connected(_on_emotes_toggle_changed):
		_emotes_toggle.toggled.connect(_on_emotes_toggle_changed)


func _apply_settings_button_chrome() -> void:
	if _btn_reset_stats != null:
		_btn_reset_stats.ensure_opaque_background(
			Color(0.18, 0.08, 0.08, 1.0),
			UiPalette.DANGER_BORDER,
			0
		)
	if _btn_back != null:
		_btn_back.ensure_opaque_background(Color(0.05, 0.16, 0.09, 1.0), UiPalette.GOLD, 0)


func _ensure_sections() -> void:
	var vbox: VBoxContainer = $Panel/Margin/VBox as VBoxContainer
	if vbox == null:
		return
	_section_audio = _insert_section(vbox, $Panel/Margin/VBox/SfxRow, "SectionAudio")
	_section_display = _insert_section(vbox, $Panel/Margin/VBox/ThemeRow, "SectionDisplay")
	_section_profile = _insert_section(vbox, $Panel/Margin/VBox/DisplayNameRow, "SectionProfile")
	_section_data = _insert_section(vbox, _btn_reset_stats, "SectionData")
	var panel: Control = $Panel as Control
	if panel != null:
		panel.offset_top = -300.0
		panel.offset_bottom = 300.0


func _insert_section(vbox: VBoxContainer, before: Node, node_name: String) -> Label:
	var existing: Node = vbox.get_node_or_null(node_name)
	if existing is Label:
		return existing as Label
	var label := Label.new()
	label.name = node_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	UiThemeCatalog.apply_variation(label, UiThemeCatalog.V_SECTION_TITLE)
	label.add_theme_font_size_override("font_size", UiPalette.MENU_SUBTITLE_SIZE)
	label.add_theme_color_override("font_color", UiPalette.GOLD)
	vbox.add_child(label)
	vbox.move_child(label, before.get_index())
	return label


func _apply_control_variations() -> void:
	UiThemeCatalog.apply_variation(_title_label, UiThemeCatalog.V_TITLE_LABEL)
	UiThemeCatalog.apply_variation(_sfx_slider, UiThemeCatalog.V_PIXEL_SLIDER)
	UiThemeCatalog.apply_variation(_music_slider, UiThemeCatalog.V_PIXEL_SLIDER)
	UiThemeCatalog.apply_variation(_music_toggle, UiThemeCatalog.V_PIXEL_TOGGLE)
	UiThemeCatalog.apply_variation(_theme_option, UiThemeCatalog.V_PIXEL_OPTION_BUTTON)
	UiThemeCatalog.apply_variation(_language_option, UiThemeCatalog.V_PIXEL_OPTION_BUTTON)
	UiThemeCatalog.apply_variation(_display_name_edit, UiThemeCatalog.V_PIXEL_LINE_EDIT)
	for row_label: Label in [_sfx_label, _music_label, _theme_label, _language_label, _display_name_label]:
		UiThemeCatalog.apply_variation(row_label, UiThemeCatalog.V_BODY_LABEL)
		row_label.custom_minimum_size.x = 128.0
	for value_label: Label in [_sfx_value_label, _music_value_label]:
		UiThemeCatalog.apply_variation(value_label, UiThemeCatalog.V_MUTED_LABEL)


func _before_open() -> void:
	# Peupler les OptionButton avant toute sélection (évite item_count = 0).
	_refresh_locale()
	_load_from_config()


func _on_overlay_opened() -> void:
	UiFocusNav.grab_first([
		_sfx_slider,
		_music_slider,
		_music_toggle,
		_theme_option,
		_language_option,
		_display_name_edit,
		_btn_reset_stats,
		_btn_back,
	])


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.SETTINGS_TITLE)
	_sfx_label.text = tr(MenuKeys.SETTINGS_SFX_VOLUME)
	_music_label.text = tr(MenuKeys.SETTINGS_MUSIC_VOLUME)
	_music_toggle.text = tr(MenuKeys.SETTINGS_MUSIC_ENABLED)
	if _emotes_toggle != null:
		_emotes_toggle.text = tr(MenuKeys.SETTINGS_EMOTES_ENABLED)
	_theme_label.text = tr(MenuKeys.SETTINGS_TABLE_THEME)
	_language_label.text = tr(MenuKeys.SETTINGS_LANGUAGE)
	_display_name_label.text = tr(MenuKeys.SETTINGS_DISPLAY_NAME)
	_btn_reset_stats.set_button_text(tr(MenuKeys.SETTINGS_RESET_STATS))
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	var settings_buttons: Array = [_btn_reset_stats, _btn_back]
	NinePatchButton.uniform_fit_group(settings_buttons)
	NinePatchButton.sync_centered_panel_half_width($Panel as Control, settings_buttons, 64.0, 280.0)
	if _section_audio != null:
		_section_audio.text = tr(MenuKeys.SETTINGS_SECTION_AUDIO)
	if _section_display != null:
		_section_display.text = tr(MenuKeys.SETTINGS_SECTION_DISPLAY)
	if _section_profile != null:
		_section_profile.text = tr(MenuKeys.SETTINGS_SECTION_PROFILE)
	if _section_data != null:
		_section_data.text = tr(MenuKeys.SETTINGS_SECTION_DATA)
	_build_theme_options()
	_build_language_options()
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
	for index in LocaleCatalog.LOCALES.size():
		var locale: String = LocaleCatalog.LOCALES[index]
		_language_option.add_icon_item(
			LocaleFlagIcons.get_icon(locale),
			tr(LocaleCatalog.label_key_for(locale)),
			index
		)
		_language_option.set_item_metadata(index, locale)
	_select_language_option(selected_language)


func _load_from_config() -> void:
	_sfx_slider.set_value_no_signal(ConfigService.get_volume() * 100.0)
	_music_slider.set_value_no_signal(ConfigService.get_music_volume() * 100.0)
	_music_toggle.set_pressed_no_signal(ConfigService.get_music_enabled())
	if _emotes_toggle != null:
		_emotes_toggle.set_pressed_no_signal(ConfigService.get_emotes_enabled())
	_select_theme_option(ConfigService.get_table_theme())
	_select_language_option(ConfigService.get_language())
	_display_name_edit.text = PlayerProfileService.get_display_name()


func _select_theme_option(theme_id: StringName) -> void:
	if _theme_option.item_count <= 0:
		return
	var normalized: StringName = TableThemePaths.normalize_theme_id(theme_id)
	for index in _theme_option.item_count:
		if TableThemePaths.THEME_IDS[index] == normalized:
			_theme_option.select(index)
			return
	_theme_option.select(0)


func _select_language_option(language: String) -> void:
	if _language_option.item_count <= 0:
		return
	var normalized: String = ConfigService.normalize_language_value(language)
	_language_option.set_block_signals(true)
	for index in _language_option.item_count:
		if _language_option.get_item_metadata(index) == normalized:
			_language_option.select(index)
			_language_option.set_block_signals(false)
			return
	_language_option.select(0)
	_language_option.set_block_signals(false)


func _set_slider_label(label: Label, value: float) -> void:
	label.text = tr(CommonKeys.PERCENT) % int(round(value))


func _on_sfx_slider_changed(value: float) -> void:
	ConfigService.set_volume(value / 100.0)
	_set_slider_label(_sfx_value_label, value)


func _on_music_slider_changed(value: float) -> void:
	ConfigService.set_music_volume(value / 100.0)
	AudioService.refresh_music_volume()
	_set_slider_label(_music_value_label, value)


func _on_music_toggle_changed(enabled: bool) -> void:
	AudioService.set_music_enabled(enabled)


func _on_emotes_toggle_changed(enabled: bool) -> void:
	ConfigService.set_emotes_enabled(enabled)


func _on_theme_option_selected(index: int) -> void:
	if index < 0 or index >= TableThemePaths.THEME_IDS.size():
		return
	ConfigService.set_table_theme(TableThemePaths.THEME_IDS[index])


func _on_language_option_selected(index: int) -> void:
	var language: Variant = _language_option.get_item_metadata(index)
	if language is String and language != ConfigService.get_language():
		ConfigService.set_language(language)


func _on_btn_reset_stats_pressed() -> void:
	StatsService.reset_stats()


func _on_btn_back_pressed() -> void:
	_save_display_name()
	close()


func _save_display_name() -> void:
	PlayerProfileService.set_display_name(_display_name_edit.text)
