class_name LocaleFonts
extends RefCounted
## Police UI selon la locale : Press Start 2P par défaut, repli système CJK pour le chinois.


const UI_FONT_PATH: String = "res://assets/fonts/PressStart2P-Regular.ttf"
const PIXEL_THEME_PATH: String = "res://resources/themes/pixel_theme.tres"

const DEFAULT_FONT_SIZE: int = 11
const SEAT_FONT_SIZE: int = 8
const MENU_TURN_FONT_SIZE: int = 10
const MENU_SCORE_FONT_SIZE: int = 8
const MENU_BUTTON_FONT_SIZE: int = 8
const LEAD_SUIT_FONT_SIZE: int = 10


static func apply_for_locale(locale: String) -> void:
	var ui_font_file: FontFile = load(UI_FONT_PATH) as FontFile
	if ui_font_file == null:
		push_warning("LocaleFonts: police UI introuvable (%s)" % UI_FONT_PATH)
		return
	var ui_font: Font = _build_ui_font(ui_font_file, LocaleCatalog.normalize(locale))
	ThemeDB.fallback_font = ui_font
	ThemeDB.fallback_font_size = DEFAULT_FONT_SIZE
	var theme: Theme = load(PIXEL_THEME_PATH) as Theme
	if theme != null:
		theme.default_font = ui_font


static func _build_ui_font(ui_font_file: FontFile, locale: String) -> Font:
	if locale != "zh":
		return ui_font_file
	var variation := FontVariation.new()
	variation.base_font = ui_font_file
	var cjk_fallback := SystemFont.new()
	cjk_fallback.font_names = _cjk_system_font_names()
	cjk_fallback.font_weight = 400
	var fallbacks: Array[Font] = [cjk_fallback]
	variation.fallbacks = fallbacks
	return variation


static func _cjk_system_font_names() -> PackedStringArray:
	return PackedStringArray([
		"Microsoft YaHei UI",
		"Microsoft YaHei",
		"PingFang SC",
		"Noto Sans CJK SC",
		"Source Han Sans SC",
		"sans-serif",
	])
