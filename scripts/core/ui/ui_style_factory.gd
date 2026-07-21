class_name UiStyleFactory
extends RefCounted
## Fabrique de styles UIBundleFree : AtlasTexture (region) + 9-slice sans déformation d'icônes.


static func atlas_region(sheet_path: String, region: Rect2i) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(sheet_path) as Texture2D
	atlas.region = region
	return atlas


static func texture_style(
	texture_path: String,
	content_margin: Vector4 = Vector4(8, 6, 8, 6),
	texture_margin: Vector4 = Vector4(4, 4, 4, 4)
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(texture_path) as Texture2D
	style.content_margin_left = content_margin.x
	style.content_margin_top = content_margin.y
	style.content_margin_right = content_margin.z
	style.content_margin_bottom = content_margin.w
	style.texture_margin_left = texture_margin.x
	style.texture_margin_top = texture_margin.y
	style.texture_margin_right = texture_margin.z
	style.texture_margin_bottom = texture_margin.w
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return style


## Fond bois horizontal (sans icône) : seul le centre s'étire en 9-slice.
static func medieval_menu_button_normal() -> StyleBoxTexture:
	return texture_style(
		UiBundleCatalog.MEDIEVAL_BTN_PLANK_NORMAL,
		Vector4(10, 4, 10, 4),
		Vector4(6, 4, 6, 4)
	)


static func medieval_menu_button_pressed() -> StyleBoxTexture:
	return texture_style(
		UiBundleCatalog.MEDIEVAL_BTN_PLANK_PRESSED,
		Vector4(10, 4, 10, 4),
		Vector4(6, 4, 6, 4)
	)


static func medieval_menu_button_hover() -> StyleBoxTexture:
	var style := medieval_menu_button_normal()
	style.modulate_color = Color(1.1, 1.06, 1.0, 1.0)
	return style


static func medieval_icon_button_style() -> StyleBoxTexture:
	return texture_style(
		UiBundleCatalog.MEDIEVAL_BTN_PLANK_NORMAL,
		Vector4(4, 4, 4, 4),
		Vector4(4, 4, 4, 4)
	)


static func configure_medieval_icon_button(
	btn: Button,
	region_key: StringName,
	min_size: Vector2 = Vector2(36, 32)
) -> void:
	var region: Rect2i = UiBundleCatalog.REGIONS_MEDIEVAL[region_key]
	btn.custom_minimum_size = min_size
	btn.text = ""
	btn.expand_icon = false
	btn.icon = atlas_region(UiBundleCatalog.MEDIEVAL_SHEET, region)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_theme_constant_override("icon_max_width", region.size.x)
	btn.add_theme_stylebox_override("normal", medieval_icon_button_style())
	btn.add_theme_stylebox_override("hover", medieval_menu_button_hover())
	btn.add_theme_stylebox_override("pressed", medieval_menu_button_pressed())
	btn.add_theme_stylebox_override("focus", _medieval_focus_outline())


## Icône legacy (feuille 8bit) : region + zoom max uniforme.
static func configure_legacy_icon_button(
	btn: Button,
	region: Rect2i,
	display_size: int = 28
) -> void:
	btn.text = ""
	btn.expand_icon = false
	btn.icon = atlas_region(UiBundleCatalog.LEGACY_UI_SHEET, region)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.add_theme_constant_override("icon_max_width", display_size)
	btn.add_theme_stylebox_override("normal", medieval_icon_button_style())
	btn.add_theme_stylebox_override("hover", medieval_menu_button_hover())
	btn.add_theme_stylebox_override("pressed", medieval_menu_button_pressed())
	btn.add_theme_stylebox_override("focus", _medieval_focus_outline())


static func apply_medieval_menu_button_theme(theme: Theme) -> void:
	theme.set_stylebox("normal", &"Button", medieval_menu_button_normal())
	theme.set_stylebox("hover", &"Button", medieval_menu_button_hover())
	theme.set_stylebox("pressed", &"Button", medieval_menu_button_pressed())
	theme.set_stylebox("focus", &"Button", _medieval_focus_outline())
	theme.set_color("font_color", &"Button", UiPalette.CREAM)
	theme.set_color("font_hover_color", &"Button", UiPalette.GOLD_BRIGHT)
	theme.set_color("font_pressed_color", &"Button", UiPalette.GOLD)
	theme.set_font_size("font_size", &"Button", LocaleFonts.MENU_BUTTON_FONT_SIZE)


static func _medieval_focus_outline() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.95, 0.82, 0.45, 1.0)
	style.expand_margin_left = 2.0
	style.expand_margin_top = 2.0
	style.expand_margin_right = 2.0
	style.expand_margin_bottom = 2.0
	return style


## Boutons barre HUD (top bar) — StyleBoxFlat pixel (coins 0, pas de soft UI).
static func pixel_bar_button_style(
	bg_color: Color,
	border_color: Color,
	border_width: int = 2
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(0)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


static func pixel_bar_focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiPalette.BTN_BG_HOVER
	style.border_color = UiPalette.GOLD_BRIGHT
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	style.expand_margin_left = 1.0
	style.expand_margin_top = 1.0
	style.expand_margin_right = 1.0
	style.expand_margin_bottom = 1.0
	return style


## Panneaux / banners table — StyleBoxFlat pixel (coins 0, bordure or).
static func pixel_banner_panel_style(
	content_margin: Vector4 = Vector4(24, 16, 24, 16),
	border_width: int = 3,
	bg_alpha: float = 0.94
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(UiPalette.PANEL_BG.r, UiPalette.PANEL_BG.g, UiPalette.PANEL_BG.b, bg_alpha)
	style.border_color = UiPalette.PANEL_BORDER
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(0)
	style.content_margin_left = content_margin.x
	style.content_margin_top = content_margin.y
	style.content_margin_right = content_margin.z
	style.content_margin_bottom = content_margin.w
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	return style


static func pixel_overlay_panel_style(
	content_margin: Vector4 = Vector4(16, 14, 16, 14)
) -> StyleBoxFlat:
	## Modales : cadre or franc + ombre nette (lisible vs splash).
	var style := pixel_banner_panel_style(content_margin, 3, 0.97)
	style.bg_color = Color(0.08, 0.09, 0.12, 0.97)
	style.border_color = UiPalette.GOLD_BRIGHT
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 5)
	style.shadow_color = Color(0, 0, 0, 0.65)
	return style


static func pixel_compact_panel_style(
	content_margin: Vector4 = Vector4(12, 8, 12, 8),
	bg_color: Color = Color(0.05, 0.06, 0.08, 0.82)
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = UiPalette.PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.content_margin_left = content_margin.x
	style.content_margin_top = content_margin.y
	style.content_margin_right = content_margin.z
	style.content_margin_bottom = content_margin.w
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 2)
	return style


## Colonne boutons menu principal — panneau bien lisible sur le splash.
static func menu_button_stack_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.04, 0.88)
	style.border_color = UiPalette.GOLD
	style.set_border_width_all(3)
	style.set_corner_radius_all(0)
	style.content_margin_left = 20
	style.content_margin_top = 18
	style.content_margin_right = 20
	style.content_margin_bottom = 18
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 6)
	return style


static func apply_pixel_panel(
	panel: Control,
	style: StyleBoxFlat = null
) -> void:
	if panel == null:
		return
	var box: StyleBoxFlat = style if style != null else pixel_overlay_panel_style()
	panel.add_theme_stylebox_override("panel", box)
