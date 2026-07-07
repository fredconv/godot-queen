class_name PixelButton
extends BaseButton
## Bouton pixel art : NinePatch 32×32 + label centré (jamais de texte dans le sprite).

enum SizePreset { MENU, COMPACT }

@export var size_preset: SizePreset = SizePreset.MENU
@export var show_icon: bool = false:
	set(value):
		show_icon = value
		_apply_icon_visibility()

@onready var _nine_patch: NinePatchRect = $NinePatchBackground
@onready var _label: Label = $MarginContainer/ContentRow/Label
@onready var _icon: TextureRect = $MarginContainer/ContentRow/Icon

var _texture_normal: Texture2D = preload("res://assets/sprites/ui/ninepatch/btn_wood_32.png")
var _texture_pressed: Texture2D = preload("res://assets/sprites/ui/ninepatch/btn_wood_32_pressed.png")
var _pointer_down: bool = false


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	_configure_nine_patch()
	_apply_size_preset()
	_apply_icon_visibility()
	_clear_theme_backgrounds()
	_update_visual_state()
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(func() -> void: _update_visual_state())
	mouse_exited.connect(func() -> void: _update_visual_state())
	focus_entered.connect(func() -> void: _update_visual_state())
	focus_exited.connect(func() -> void: _update_visual_state())


func set_button_text(value: String) -> void:
	if _label:
		_label.text = value
	else:
		call_deferred("set_button_text", value)


func set_button_icon(texture: Texture2D) -> void:
	if _icon:
		_icon.texture = texture
		show_icon = texture != null
	else:
		call_deferred("set_button_icon", texture)


func _on_button_down() -> void:
	_pointer_down = true
	_update_visual_state()


func _on_button_up() -> void:
	_pointer_down = false
	_update_visual_state()


func _configure_nine_patch() -> void:
	var margin: int = UiButtonLayout.NINEPATCH_MARGIN
	_nine_patch.patch_margin_left = margin
	_nine_patch.patch_margin_top = margin
	_nine_patch.patch_margin_right = margin
	_nine_patch.patch_margin_bottom = margin
	_nine_patch.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	_nine_patch.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	_nine_patch.texture = _texture_normal
	_nine_patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _apply_size_preset() -> void:
	var size: Vector2i = UiButtonLayout.MENU_BUTTON_SIZE
	if size_preset == SizePreset.COMPACT:
		size = UiButtonLayout.COMPACT_BUTTON_SIZE
	custom_minimum_size = Vector2(size)


func _apply_icon_visibility() -> void:
	if not _icon:
		return
	_icon.visible = show_icon and _icon.texture != null


func _clear_theme_backgrounds() -> void:
	var empty := StyleBoxEmpty.new()
	for style_name: StringName in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(style_name, empty)


func _update_visual_state() -> void:
	if _nine_patch == null:
		return
	if disabled:
		_nine_patch.texture = _texture_normal
		_nine_patch.modulate = Color(0.72, 0.72, 0.72, 1.0)
		return
	if _pointer_down:
		_nine_patch.texture = _texture_pressed
		_nine_patch.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif is_hovered() or has_focus():
		_nine_patch.texture = _texture_normal
		_nine_patch.modulate = Color(1.1, 1.06, 1.0, 1.0)
	else:
		_nine_patch.texture = _texture_normal
		_nine_patch.modulate = Color(1.0, 1.0, 1.0, 1.0)
