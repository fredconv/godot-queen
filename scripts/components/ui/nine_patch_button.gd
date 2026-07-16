class_name NinePatchButton
extends BaseButton
## Bouton 9-slice : NinePatchRect + label centré (voir button_template.tscn).

@export var patch_texture: Texture2D = preload("res://assets/sprites/9_grid_rounded_patch.png")
@export var button_size: Vector2i = Vector2i(192, 48)
@export var label_font_size: int = LocaleFonts.NINE_PATCH_BUTTON_FONT_SIZE

@onready var _nine_patch: NinePatchRect = $NinePatchBackground
@onready var _label: Label = $MarginContainer/Label

var _pointer_down: bool = false


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	_configure_nine_patch()
	_apply_label_font_size()
	custom_minimum_size = Vector2(button_size)
	_clear_theme_backgrounds()
	_update_visual_state()
	button_down.connect(func() -> void: _pointer_down = true; _update_visual_state())
	button_up.connect(func() -> void: _pointer_down = false; _update_visual_state())
	mouse_entered.connect(func() -> void: _update_visual_state())
	mouse_exited.connect(func() -> void: _update_visual_state())
	focus_entered.connect(func() -> void: _update_visual_state())
	focus_exited.connect(func() -> void: _update_visual_state())


func _apply_label_font_size() -> void:
	if _label:
		_label.add_theme_font_size_override("font_size", label_font_size)


func set_button_text(value: String) -> void:
	if _label:
		_label.text = value
	else:
		call_deferred("set_button_text", value)


func apply_button_size(size: Vector2i) -> void:
	button_size = size
	custom_minimum_size = Vector2(size)


func ensure_opaque_background(
	fill_color: Color = UiPalette.BTN_BG,
	border_color: Color = UiPalette.PANEL_BORDER,
	corner_radius: int = 6
) -> void:
	if has_node("OpaqueBackground"):
		return
	var panel := Panel.new()
	panel.name = "OpaqueBackground"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(corner_radius)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	move_child(panel, 0)


func _configure_nine_patch() -> void:
	var margin: int = UiNinePatchCatalog.PATCH_MARGIN
	_nine_patch.texture = patch_texture
	_nine_patch.patch_margin_left = margin
	_nine_patch.patch_margin_top = margin
	_nine_patch.patch_margin_right = margin
	_nine_patch.patch_margin_bottom = margin
	_nine_patch.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	_nine_patch.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	_nine_patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _clear_theme_backgrounds() -> void:
	var empty := StyleBoxEmpty.new()
	for style_name: StringName in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(style_name, empty)


func _update_visual_state() -> void:
	if _nine_patch == null:
		return
	if disabled:
		_nine_patch.modulate = Color(0.72, 0.72, 0.72, 1.0)
		return
	if _pointer_down:
		_nine_patch.modulate = Color(0.92, 0.92, 0.92, 1.0)
	elif is_hovered() or has_focus():
		_nine_patch.modulate = Color(1.08, 1.04, 1.0, 1.0)
	else:
		_nine_patch.modulate = Color(1.0, 1.0, 1.0, 1.0)
