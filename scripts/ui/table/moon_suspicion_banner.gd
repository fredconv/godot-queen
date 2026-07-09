class_name MoonSuspicionBanner
extends Control
## Bandeau pixel-art « On soupçonne une Lune ! » avec bullet time léger.


const BANNER_TEXTURE: Texture2D = preload("res://assets/sprites/suspicious-moon.png")
const ENTER_DURATION_SEC: float = 0.35
const HOLD_DURATION_SEC: float = 2.0
const EXIT_DURATION_SEC: float = 0.28
const SHAKE_STRENGTH_PX: float = 4.0

@onready var _banner_texture: TextureRect = $BannerTexture
@onready var _message_label: Label = $VBox/MessageLabel
@onready var _avatar_texture: TextureRect = $VBox/AvatarTexture


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func play(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	_banner_texture.texture = BANNER_TEXTURE
	var suspector_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, event.suspector_seat)
	var suspected_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, event.suspected_seat)
	_message_label.text = TranslationServer.translate(TableKeys.MOON_SUSPICION_ALERT) % [suspector_name, suspected_name]
	_avatar_texture.texture = SpecialAvatarPaths.get_texture(event.suspected_seat)

	var viewport_size: Vector2 = get_viewport_rect().size
	var banner_size: Vector2 = Vector2(minf(viewport_size.x * 0.92, 920.0), 120.0)
	_banner_texture.custom_minimum_size = banner_size
	_banner_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var center_y: float = viewport_size.y * 0.38
	var start_x: float = viewport_size.x + banner_size.x * 0.5
	var center_x: float = viewport_size.x * 0.5
	var exit_x: float = -banner_size.x * 0.5

	modulate.a = 1.0
	position = Vector2(start_x - banner_size.x * 0.5, center_y - banner_size.y * 0.5)

	TableServiceAccess.audio(ctx.host).play_queen_of_spades()

	var camera: Camera2D = ctx.bullet_time_camera
	var dim: ColorRect = ctx.bullet_time_dim
	var table_center: Vector2 = ctx.host.get_global_transform_with_canvas() * (ctx.host.size * 0.5)
	if camera != null:
		camera.enabled = true
		camera.make_current()
		camera.global_position = table_center
		camera.zoom = Vector2.ONE
	if dim != null:
		dim.visible = true
		dim.modulate.a = 0.0

	var enter_tween: Tween = ctx.host.create_tween().set_parallel(true)
	enter_tween.set_trans(Tween.TRANS_CUBIC)
	enter_tween.set_ease(Tween.EASE_OUT)
	enter_tween.tween_property(self, "position:x", center_x - banner_size.x * 0.5, ENTER_DURATION_SEC)
	if camera != null:
		enter_tween.tween_property(camera, "zoom", Vector2(1.35, 1.35), ENTER_DURATION_SEC)
	if dim != null:
		enter_tween.tween_property(dim, "modulate:a", 0.42, ENTER_DURATION_SEC)
	await enter_tween.finished
	if not ctx.is_active():
		_reset_camera(camera, dim)
		return

	await _shake_host(ctx.host, SHAKE_STRENGTH_PX, 0.18)
	if not ctx.is_active():
		_reset_camera(camera, dim)
		return

	await ctx.host.get_tree().create_timer(HOLD_DURATION_SEC).timeout
	if not ctx.is_active():
		_reset_camera(camera, dim)
		return

	var exit_tween: Tween = ctx.host.create_tween().set_parallel(true)
	exit_tween.set_trans(Tween.TRANS_CUBIC)
	exit_tween.set_ease(Tween.EASE_IN)
	exit_tween.tween_property(self, "position:x", exit_x - banner_size.x * 0.5, EXIT_DURATION_SEC)
	exit_tween.tween_property(self, "modulate:a", 0.0, EXIT_DURATION_SEC)
	if camera != null:
		exit_tween.tween_property(camera, "zoom", Vector2.ONE, EXIT_DURATION_SEC)
	if dim != null:
		exit_tween.tween_property(dim, "modulate:a", 0.0, EXIT_DURATION_SEC)
	await exit_tween.finished
	_reset_camera(camera, dim)


static func _shake_host(host: Control, strength_px: float, duration_sec: float) -> void:
	var origin: Vector2 = host.position
	var tween: Tween = host.create_tween()
	var steps: int = 6
	for step_index in steps:
		var offset := Vector2(
			randf_range(-strength_px, strength_px),
			randf_range(-strength_px, strength_px)
		)
		tween.tween_property(host, "position", origin + offset, duration_sec / float(steps))
	tween.tween_property(host, "position", origin, duration_sec / float(steps))
	await tween.finished


static func _reset_camera(camera: Camera2D, dim: ColorRect) -> void:
	if camera != null:
		camera.enabled = false
		camera.zoom = Vector2.ONE
	if dim != null:
		dim.visible = false
		dim.modulate.a = 0.0
