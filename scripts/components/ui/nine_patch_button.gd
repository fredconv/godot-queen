class_name NinePatchButton
extends BaseButton
## Bouton 9-slice : NinePatchRect + label centré (voir button_template.tscn).
## Hover/focus/pressed : modulate + scale + chrome OpaqueBackground (bordure or).
## Largeur : s’adapte au label (fit_to_label / uniform_fit_group) — grille 8 px.

@export var patch_texture: Texture2D = preload("res://assets/sprites/9_grid_rounded_patch.png")
@export var button_size: Vector2i = Vector2i(192, 64)
@export var label_font_size: int = LocaleFonts.NINE_PATCH_BUTTON_FONT_SIZE

const HOVER_SCALE: Vector2 = Vector2(1.05, 1.05)
const PRESSED_SCALE: Vector2 = Vector2(0.96, 0.96)
const SCALE_TWEEN_SEC: float = 0.09
const SIZE_GRID: int = 8
## Bordure chrome max (3×2) + ombre label + air — évite le « collé au cadre ».
const LABEL_EXTRA_PAD: int = 24
const ROYAL_NORMAL: Texture2D = preload("res://assets/sprites/ui/royal_salon/button_normal_v1.png")
const ROYAL_HOVER: Texture2D = preload("res://assets/sprites/ui/royal_salon/button_hover_v1.png")
const ROYAL_PRESSED: Texture2D = preload("res://assets/sprites/ui/royal_salon/button_pressed_v1.png")
const ROYAL_SELECTED: Texture2D = preload("res://assets/sprites/ui/royal_salon/button_selected_v1.png")
const ROYAL_DISABLED: Texture2D = preload("res://assets/sprites/ui/royal_salon/button_disabled_v1.png")
const ROYAL_PATCH_MARGIN: int = 12

@onready var _nine_patch: NinePatchRect = $NinePatchBackground
@onready var _label: Label = $MarginContainer/Label
@onready var _margin: MarginContainer = $MarginContainer

var _pointer_down: bool = false
var _scale_tween: Tween = null
var _opaque_fill: Color = UiPalette.BTN_BG
var _opaque_border: Color = UiPalette.PANEL_BORDER
var _button_icon: TextureRect = null


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	_configure_nine_patch()
	_apply_content_margins()
	_apply_label_font_size()
	custom_minimum_size = Vector2(button_size)
	_clear_theme_backgrounds()
	UiOffsetAnim.enable_on(self)
	_update_visual_state()
	button_down.connect(func() -> void: _pointer_down = true; _update_visual_state())
	button_up.connect(func() -> void: _pointer_down = false; _update_visual_state())
	mouse_entered.connect(func() -> void: _update_visual_state())
	mouse_exited.connect(func() -> void: _update_visual_state())
	focus_entered.connect(func() -> void: _update_visual_state())
	focus_exited.connect(func() -> void: _update_visual_state())
	if _label != null and not _label.text.is_empty():
		fit_to_label()


func _apply_content_margins() -> void:
	if _margin == null:
		return
	_margin.add_theme_constant_override("margin_left", UiButtonLayout.CONTENT_MARGIN_H)
	_margin.add_theme_constant_override("margin_right", UiButtonLayout.CONTENT_MARGIN_H)
	_margin.add_theme_constant_override("margin_top", UiButtonLayout.CONTENT_MARGIN_V)
	_margin.add_theme_constant_override("margin_bottom", UiButtonLayout.CONTENT_MARGIN_V)


func _apply_label_font_size() -> void:
	if _label:
		_label.add_theme_font_size_override("font_size", label_font_size)


func set_button_text(value: String) -> void:
	if _label == null:
		call_deferred("set_button_text", value)
		return
	_label.text = value
	fit_to_label()


func set_button_icon(texture: Texture2D, icon_size: int = 32) -> void:
	if texture == null:
		if _button_icon != null:
			_button_icon.queue_free()
			_button_icon = null
		return
	if _button_icon == null:
		_button_icon = TextureRect.new()
		_button_icon.name = "ButtonIcon"
		_button_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_button_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_button_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_button_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		## Keep the icon in the button's own canvas layer. A positive z-index made
		## icons from covered menu buttons bleed through modal overlays.
		_button_icon.z_index = 0
		add_child(_button_icon)
	_button_icon.texture = texture
	_button_icon.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	var half := float(icon_size) * 0.5
	_button_icon.offset_left = 16.0
	_button_icon.offset_top = -half
	_button_icon.offset_right = 16.0 + float(icon_size)
	_button_icon.offset_bottom = half
	if _margin != null:
		_margin.add_theme_constant_override("margin_left", maxi(UiButtonLayout.CONTENT_MARGIN_H, icon_size + 32))
		_margin.add_theme_constant_override("margin_right", UiButtonLayout.CONTENT_MARGIN_H)
	fit_to_label()


func apply_button_size(target_size: Vector2i) -> void:
	button_size = target_size
	custom_minimum_size = Vector2(target_size)


## Élargit le bouton si le label dépasse (conserve une largeur plancher = button_size.x).
func fit_to_label() -> void:
	if _label == null:
		return
	_apply_label_font_size()
	var needed: int = measure_required_width()
	var width: int = maxi(button_size.x, needed)
	width = snap_width_up(width)
	custom_minimum_size = Vector2(width, float(button_size.y))


func measure_required_width() -> int:
	if _label == null:
		return button_size.x
	var font: Font = _label.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size: int = _label.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = label_font_size
	var text_width: float = font.get_string_size(
		_label.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	).x
	var margin_left: int = UiButtonLayout.CONTENT_MARGIN_H
	var margin_right: int = UiButtonLayout.CONTENT_MARGIN_H
	if _margin != null:
		margin_left = _margin.get_theme_constant("margin_left")
		margin_right = _margin.get_theme_constant("margin_right")
	return int(ceili(text_width)) + margin_left + margin_right + LABEL_EXTRA_PAD


## Aligne un groupe : largeur = max(mesure texte, 192), grille 8 — sans garder un plancher trop large d’une locale précédente.
static func uniform_fit_group(buttons: Array) -> void:
	var max_width: int = SIZE_GRID * 24 # 192
	var height: int = UiButtonLayout.MENU_BUTTON_SIZE.y
	for item in buttons:
		var btn: NinePatchButton = item as NinePatchButton
		if btn == null:
			continue
		height = maxi(height, btn.button_size.y)
		max_width = maxi(max_width, btn.measure_required_width())
	max_width = snap_width_up(max_width)
	for item in buttons:
		var btn: NinePatchButton = item as NinePatchButton
		if btn == null:
			continue
		btn.apply_button_size(Vector2i(max_width, height))


static func snap_width_up(width: int) -> int:
	return int(ceili(float(width) / float(SIZE_GRID))) * SIZE_GRID


## Élargit un Panel centré (offsets ±half) pour contenir les boutons + padding.
static func sync_centered_panel_half_width(
	panel: Control,
	buttons: Array,
	padding: float = 48.0,
	min_half: float = 200.0
) -> void:
	if panel == null:
		return
	var max_button_width: float = 0.0
	for item in buttons:
		var btn: Control = item as Control
		if btn == null:
			continue
		max_button_width = maxf(max_button_width, btn.custom_minimum_size.x)
	var half: float = maxf(min_half, max_button_width * 0.5 + padding)
	panel.offset_left = -half
	panel.offset_right = half


func ensure_opaque_background(
	fill_color: Color = UiPalette.BTN_BG,
	border_color: Color = UiPalette.PANEL_BORDER,
	_corner_radius: int = 0
) -> void:
	_opaque_fill = fill_color
	_opaque_border = border_color
	## Royal Salon owns the chrome through the 9-slice state textures. This
	## compatibility method intentionally no longer adds a flat panel.


func _apply_opaque_chrome(hovered: bool, as_pressed: bool, corner_radius: int = 0) -> void:
	var panel: Panel = get_node_or_null("OpaqueBackground") as Panel
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(corner_radius)
	if as_pressed:
		style.bg_color = Color(_opaque_fill.r * 0.75, _opaque_fill.g * 0.75, _opaque_fill.b * 0.75, 1.0)
		style.border_color = UiPalette.GOLD
		style.set_border_width_all(2)
		style.shadow_size = 1
		style.shadow_offset = Vector2(0, 1)
	elif hovered:
		style.bg_color = Color(
			minf(_opaque_fill.r + 0.08, 1.0),
			minf(_opaque_fill.g + 0.1, 1.0),
			minf(_opaque_fill.b + 0.06, 1.0),
			1.0
		)
		style.border_color = UiPalette.GOLD_BRIGHT
		style.set_border_width_all(3)
		style.shadow_color = Color(0, 0, 0, 0.55)
		style.shadow_size = 4
		style.shadow_offset = Vector2(0, 3)
	else:
		style.bg_color = _opaque_fill
		style.border_color = _opaque_border
		style.set_border_width_all(2)
		style.shadow_color = Color(0, 0, 0, 0.45)
		style.shadow_size = 3
		style.shadow_offset = Vector2(0, 2)
	panel.add_theme_stylebox_override("panel", style)


func _configure_nine_patch() -> void:
	var margin: int = ROYAL_PATCH_MARGIN
	_nine_patch.texture = ROYAL_NORMAL
	_nine_patch.patch_margin_left = margin
	_nine_patch.patch_margin_top = margin
	_nine_patch.patch_margin_right = margin
	_nine_patch.patch_margin_bottom = margin
	_nine_patch.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	_nine_patch.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	_nine_patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _clear_theme_backgrounds() -> void:
	var empty := StyleBoxEmpty.new()
	for style_name: StringName in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(style_name, empty)


func _update_visual_state() -> void:
	if _nine_patch == null:
		return
	var target_scale: Vector2 = Vector2.ONE
	if disabled:
		_nine_patch.texture = ROYAL_DISABLED
		_nine_patch.modulate = Color.WHITE
		if _label:
			_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
			_label.add_theme_constant_override("shadow_offset_y", 0)
		_apply_opaque_chrome(false, false)
		_tween_to_scale(Vector2.ONE)
		return
	if _pointer_down:
		_nine_patch.texture = ROYAL_PRESSED
		_nine_patch.modulate = Color.WHITE
		if _label:
			_label.add_theme_color_override("font_color", UiPalette.GOLD)
			_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
			_label.add_theme_constant_override("shadow_offset_x", 1)
			_label.add_theme_constant_override("shadow_offset_y", 1)
		_apply_opaque_chrome(false, true)
		target_scale = PRESSED_SCALE
	elif is_hovered() or has_focus():
		_nine_patch.texture = ROYAL_SELECTED if has_focus() else ROYAL_HOVER
		_nine_patch.modulate = Color.WHITE
		if _label:
			_label.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
			_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
			_label.add_theme_constant_override("shadow_offset_x", 1)
			_label.add_theme_constant_override("shadow_offset_y", 2)
		_apply_opaque_chrome(true, false)
		target_scale = HOVER_SCALE
	else:
		_nine_patch.texture = ROYAL_NORMAL
		_nine_patch.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if _label:
			_label.add_theme_color_override("font_color", UiPalette.CREAM)
			_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
			_label.add_theme_constant_override("shadow_offset_x", 1)
			_label.add_theme_constant_override("shadow_offset_y", 1)
		_apply_opaque_chrome(false, false)
		target_scale = Vector2.ONE
	_tween_to_scale(target_scale)


func _tween_to_scale(target: Vector2) -> void:
	UiOffsetAnim.enable_on(self)
	if offset_transform_scale.is_equal_approx(target):
		return
	UiOffsetAnim.kill_tween(_scale_tween)
	_scale_tween = create_tween()
	_scale_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(self, "offset_transform_scale", target, SCALE_TWEEN_SEC)
