class_name ReactionBubble
extends Control
## Bulle sombre + contour or + icône ; pop / rise / fade.


signal finished

const POP_SEC: float = 0.12
const FADE_SEC: float = 0.28
const BUBBLE_SIZE: Vector2 = Vector2(56, 64)

var _icon: ReactionIcon
var _panel: Panel
var _tail: ColorRect
var _tween: Tween
var _anchor_side: int = 0 ## 0 above, 1 below, 2 right, 3 left


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = BUBBLE_SIZE
	size = BUBBLE_SIZE
	_build()


func _build() -> void:
	_panel = Panel.new()
	_panel.name = "Panel"
	_panel.position = Vector2.ZERO
	_panel.size = Vector2(56, 52)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = UiPalette.PANEL_BG
	style.border_color = UiPalette.GOLD
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 2
	style.shadow_offset = Vector2(1, 2)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_icon = ReactionIcon.new()
	_icon.name = "Icon"
	_icon.face_size = 32
	_icon.position = Vector2(12, 10)
	_icon.size = Vector2(32, 32)
	_panel.add_child(_icon)

	_tail = ColorRect.new()
	_tail.name = "Tail"
	_tail.color = UiPalette.GOLD
	_tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tail.size = Vector2(8, 8)
	add_child(_tail)
	_layout_tail()


func setup(reaction_id: int, anchor_side: int) -> void:
	_anchor_side = anchor_side
	if _icon == null:
		call_deferred("setup", reaction_id, anchor_side)
		return
	_icon.reaction_id = reaction_id
	_layout_tail()


func _layout_tail() -> void:
	if _tail == null or _panel == null:
		return
	match _anchor_side:
		1:
			_tail.position = Vector2(24, -4)
		2:
			_tail.position = Vector2(-4, 22)
		3:
			_tail.position = Vector2(52, 22)
		_:
			_tail.position = Vector2(24, 50)


func play() -> void:
	size = BUBBLE_SIZE
	modulate.a = 1.0
	scale = Vector2(0.85, 0.85)
	pivot_offset = size * 0.5
	var start_pos: Vector2 = position
	var rise_pos: Vector2 = start_pos + Vector2(0, -ReactionIds.RISE_PX)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ONE, POP_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", rise_pos, ReactionIds.DISPLAY_SEC * 0.55).set_trans(Tween.TRANS_SINE)
	_tween.tween_interval(ReactionIds.DISPLAY_SEC * 0.4)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_SEC).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(_on_play_finished, CONNECT_ONE_SHOT)


func _on_play_finished() -> void:
	finished.emit()
	queue_free()


func kill_immediate() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	queue_free()
