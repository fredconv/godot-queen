class_name LocaleFlagIcons
extends RefCounted
## Petites icônes de drapeaux (pixels) pour le sélecteur de langue.
## La police pixel du thème ne rend pas les emojis : textures générées à la volée.

const FLAG_SIZE: Vector2i = Vector2i(20, 14)

static var _cache: Dictionary = {}


static func get_icon(locale: String) -> Texture2D:
	var normalized: String = LocaleCatalog.normalize(locale)
	if _cache.has(normalized):
		return _cache[normalized]
	var image := Image.create(FLAG_SIZE.x, FLAG_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	_paint_flag(image, normalized)
	var texture := ImageTexture.create_from_image(image)
	_cache[normalized] = texture
	return texture


static func _paint_flag(image: Image, locale: String) -> void:
	match locale:
		"en":
			_paint_english_flag(image)
		"de":
			_paint_horizontal_tricolor(image, Color(0.0, 0.0, 0.0), Color(0.86, 0.08, 0.12), Color(1.0, 0.8, 0.0))
		"es":
			_paint_horizontal_tricolor(image, Color(0.76, 0.11, 0.17), Color(0.98, 0.75, 0.18), Color(0.76, 0.11, 0.17), 0.25, 0.5)
		"pt":
			_paint_portugal_flag(image)
		"zh":
			_paint_china_flag(image)
		_:
			_paint_french_flag(image)


static func _paint_french_flag(image: Image) -> void:
	var third: int = int(FLAG_SIZE.x / 3.0)
	_fill_rect(image, 0, 0, third, FLAG_SIZE.y, Color(0.0, 0.14, 0.58))
	_fill_rect(image, third, 0, third * 2, FLAG_SIZE.y, Color(1.0, 1.0, 1.0))
	_fill_rect(image, third * 2, 0, FLAG_SIZE.x, FLAG_SIZE.y, Color(0.93, 0.16, 0.22))


static func _paint_english_flag(image: Image) -> void:
	_fill_rect(image, 0, 0, FLAG_SIZE.x, FLAG_SIZE.y, Color(0.0, 0.24, 0.55))
	_fill_rect(image, 0, 5, FLAG_SIZE.x, 9, Color(1.0, 1.0, 1.0))
	_fill_rect(image, 8, 0, 12, FLAG_SIZE.y, Color(1.0, 1.0, 1.0))
	_fill_rect(image, 0, 6, FLAG_SIZE.x, 8, Color(0.8, 0.1, 0.15))
	_fill_rect(image, 9, 0, 11, FLAG_SIZE.y, Color(0.8, 0.1, 0.15))


static func _paint_horizontal_tricolor(
	image: Image,
	top: Color,
	middle: Color,
	bottom: Color,
	top_ratio: float = 1.0 / 3.0,
	middle_ratio: float = 1.0 / 3.0
) -> void:
	var top_end: int = int(FLAG_SIZE.y * top_ratio)
	var middle_end: int = top_end + int(FLAG_SIZE.y * middle_ratio)
	_fill_rect(image, 0, 0, FLAG_SIZE.x, top_end, top)
	_fill_rect(image, 0, top_end, FLAG_SIZE.x, middle_end, middle)
	_fill_rect(image, 0, middle_end, FLAG_SIZE.x, FLAG_SIZE.y, bottom)


static func _paint_portugal_flag(image: Image) -> void:
	var split: int = int(FLAG_SIZE.x * 0.42)
	_fill_rect(image, 0, 0, split, FLAG_SIZE.y, Color(0.0, 0.42, 0.24))
	_fill_rect(image, split, 0, FLAG_SIZE.x, FLAG_SIZE.y, Color(0.8, 0.1, 0.15))
	_draw_disc(image, Vector2i(7, 7), 3, Color(1.0, 0.82, 0.16))


static func _paint_china_flag(image: Image) -> void:
	_fill_rect(image, 0, 0, FLAG_SIZE.x, FLAG_SIZE.y, Color(0.87, 0.16, 0.15))
	_draw_star(image, Vector2i(5, 4), 2, Color(1.0, 0.86, 0.2))
	_draw_star(image, Vector2i(9, 2), 1, Color(1.0, 0.86, 0.2))
	_draw_star(image, Vector2i(10, 4), 1, Color(1.0, 0.86, 0.2))
	_draw_star(image, Vector2i(10, 6), 1, Color(1.0, 0.86, 0.2))
	_draw_star(image, Vector2i(9, 8), 1, Color(1.0, 0.86, 0.2))


static func _fill_rect(image: Image, left: int, top: int, right: int, bottom: int, color: Color) -> void:
	for y in range(top, bottom):
		for x in range(left, right):
			if x >= 0 and x < FLAG_SIZE.x and y >= 0 and y < FLAG_SIZE.y:
				image.set_pixel(x, y, color)


static func _draw_disc(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if Vector2(x, y).distance_to(Vector2(center)) <= float(radius) + 0.35:
				if x >= 0 and x < FLAG_SIZE.x and y >= 0 and y < FLAG_SIZE.y:
					image.set_pixel(x, y, color)


static func _draw_star(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var offset := Vector2(x, y) - Vector2(center)
			if absf(offset.x) + absf(offset.y) * 1.4 <= float(radius) + 0.2:
				if x >= 0 and x < FLAG_SIZE.x and y >= 0 and y < FLAG_SIZE.y:
					image.set_pixel(x, y, color)
