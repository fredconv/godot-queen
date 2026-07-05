class_name QueenOfSpadesAvatarBurst
extends Control
## Effet « super attaque » Marvel vs Capcom : grand avatar du joueur qui
## traverse l'écran lorsque la Dame de Pique est posée. Purement visuel,
## non bloquant pour la logique de jeu (voir `table.gd`).

signal animation_completed

const TOTAL_DURATION_SEC: float = 1.1
const MAX_WIDTH_PX: float = 720.0
const WIDTH_VIEWPORT_RATIO: float = 0.55
const MAX_HEIGHT_VIEWPORT_RATIO: float = 0.85
const GLOW_SCALE: float = 1.06
const GLOW_ALPHA: float = 0.42

## Entrée rapide (0 % → 18 %).
const SEGMENT_ENTER_SEC: float = 0.198
## Ralenti bullet time au centre-droit (18 % → 55 %).
const SEGMENT_HOLD_SEC: float = 0.407
## Accélération initiale de sortie (55 % → 72 %).
const SEGMENT_EXIT_START_SEC: float = 0.187
## Sortie rapide vers la gauche (72 % → 100 %).
const SEGMENT_EXIT_SEC: float = 0.308

var _flash: TextureRect
var _avatar_glow: TextureRect
var _avatar: TextureRect
var _flight_tween: Tween
var _flash_tween: Tween
var _playing: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_nodes()


func _exit_tree() -> void:
	_stop_animation()


func _build_nodes() -> void:
	_flash = TextureRect.new()
	_flash.name = "Flash"
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.texture = _build_radial_flash_texture()
	_flash.modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_child(_flash)

	_avatar_glow = TextureRect.new()
	_avatar_glow.name = "AvatarGlow"
	_avatar_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_avatar_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_avatar_glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_avatar_glow.modulate = Color(1.0, 1.0, 1.0, GLOW_ALPHA)
	add_child(_avatar_glow)

	_avatar = TextureRect.new()
	_avatar.name = "Avatar"
	_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_avatar)


func _build_radial_flash_texture() -> Texture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.65))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var radial := GradientTexture2D.new()
	radial.gradient = gradient
	radial.fill = GradientTexture2D.FILL_RADIAL
	radial.fill_from = Vector2(0.58, 0.5)
	radial.fill_to = Vector2(0.88, 0.5)
	radial.width = 512
	radial.height = 512
	return radial


## Lance l'animation pour le joueur `character_id` (0-3). Non bloquant :
## émet `animation_completed` à la fin.
func play(character_id: int) -> void:
	var texture: Texture2D = SpecialAvatarPaths.get_texture(character_id)
	if texture == null:
		DebugService.log_error(
			"QueenOfSpadesAvatarBurst: texture introuvable pour character_id %d" % character_id
		)
		animation_completed.emit()
		return

	_stop_animation()
	_playing = true
	visible = true
	_avatar.texture = texture
	_avatar_glow.texture = texture
	_flash.modulate.a = 0.0
	_run_flight_animation()
	_run_flash_animation()


func _stop_animation() -> void:
	if _flight_tween and _flight_tween.is_valid():
		_flight_tween.kill()
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flight_tween = null
	_flash_tween = null
	_playing = false
	visible = false


func _finish_animation() -> void:
	_playing = false
	visible = false
	_flight_tween = null
	animation_completed.emit()


func _set_avatar_state_vec(state: Vector3) -> void:
	_set_avatar_state(state.x, state.y, state.z)


func _viewport_size() -> Vector2:
	return get_viewport_rect().size


func _avatar_layout(texture: Texture2D) -> Dictionary:
	var viewport: Vector2 = _viewport_size()
	var target_width: float = minf(viewport.x * WIDTH_VIEWPORT_RATIO, MAX_WIDTH_PX)
	var aspect: float = texture.get_height() / maxf(texture.get_width(), 1.0)
	var display_height: float = minf(target_width * aspect, viewport.y * MAX_HEIGHT_VIEWPORT_RATIO)
	var display_width: float = display_height / aspect
	var top_y: float = (viewport.y - display_height) * 0.5
	return {
		"width": display_width,
		"height": display_height,
		"top_y": top_y,
	}


func _set_avatar_state(left_vw: float, scale_factor: float, opacity: float) -> void:
	var texture: Texture2D = _avatar.texture
	if texture == null:
		return
	var layout: Dictionary = _avatar_layout(texture)
	var viewport_w: float = _viewport_size().x
	var left_x: float = viewport_w * (left_vw / 100.0)
	var display_width: float = layout["width"] * scale_factor
	var display_height: float = layout["height"] * scale_factor
	var top_y: float = layout["top_y"] - (display_height - layout["height"]) * 0.5

	_avatar.size = Vector2(display_width, display_height)
	_avatar.position = Vector2(left_x, top_y)
	_avatar.modulate.a = opacity

	var glow_pad: float = display_width * (GLOW_SCALE - 1.0) * 0.5
	_avatar_glow.size = Vector2(display_width * GLOW_SCALE, display_height * GLOW_SCALE)
	_avatar_glow.position = Vector2(left_x - glow_pad, top_y - glow_pad * (display_height / display_width))
	_avatar_glow.modulate.a = opacity * GLOW_ALPHA


func _run_flight_animation() -> void:
	var tween: Tween = create_tween()
	_flight_tween = tween
	tween.set_parallel(false)

	_set_avatar_state(120.0, 1.08, 0.0)

	tween.tween_method(_set_avatar_state_vec, Vector3(120.0, 1.08, 0.0), Vector3(40.0, 1.03, 1.0), SEGMENT_ENTER_SEC) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_method(_set_avatar_state_vec, Vector3(40.0, 1.03, 1.0), Vector3(30.0, 1.0, 1.0), SEGMENT_HOLD_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(_set_avatar_state_vec, Vector3(30.0, 1.0, 1.0), Vector3(18.0, 1.06, 1.0), SEGMENT_EXIT_START_SEC) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	tween.tween_method(_set_avatar_state_vec, Vector3(18.0, 1.06, 1.0), Vector3(-75.0, 1.12, 0.0), SEGMENT_EXIT_SEC) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	tween.tween_callback(_finish_animation)


func _run_flash_animation() -> void:
	var flash_tween: Tween = create_tween()
	_flash_tween = flash_tween
	_flash.modulate.a = 0.0
	flash_tween.tween_interval(TOTAL_DURATION_SEC * 0.22)
	flash_tween.tween_property(_flash, "modulate:a", 1.0, 0.04) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(_flash, "modulate:a", 0.18, TOTAL_DURATION_SEC * 0.23) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	flash_tween.tween_property(_flash, "modulate:a", 0.0, TOTAL_DURATION_SEC * 0.25) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
