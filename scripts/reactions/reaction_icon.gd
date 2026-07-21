class_name ReactionIcon
extends Control
## Visage pixel procédural (`_draw`) — pas d’emoji OS ni de sprite externe.


@export var reaction_id: int = ReactionIds.Id.SMILE:
	set(value):
		reaction_id = value
		queue_redraw()

@export var face_size: int = 28:
	set(value):
		face_size = value
		custom_minimum_size = Vector2(face_size, face_size)
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(face_size, face_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_reaction(id: int) -> void:
	reaction_id = id


func _draw() -> void:
	var s: float = minf(size.x, size.y)
	if s < 8.0:
		return
	var origin := Vector2((size.x - s) * 0.5, (size.y - s) * 0.5)
	var face_rect := Rect2(origin, Vector2(s, s))
	var fill: Color = _face_fill()
	var border: Color = UiPalette.GOLD
	## Carré pixel (coins nets).
	draw_rect(face_rect, fill, true)
	draw_rect(face_rect, border, false, 1.0)
	var unit: float = s / 14.0
	var ink: Color = Color(0.12, 0.1, 0.08, 1.0)
	match reaction_id:
		ReactionIds.Id.SMILE:
			_draw_eye(origin, unit, 4, 4, ink)
			_draw_eye(origin, unit, 9, 4, ink)
			_draw_mouth_arc(origin, unit, ink, true)
		ReactionIds.Id.TAUNT:
			_draw_brow(origin, unit, 3, 3, 5, 4, ink)
			_draw_eye(origin, unit, 4, 5, ink)
			_draw_eye(origin, unit, 9, 4, ink)
			_draw_mouth_smirk(origin, unit, ink)
		ReactionIds.Id.SCREAM:
			_draw_eye(origin, unit, 4, 4, ink, 2)
			_draw_eye(origin, unit, 9, 4, ink, 2)
			_draw_mouth_o(origin, unit, ink)
		ReactionIds.Id.SUSPICIOUS:
			_draw_brow(origin, unit, 3, 4, 6, 3, ink)
			_draw_brow(origin, unit, 8, 3, 11, 4, ink)
			_draw_eye(origin, unit, 4, 5, ink)
			_draw_eye(origin, unit, 9, 5, ink)
			_draw_mouth_flat(origin, unit, ink)
		_:
			_draw_eye(origin, unit, 4, 4, ink)
			_draw_eye(origin, unit, 9, 4, ink)


func _face_fill() -> Color:
	match reaction_id:
		ReactionIds.Id.SMILE:
			return Color(0.92, 0.78, 0.28, 1.0)
		ReactionIds.Id.TAUNT:
			return Color(0.88, 0.62, 0.22, 1.0)
		ReactionIds.Id.SCREAM:
			return Color(0.9, 0.55, 0.35, 1.0)
		ReactionIds.Id.SUSPICIOUS:
			return Color(0.75, 0.72, 0.45, 1.0)
		_:
			return Color(0.85, 0.75, 0.35, 1.0)


func _px(origin: Vector2, unit: float, gx: int, gy: int) -> Vector2:
	return origin + Vector2(float(gx) * unit, float(gy) * unit)


func _draw_eye(origin: Vector2, unit: float, gx: int, gy: int, ink: Color, span: int = 1) -> void:
	var p: Vector2 = _px(origin, unit, gx, gy)
	draw_rect(Rect2(p, Vector2(unit * float(span), unit * float(span))), ink, true)


func _draw_brow(
	origin: Vector2,
	unit: float,
	x0: int,
	y0: int,
	x1: int,
	y1: int,
	ink: Color
) -> void:
	draw_line(_px(origin, unit, x0, y0), _px(origin, unit, x1, y1), ink, maxf(unit, 1.0))


func _draw_mouth_arc(origin: Vector2, unit: float, ink: Color, smile: bool) -> void:
	var y: int = 9 if smile else 10
	var points: PackedVector2Array = PackedVector2Array([
		_px(origin, unit, 4, y),
		_px(origin, unit, 5, y + (1 if smile else -1)),
		_px(origin, unit, 7, y + (1 if smile else -1)),
		_px(origin, unit, 9, y),
	])
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], ink, maxf(unit, 1.0))


func _draw_mouth_smirk(origin: Vector2, unit: float, ink: Color) -> void:
	draw_line(_px(origin, unit, 5, 9), _px(origin, unit, 10, 8), ink, maxf(unit, 1.0))
	draw_line(_px(origin, unit, 10, 8), _px(origin, unit, 11, 9), ink, maxf(unit, 1.0))


func _draw_mouth_o(origin: Vector2, unit: float, ink: Color) -> void:
	var p: Vector2 = _px(origin, unit, 6, 8)
	draw_rect(Rect2(p, Vector2(unit * 2.0, unit * 3.0)), ink, false, maxf(unit * 0.8, 1.0))


func _draw_mouth_flat(origin: Vector2, unit: float, ink: Color) -> void:
	draw_line(_px(origin, unit, 4, 10), _px(origin, unit, 10, 10), ink, maxf(unit, 1.0))
