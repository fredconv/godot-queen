class_name UiThemeCatalog
extends RefCounted
## Catalogue Theme IDEA-00021 — type variations pixel (StyleBoxFlat, coins 0).
## Enrichit `pixel_theme.tres` en mémoire (pas de PNG). Appelé depuis LocaleFonts.


const V_PRIMARY_BUTTON: StringName = &"PrimaryButton"
const V_SECONDARY_BUTTON: StringName = &"SecondaryButton"
const V_DANGER_BUTTON: StringName = &"DangerButton"
const V_SMALL_HUD_BUTTON: StringName = &"SmallHudButton"
const V_PIXEL_PANEL: StringName = &"PixelPanel"
const V_MODAL_PANEL: StringName = &"ModalPanel"
const V_SECTION_PANEL: StringName = &"SectionPanel"
const V_TITLE_LABEL: StringName = &"TitleLabel"
const V_SECTION_TITLE: StringName = &"SectionTitle"
const V_BODY_LABEL: StringName = &"BodyLabel"
const V_MUTED_LABEL: StringName = &"MutedLabel"
const V_PIXEL_LINE_EDIT: StringName = &"PixelLineEdit"
const V_PIXEL_OPTION_BUTTON: StringName = &"PixelOptionButton"
const V_PIXEL_SLIDER: StringName = &"PixelSlider"
const V_PIXEL_TOGGLE: StringName = &"PixelToggle"
const V_SCORE_PANEL: StringName = &"ScorePanel"
const V_NOTIFICATION_PANEL: StringName = &"NotificationPanel"

const _ENRICHED_META: StringName = &"_ddp_theme_enriched"


static func enrich_theme(theme: Theme) -> void:
	if theme == null:
		return
	if theme.has_meta(_ENRICHED_META):
		return
	_ensure_base_button_focus_gold(theme)
	_register_button_variation(theme, V_PRIMARY_BUTTON, UiPalette.BTN_BG, UiPalette.BTN_BG_HOVER, UiPalette.BTN_BG_PRESSED, UiPalette.GOLD, 2, Vector4(12, 10, 12, 10))
	_register_button_variation(theme, V_SECONDARY_BUTTON, UiPalette.ANTHRACITE, UiPalette.BTN_BG_HOVER, UiPalette.BTN_BG_PRESSED, UiPalette.GOLD, 2, Vector4(12, 10, 12, 10))
	_register_button_variation(theme, V_DANGER_BUTTON, UiPalette.DANGER_BG, UiPalette.DANGER_BG_HOVER, UiPalette.DANGER_BG_PRESSED, UiPalette.DANGER_BORDER, 2, Vector4(12, 10, 12, 10))
	_register_button_variation(theme, V_SMALL_HUD_BUTTON, UiPalette.BTN_BG, UiPalette.BTN_BG_HOVER, UiPalette.BTN_BG_PRESSED, UiPalette.GOLD, 2, Vector4(8, 4, 8, 4))
	_register_panel_variation(theme, V_PIXEL_PANEL, UiStyleFactory.pixel_overlay_panel_style())
	_register_panel_variation(theme, V_MODAL_PANEL, UiStyleFactory.pixel_overlay_panel_style(Vector4(16, 14, 16, 14)))
	_register_panel_variation(theme, V_SECTION_PANEL, UiStyleFactory.pixel_compact_panel_style(Vector4(10, 8, 10, 8), UiPalette.SECTION_BG))
	_register_panel_variation(theme, V_SCORE_PANEL, UiStyleFactory.pixel_banner_panel_style(Vector4(12, 10, 12, 10), 2, 0.94))
	_register_panel_variation(theme, V_NOTIFICATION_PANEL, UiStyleFactory.pixel_banner_panel_style(Vector4(20, 12, 20, 12), 2, 0.9))
	_register_label_variation(theme, V_TITLE_LABEL, UiPalette.GOLD_BRIGHT, UiPalette.MENU_TITLE_SIZE)
	_register_label_variation(theme, V_SECTION_TITLE, UiPalette.GOLD, UiPalette.MENU_SUBTITLE_SIZE)
	_register_label_variation(theme, V_BODY_LABEL, UiPalette.CREAM, UiPalette.MENU_BUTTON_SIZE)
	_register_label_variation(theme, V_MUTED_LABEL, UiPalette.MUTED, UiPalette.MENU_SUBTITLE_SIZE)
	_register_line_edit_variation(theme)
	_register_option_button_variation(theme)
	_register_slider_variation(theme)
	_register_toggle_variation(theme)
	theme.set_meta(_ENRICHED_META, true)


static func apply_variation(control: Control, variation: StringName) -> void:
	if control == null:
		return
	control.theme_type_variation = String(variation)


static func ensure_project_theme_enriched() -> Theme:
	var theme: Theme = load(LocaleFonts.PIXEL_THEME_PATH) as Theme
	enrich_theme(theme)
	return theme


static func _ensure_base_button_focus_gold(theme: Theme) -> void:
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.set_border_width_all(2)
	focus.border_color = UiPalette.GOLD_BRIGHT
	focus.set_corner_radius_all(0)
	focus.expand_margin_left = 2.0
	focus.expand_margin_top = 2.0
	focus.expand_margin_right = 2.0
	focus.expand_margin_bottom = 2.0
	theme.set_stylebox("focus", &"Button", focus)
	theme.set_stylebox("focus", &"OptionButton", focus)


static func _register_button_variation(
	theme: Theme,
	variation: StringName,
	bg_normal: Color,
	bg_hover: Color,
	bg_pressed: Color,
	border: Color,
	border_width: int,
	margins: Vector4
) -> void:
	theme.add_type(variation)
	theme.set_type_variation(variation, &"Button")
	theme.set_stylebox("normal", variation, _button_style(bg_normal, border, border_width, margins, false))
	theme.set_stylebox("hover", variation, _button_style(bg_hover, UiPalette.GOLD_BRIGHT, border_width, margins, false))
	theme.set_stylebox("pressed", variation, _button_style(bg_pressed, border, border_width, margins, true))
	theme.set_stylebox("disabled", variation, _button_style(UiPalette.DISABLED_BG, UiPalette.DISABLED_BORDER, 1, margins, false))
	theme.set_stylebox("focus", variation, _focus_style())
	theme.set_color("font_color", variation, UiPalette.CREAM)
	theme.set_color("font_hover_color", variation, UiPalette.GOLD_BRIGHT)
	theme.set_color("font_pressed_color", variation, UiPalette.GOLD)
	theme.set_color("font_focus_color", variation, UiPalette.GOLD_BRIGHT)
	theme.set_color("font_disabled_color", variation, UiPalette.MUTED)
	theme.set_font_size("font_size", variation, UiPalette.MENU_BUTTON_SIZE)


static func _register_panel_variation(theme: Theme, variation: StringName, style: StyleBoxFlat) -> void:
	theme.add_type(variation)
	theme.set_type_variation(variation, &"PanelContainer")
	theme.set_stylebox("panel", variation, style)
	## Aussi pour Panel nu.
	var panel_type: StringName = StringName(String(variation) + "Raw")
	theme.add_type(panel_type)
	theme.set_type_variation(panel_type, &"Panel")
	theme.set_stylebox("panel", panel_type, style)


static func _register_label_variation(theme: Theme, variation: StringName, color: Color, font_size: int) -> void:
	theme.add_type(variation)
	theme.set_type_variation(variation, &"Label")
	theme.set_color("font_color", variation, color)
	theme.set_font_size("font_size", variation, font_size)


static func _register_line_edit_variation(theme: Theme) -> void:
	theme.add_type(V_PIXEL_LINE_EDIT)
	theme.set_type_variation(V_PIXEL_LINE_EDIT, &"LineEdit")
	theme.set_stylebox("normal", V_PIXEL_LINE_EDIT, _field_style(false))
	theme.set_stylebox("focus", V_PIXEL_LINE_EDIT, _field_style(true))
	theme.set_stylebox("read_only", V_PIXEL_LINE_EDIT, _field_style(false))
	theme.set_color("font_color", V_PIXEL_LINE_EDIT, UiPalette.CREAM)
	theme.set_color("font_placeholder_color", V_PIXEL_LINE_EDIT, UiPalette.MUTED)
	theme.set_font_size("font_size", V_PIXEL_LINE_EDIT, UiPalette.MENU_BUTTON_SIZE)


static func _register_option_button_variation(theme: Theme) -> void:
	theme.add_type(V_PIXEL_OPTION_BUTTON)
	theme.set_type_variation(V_PIXEL_OPTION_BUTTON, &"OptionButton")
	theme.set_stylebox("normal", V_PIXEL_OPTION_BUTTON, _button_style(UiPalette.ANTHRACITE, UiPalette.GOLD, 2, Vector4(10, 8, 10, 8), false))
	theme.set_stylebox("hover", V_PIXEL_OPTION_BUTTON, _button_style(UiPalette.BTN_BG_HOVER, UiPalette.GOLD_BRIGHT, 2, Vector4(10, 8, 10, 8), false))
	theme.set_stylebox("pressed", V_PIXEL_OPTION_BUTTON, _button_style(UiPalette.BTN_BG_PRESSED, UiPalette.GOLD, 2, Vector4(10, 8, 10, 8), true))
	theme.set_stylebox("disabled", V_PIXEL_OPTION_BUTTON, _button_style(UiPalette.DISABLED_BG, UiPalette.DISABLED_BORDER, 1, Vector4(10, 8, 10, 8), false))
	theme.set_stylebox("focus", V_PIXEL_OPTION_BUTTON, _focus_style())
	theme.set_color("font_color", V_PIXEL_OPTION_BUTTON, UiPalette.CREAM)
	theme.set_color("font_hover_color", V_PIXEL_OPTION_BUTTON, UiPalette.GOLD_BRIGHT)
	theme.set_font_size("font_size", V_PIXEL_OPTION_BUTTON, UiPalette.MENU_BUTTON_SIZE)


static func _register_slider_variation(theme: Theme) -> void:
	theme.add_type(V_PIXEL_SLIDER)
	theme.set_type_variation(V_PIXEL_SLIDER, &"HSlider")
	var track := StyleBoxFlat.new()
	track.bg_color = UiPalette.ANTHRACITE
	track.border_color = UiPalette.GOLD
	track.set_border_width_all(1)
	track.set_corner_radius_all(0)
	track.content_margin_left = 4
	track.content_margin_top = 4
	track.content_margin_right = 4
	track.content_margin_bottom = 4
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.55)
	fill.set_corner_radius_all(0)
	theme.set_stylebox("slider", V_PIXEL_SLIDER, track)
	theme.set_stylebox("grabber_area", V_PIXEL_SLIDER, fill)
	theme.set_stylebox("grabber_area_highlight", V_PIXEL_SLIDER, fill)


static func _register_toggle_variation(theme: Theme) -> void:
	theme.add_type(V_PIXEL_TOGGLE)
	theme.set_type_variation(V_PIXEL_TOGGLE, &"CheckButton")
	theme.set_color("font_color", V_PIXEL_TOGGLE, UiPalette.CREAM)
	theme.set_color("font_hover_color", V_PIXEL_TOGGLE, UiPalette.GOLD_BRIGHT)
	theme.set_color("font_pressed_color", V_PIXEL_TOGGLE, UiPalette.GOLD)
	theme.set_font_size("font_size", V_PIXEL_TOGGLE, UiPalette.MENU_BUTTON_SIZE)


static func _button_style(
	bg: Color,
	border: Color,
	border_width: int,
	margins: Vector4,
	pressed: bool
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(0)
	style.content_margin_left = margins.x
	style.content_margin_top = margins.y
	style.content_margin_right = margins.z
	style.content_margin_bottom = margins.w
	style.shadow_color = Color(0, 0, 0, 0.45 if not pressed else 0.2)
	style.shadow_size = 2 if not pressed else 1
	style.shadow_offset = Vector2(0, 2 if not pressed else 1)
	return style


static func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = UiPalette.GOLD_BRIGHT
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.expand_margin_left = 2.0
	style.expand_margin_top = 2.0
	style.expand_margin_right = 2.0
	style.expand_margin_bottom = 2.0
	return style


static func _field_style(focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiPalette.ANTHRACITE
	style.border_color = UiPalette.GOLD_BRIGHT if focused else Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style
