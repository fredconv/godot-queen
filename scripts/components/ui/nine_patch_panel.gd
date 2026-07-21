class_name NinePatchPanel
extends Control
## Panneau 9-slice pour dialogs / overlays (réf. archive `dialog_template.tscn`).

@export var patch_texture: Texture2D = preload("res://assets/sprites/9_grid_Badge_patch.png")
@export var panel_size: Vector2i = Vector2i(320, 200)
@export var content_margin: int = 16

@onready var _nine_patch: NinePatchRect = $NinePatchBackground
@onready var _content: MarginContainer = $MarginContainer


func _ready() -> void:
	_configure_nine_patch()
	custom_minimum_size = Vector2(panel_size)
	_content.add_theme_constant_override("margin_left", content_margin)
	_content.add_theme_constant_override("margin_top", content_margin)
	_content.add_theme_constant_override("margin_right", content_margin)
	_content.add_theme_constant_override("margin_bottom", content_margin)


func get_content_container() -> MarginContainer:
	return _content


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
