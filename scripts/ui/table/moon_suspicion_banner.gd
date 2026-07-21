class_name MoonSuspicionBanner
extends Control
## Bandeau pixel-art « On soupçonne une Lune ! » avec assombrissement léger.


const BANNER_TEXTURE: Texture2D = preload("res://assets/sprites/suspicious-moon.png")
const BANNER_WIDTH_VIEWPORT_RATIO: float = 0.82
const HORIZONTAL_MARGIN_PX: float = 44.0
const VERTICAL_MARGIN_PX: float = 56.0
const MAX_BANNER_HEIGHT_RATIO: float = 0.22
const MESSAGE_ROW_HEIGHT: float = 72.0
const ENTER_DURATION_SEC: float = 0.35
const HOLD_DURATION_SEC: float = 2.0
const EXIT_DURATION_SEC: float = 0.28
const SHAKE_STRENGTH_PX: float = 3.0

@onready var _content: VBoxContainer = $Content
@onready var _banner_texture: TextureRect = $Content/BannerTexture
@onready var _message_label: Label = $Content/MessageRow/MessageLabel
@onready var _player_avatar: PlayerAvatar = $Content/MessageRow/PlayerAvatar


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_anchors_preset(Control.PRESET_FULL_RECT)


func play(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	_banner_texture.texture = BANNER_TEXTURE
	var suspector_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, event.suspector_seat)
	var suspected_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, event.suspected_seat)
	_message_label.text = GameCopy.moon_suspicion_alert(
		suspector_name,
		suspected_name,
		event.message_variant
	)
	_player_avatar.character_index = clampi(event.suspected_seat, 0, PlayerAvatar.CHARACTER_SHEETS.size() - 1)
	_player_avatar.set_turn_active(true)

	var viewport_size: Vector2 = get_viewport_rect().size
	var layout: Dictionary = _compute_layout(viewport_size)
	var banner_size: Vector2 = layout["banner_size"]
	var content_size: Vector2 = layout["content_size"]
	var center_pos: Vector2 = layout["center_pos"]

	_apply_layout(banner_size, content_size, center_pos)
	modulate.a = 1.0

	TableServiceAccess.audio(ctx.host).play_queen_of_spades()

	var dim: ColorRect = ctx.bullet_time_dim
	if dim != null:
		dim.visible = true
		dim.modulate.a = 0.0

	var enter_start_x: float = viewport_size.x + 12.0
	_content.position = Vector2(enter_start_x, center_pos.y)

	var enter_tween: Tween = ctx.host.create_tween().set_parallel(true)
	enter_tween.set_trans(Tween.TRANS_CUBIC)
	enter_tween.set_ease(Tween.EASE_OUT)
	enter_tween.tween_property(_content, "position:x", center_pos.x, ENTER_DURATION_SEC)
	if dim != null:
		enter_tween.tween_property(dim, "modulate:a", 0.42, ENTER_DURATION_SEC)
	await enter_tween.finished
	if not ctx.is_active():
		_reset_dim(dim)
		return

	await _shake_content(center_pos, SHAKE_STRENGTH_PX, 0.18)
	if not ctx.is_active():
		_reset_dim(dim)
		return

	await ctx.host.get_tree().create_timer(HOLD_DURATION_SEC).timeout
	if not ctx.is_active():
		_reset_dim(dim)
		return

	var exit_x: float = -content_size.x - 12.0
	var exit_tween: Tween = ctx.host.create_tween().set_parallel(true)
	exit_tween.set_trans(Tween.TRANS_CUBIC)
	exit_tween.set_ease(Tween.EASE_IN)
	exit_tween.tween_property(_content, "position:x", exit_x, EXIT_DURATION_SEC)
	exit_tween.tween_property(self, "modulate:a", 0.0, EXIT_DURATION_SEC)
	if dim != null:
		exit_tween.tween_property(dim, "modulate:a", 0.0, EXIT_DURATION_SEC)
	await exit_tween.finished
	_reset_dim(dim)


func _apply_layout(banner_size: Vector2, content_size: Vector2, _center_pos: Vector2) -> void:
	_content.clip_contents = true
	_content.custom_minimum_size = content_size
	_content.size = content_size

	_banner_texture.custom_minimum_size = banner_size
	_banner_texture.size = banner_size
	_banner_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	_message_label.custom_minimum_size = Vector2(banner_size.x - 88.0, 0.0)
	_message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


static func _compute_layout(viewport_size: Vector2) -> Dictionary:
	var tex_size: Vector2 = BANNER_TEXTURE.get_size()
	var max_width: float = viewport_size.x - HORIZONTAL_MARGIN_PX * 2.0
	var banner_width: float = minf(viewport_size.x * BANNER_WIDTH_VIEWPORT_RATIO, max_width)
	var banner_height: float = banner_width * tex_size.y / maxf(tex_size.x, 1.0)
	var max_height: float = viewport_size.y * MAX_BANNER_HEIGHT_RATIO
	if banner_height > max_height:
		banner_height = max_height
		banner_width = banner_height * tex_size.x / maxf(tex_size.y, 1.0)

	var banner_size := Vector2(banner_width, banner_height)
	var content_size := Vector2(banner_width, banner_height + MESSAGE_ROW_HEIGHT)
	var center_pos := Vector2(
		(viewport_size.x - content_size.x) * 0.5,
		maxf(
			VERTICAL_MARGIN_PX,
			(viewport_size.y - content_size.y) * 0.5
		)
	)
	return {
		"banner_size": banner_size,
		"content_size": content_size,
		"center_pos": center_pos,
	}


func _shake_content(origin: Vector2, strength_px: float, duration_sec: float) -> void:
	var tween: Tween = create_tween()
	var steps: int = 6
	for _step_index in steps:
		var offset := Vector2(
			randf_range(-strength_px, strength_px),
			randf_range(-strength_px, strength_px)
		)
		tween.tween_property(_content, "position", origin + offset, duration_sec / float(steps))
	tween.tween_property(_content, "position", origin, duration_sec / float(steps))
	await tween.finished


static func _reset_dim(dim: ColorRect) -> void:
	if dim != null:
		dim.visible = false
		dim.modulate.a = 0.0
