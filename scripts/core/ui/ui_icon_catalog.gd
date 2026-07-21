class_name UiIconCatalog
extends RefCounted
## Catalogue des icones illustrees Dame de Pique.
## Une texture atlas partagee, decoupee en 16 regions pour limiter les changements d'etat GPU.

const ATLAS_PATH := "res://assets/sprites/ui/dame_de_pique/common_icon_atlas_v1.png"
const ATLAS_SIZE := Vector2i(1254, 1254)
const COLUMNS := 4
const ROWS := 4

enum Icon {
	FOCUS_SPADE,
	RULES,
	TROPHY,
	SETTINGS,
	CREDITS,
	EXIT,
	AUDIO,
	MUSIC,
	TABLE_THEME,
	ONLINE,
	PROFILE,
	COIN,
	CROWN,
	INVITE,
	PLAYING_CARDS,
	DIVIDER,
}

static var _atlas: Texture2D
static var _cache: Dictionary = {}


static func texture(icon: Icon) -> AtlasTexture:
	if _cache.has(icon):
		return _cache[icon] as AtlasTexture
	if _atlas == null:
		_atlas = load(ATLAS_PATH) as Texture2D
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = _atlas
	atlas_texture.region = _region_for(icon)
	atlas_texture.filter_clip = true
	_cache[icon] = atlas_texture
	return atlas_texture


static func make_icon_rect(icon: Icon, display_size: Vector2i) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(display_size)
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.texture = texture(icon)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return rect


static func _region_for(icon: Icon) -> Rect2:
	var index := int(icon)
	var column := index % COLUMNS
	var row := floori(float(index) / float(COLUMNS))
	var x0 := roundi(float(column) * float(ATLAS_SIZE.x) / float(COLUMNS))
	var x1 := roundi(float(column + 1) * float(ATLAS_SIZE.x) / float(COLUMNS))
	var y0 := roundi(float(row) * float(ATLAS_SIZE.y) / float(ROWS))
	var y1 := roundi(float(row + 1) * float(ATLAS_SIZE.y) / float(ROWS))
	return Rect2(x0, y0, x1 - x0, y1 - y0)
