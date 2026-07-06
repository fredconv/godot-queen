class_name LocaleFonts
extends RefCounted
## Police UI selon la locale : Pixelify Sans par défaut, repli système CJK pour le chinois.


const PIXEL_FONT_PATH: String = "res://assets/fonts/PixelifySans-VariableFont_wght.ttf"

const CJK_SYSTEM_FONT_NAMES: PackedStringArray = PackedStringArray([
	"Microsoft YaHei UI",
	"Microsoft YaHei",
	"PingFang SC",
	"Noto Sans CJK SC",
	"Source Han Sans SC",
	"sans-serif",
])


static func apply_for_locale(locale: String) -> void:
	var pixel_font: FontFile = load(PIXEL_FONT_PATH) as FontFile
	if pixel_font == null:
		push_warning("LocaleFonts: police pixel introuvable (%s)" % PIXEL_FONT_PATH)
		return
	ThemeDB.fallback_base_font = _build_ui_font(pixel_font, LocaleCatalog.normalize(locale))
	ThemeDB.fallback_font_size = 16


static func _build_ui_font(pixel_font: FontFile, locale: String) -> Font:
	if locale != "zh":
		return pixel_font
	var variation := FontVariation.new()
	variation.base_font = pixel_font
	var cjk_fallback := SystemFont.new()
	cjk_fallback.font_names = CJK_SYSTEM_FONT_NAMES
	cjk_fallback.font_weight = 400
	variation.fallbacks = Array[Font]([cjk_fallback])
	return variation
