class_name ReactionManager
extends RefCounted
## Orchestration réactions : cooldown, affichage, réseau (hôte autoritaire).


var _last_reaction_msec: Dictionary = {} ## seat -> ticks
var _active_bubbles: Dictionary = {} ## seat -> ReactionBubble
var _picker: ReactionPicker = null


static func reset_for_match(ctx: TableContext) -> void:
	ctx.reaction_manager = ReactionManager.new()
	_ensure_picker(ctx)


static func on_new_hand(ctx: TableContext) -> void:
	var manager := _manager(ctx)
	if manager == null:
		return
	manager._last_reaction_msec.clear()
	_refresh_picker(ctx)


static func _ensure_picker(ctx: TableContext) -> void:
	if ctx.host == null:
		return
	var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return
	var existing: ReactionPicker = ui_layer.get_node_or_null("ReactionPicker") as ReactionPicker
	var manager := _manager(ctx)
	if existing != null:
		if manager != null:
			manager._picker = existing
		_bind_picker_signal(ctx, existing)
		_refresh_picker(ctx)
		return
	var picker := ReactionPicker.new()
	picker.name = "ReactionPicker"
	picker.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	picker.offset_left = -64.0
	picker.offset_top = -72.0
	picker.offset_right = -12.0
	picker.offset_bottom = -16.0
	_bind_picker_signal(ctx, picker)
	ui_layer.add_child(picker)
	if manager != null:
		manager._picker = picker
	_refresh_picker(ctx)


## Décale le picker hors de la sidebar / bottom bar (reste flottant, indépendant).
static func apply_shell_insets(ctx: TableContext, insets: Vector4) -> void:
	var manager := _manager(ctx)
	var picker: ReactionPicker = null
	if manager != null:
		picker = manager._picker
	if picker == null and ctx.host != null:
		var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
		if ui_layer != null:
			picker = ui_layer.get_node_or_null("ReactionPicker") as ReactionPicker
	if picker == null:
		return
	picker.offset_left = -64.0 - insets.z
	picker.offset_right = -12.0 - insets.z
	picker.offset_top = -72.0 - insets.w
	picker.offset_bottom = -16.0 - insets.w


static func _bind_picker_signal(ctx: TableContext, picker: ReactionPicker) -> void:
	## Rebranche à chaque match : le ctx capturé ne doit pas être périmé.
	for conn: Dictionary in picker.get_signal_connection_list(&"reaction_selected"):
		picker.disconnect(&"reaction_selected", conn["callable"])
	picker.reaction_selected.connect(func(reaction_id: int) -> void:
		on_picker_selected(ctx, reaction_id)
	)


static func _refresh_picker(ctx: TableContext) -> void:
	var manager := _manager(ctx)
	if manager == null or manager._picker == null:
		return
	manager._picker.refresh_from_config()
	manager._picker.visible = ConfigService.get_emotes_enabled()


static func on_picker_selected(ctx: TableContext, reaction_id: int) -> void:
	if not ConfigService.get_emotes_enabled():
		return
	if not ReactionIds.is_valid(reaction_id):
		return
	var seat: int = ctx.get_local_human_seat()
	submit_reaction(ctx, seat, reaction_id)


static func can_submit(ctx: TableContext, seat_index: int) -> bool:
	if not ConfigService.get_emotes_enabled():
		return false
	if ctx.match_manager == null:
		return false
	if ctx.hot_seat_overlay != null and ctx.hot_seat_overlay.visible:
		return false
	var manager := _manager(ctx)
	if manager == null:
		return false
	var last_msec: int = int(manager._last_reaction_msec.get(seat_index, -999999))
	var elapsed: float = float(Time.get_ticks_msec() - last_msec) / 1000.0
	return elapsed >= ReactionIds.COOLDOWN_SEC


static func submit_reaction(ctx: TableContext, seat_index: int, reaction_id: int) -> void:
	if not ReactionIds.is_valid(reaction_id):
		return
	if not can_submit(ctx, seat_index):
		return
	if ctx.is_online_client():
		NetworkMatchRelay.rpc_request_reaction.rpc_id(1, reaction_id)
		var manager := _manager(ctx)
		if manager != null and manager._picker != null:
			manager._picker.begin_cooldown()
		return
	apply_reaction(ctx, seat_index, reaction_id)
	if ctx.is_online_host():
		NetworkMatchRelay.broadcast_reaction_from_host(seat_index, reaction_id)


static func apply_reaction(ctx: TableContext, seat_index: int, reaction_id: int) -> void:
	if not ReactionIds.is_valid(reaction_id) or not ctx.is_active():
		return
	if not ConfigService.get_emotes_enabled():
		return
	var manager := _manager(ctx)
	if manager == null:
		return
	manager._last_reaction_msec[seat_index] = Time.get_ticks_msec()
	if seat_index == ctx.get_local_human_seat() and manager._picker != null:
		manager._picker.begin_cooldown()
	_spawn_bubble(ctx, seat_index, reaction_id)
	GameEvents.reaction_sent.emit(seat_index, reaction_id)


static func validate_server(ctx: TableContext, seat_index: int, reaction_id: int) -> bool:
	if not ReactionIds.is_valid(reaction_id):
		return false
	if not ConfigService.get_emotes_enabled():
		return false
	return can_submit(ctx, seat_index)


static func _spawn_bubble(ctx: TableContext, seat_index: int, reaction_id: int) -> void:
	var manager := _manager(ctx)
	## Au-dessus des sièges / main (comme bannières IA) — pas enfant de l’avatar.
	if manager == null or ctx.animation_layer == null:
		return
	var previous: ReactionBubble = manager._active_bubbles.get(seat_index) as ReactionBubble
	if previous != null and is_instance_valid(previous):
		previous.kill_immediate()
	var seat: PlayerSeat = TableSeatDisplayMap.get_seat_node(ctx, seat_index)
	if seat == null:
		return
	var avatar: Control = seat.get_node_or_null("InfoBox/AvatarPlaceholder/Avatar") as Control
	if avatar == null:
		avatar = seat.get_node_or_null("InfoBox/AvatarPlaceholder") as Control
	if avatar == null:
		avatar = seat.get_node_or_null("InfoBox") as Control
	if avatar == null:
		return
	var side: int = _anchor_side_for_seat(seat)
	var bubble := ReactionBubble.new()
	ctx.animation_layer.add_child(bubble)
	bubble.setup(reaction_id, side)
	manager._active_bubbles[seat_index] = bubble
	bubble.finished.connect(func() -> void:
		if manager._active_bubbles.get(seat_index) == bubble:
			manager._active_bubbles.erase(seat_index)
	)
	var avatar_center: Vector2 = avatar.get_global_rect().get_center()
	var layer_xform: Transform2D = ctx.animation_layer.get_global_transform_with_canvas()
	var local_center: Vector2 = layer_xform.affine_inverse() * avatar_center
	bubble.position = _bubble_position(local_center, side, bubble.custom_minimum_size)
	bubble.z_index = 40
	bubble.play()


static func _anchor_side_for_seat(seat: PlayerSeat) -> int:
	match seat.orientation:
		PlayerSeat.SeatOrientation.TOP:
			return 1 ## below
		PlayerSeat.SeatOrientation.LEFT:
			return 2 ## right of player
		PlayerSeat.SeatOrientation.RIGHT:
			return 3 ## left of player
		_:
			return 0 ## above


static func _bubble_position(avatar_center: Vector2, side: int, bubble_size: Vector2) -> Vector2:
	match side:
		1:
			return avatar_center + Vector2(-bubble_size.x * 0.5, 18.0)
		2:
			return avatar_center + Vector2(28.0, -bubble_size.y * 0.5)
		3:
			return avatar_center + Vector2(-bubble_size.x - 28.0, -bubble_size.y * 0.5)
		_:
			return avatar_center + Vector2(-bubble_size.x * 0.5, -bubble_size.y - 12.0)


static func _manager(ctx: TableContext) -> ReactionManager:
	return ctx.reaction_manager as ReactionManager
