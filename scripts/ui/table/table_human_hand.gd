class_name TableHumanHand
extends RefCounted
## Main du joueur humain : construction de l'éventail, entrées souris.


static func clear(ctx: TableContext) -> void:
	_clear_hand_children(ctx)


static func rebuild(ctx: TableContext, animate_reflow: bool = false) -> void:
	var previous_positions: Array[Vector2] = []
	var previous_seat_position := Vector2.ZERO
	if animate_reflow:
		for view: Control in ctx.hand_card_views:
			previous_positions.append(view.global_position)
		if not ctx.seats.is_empty():
			previous_seat_position = ctx.seats[0].global_position
	_clear_hand_children(ctx)
	ctx.hand_cards = ctx.match_manager.hands[ctx.get_local_human_seat()].cards()

	var count: int = ctx.hand_cards.size()
	var step: float = TableConstants.HAND_FAN_SPREAD_DEG / maxf(count - 1, 1.0)
	var start_angle_deg: float = -TableConstants.HAND_FAN_SPREAD_DEG / 2.0
	var fan_center: Vector2 = Vector2(
		ctx.player_bottom_hand.size.x / 2.0,
		ctx.player_bottom_hand.size.y + TableConstants.HAND_FAN_RADIUS - TableConstants.HAND_FAN_BOTTOM_MARGIN
	)
	for i in count:
		var card: CardModel = ctx.hand_cards[i]
		var card_view: Control = TableConstants.CardViewScene.instantiate()
		card_view.face_up = true
		card_view.front_texture = CardTexturePaths.get_front_texture(card)
		card_view.scale = Vector2(TableConstants.HAND_CARD_SCALE, TableConstants.HAND_CARD_SCALE)
		card_view.pivot_offset = Vector2(TableConstants.CARD_BASE_SIZE.x / 2.0, TableConstants.CARD_BASE_SIZE.y)
		ctx.player_bottom_hand.add_child(card_view)

		var angle_rad: float = deg_to_rad(start_angle_deg + step * i)
		var point_on_fan: Vector2 = fan_center + Vector2(sin(angle_rad), -cos(angle_rad)) * TableConstants.HAND_FAN_RADIUS
		card_view.position = point_on_fan - card_view.pivot_offset
		card_view.rotation = angle_rad

		card_view.mouse_entered.connect(_on_mouse_entered.bind(ctx, card_view))
		card_view.mouse_exited.connect(_on_mouse_exited.bind(card_view))
		card_view.gui_input.connect(_on_gui_input.bind(ctx, card_view, card))
		ctx.hand_card_views.append(card_view)

	TableDisplay.refresh_human_hand_legality(ctx)
	_reposition_human_seat(ctx)
	if animate_reflow and not previous_positions.is_empty():
		for index: int in mini(previous_positions.size(), ctx.hand_card_views.size()):
			var view: Control = ctx.hand_card_views[index]
			var target := view.global_position
			view.global_position = previous_positions[index]
			ctx.host.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(view, "global_position", target, 0.24)
		if not ctx.seats.is_empty():
			var seat: Control = ctx.seats[0]
			var seat_target := seat.global_position
			seat.global_position = previous_seat_position
			ctx.host.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(seat, "global_position", seat_target, 0.24)


static func build_hidden_face_down(ctx: TableContext) -> void:
	_clear_hand_children(ctx)

	var local_seat: int = ctx.get_local_human_seat()
	var count: int = ctx.match_manager.hands[local_seat].count()
	if count <= 0:
		return

	var scale: float = TableConstants.HAND_CARD_SCALE
	var card_size: Vector2 = TableConstants.CARD_BASE_SIZE * scale
	var visible_strip: float = 18.0
	var step: float = visible_strip
	var stack_extent: float = card_size.x + step * maxf(count - 1, 0.0)
	var area_size: Vector2 = ctx.player_bottom_hand.size
	var row_y: float = area_size.y * 0.58
	var start_center_x: float = area_size.x / 2.0 - stack_extent / 2.0 + card_size.x / 2.0
	var pivot: Vector2 = TableConstants.CARD_BASE_SIZE * 0.5

	for i in count:
		var card_view: Control = TableConstants.CardViewScene.instantiate()
		card_view.face_up = false
		card_view.scale = Vector2(scale, scale)
		card_view.pivot_offset = pivot
		card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ctx.player_bottom_hand.add_child(card_view)
		var center: Vector2 = Vector2(start_center_x + step * i, row_y)
		card_view.position = center - pivot
		ctx.hand_card_views.append(card_view)
	_reposition_human_seat(ctx)


static func _reposition_human_seat(ctx: TableContext) -> void:
	if ctx.seats.is_empty() or ctx.hand_card_views.is_empty():
		return
	var seat: PlayerSeat = ctx.seats[0]
	var seat_parent := seat.get_parent() as Control
	if seat_parent == null:
		return
	var min_x: float = INF
	var min_y: float = INF
	for card_view: Control in ctx.hand_card_views:
		var transform := card_view.get_global_transform_with_canvas()
		for corner: Vector2 in [Vector2.ZERO, Vector2(card_view.size.x, 0), card_view.size, Vector2(0, card_view.size.y)]:
			var point: Vector2 = transform * corner
			min_x = minf(min_x, point.x)
			min_y = minf(min_y, point.y)
	var seat_size: Vector2 = seat.size
	if seat_size.x <= 0.0 or seat_size.y <= 0.0:
		seat_size = seat.custom_minimum_size
	var desired_global := Vector2(min_x - seat_size.x - 6.0, min_y + 38.0)
	var bottom_safe: float = ctx.host.get_viewport_rect().size.y - 72.0 - seat_size.y
	desired_global.y = minf(desired_global.y, bottom_safe)
	desired_global.x = maxf(desired_global.x, 18.0)
	seat.position = seat_parent.get_global_transform_with_canvas().affine_inverse() * desired_global


static func _clear_hand_children(ctx: TableContext) -> void:
	for child in ctx.player_bottom_hand.get_children():
		ctx.player_bottom_hand.remove_child(child)
		child.queue_free()
	ctx.hand_card_views.clear()
	ctx.hand_cards.clear()


static func _on_mouse_entered(ctx: TableContext, card_view: Control) -> void:
	if not ctx.host.is_inside_tree():
		return
	if card_view.playable:
		TableServiceAccess.audio(ctx.host).play_card_hover()
	card_view.set_hovered(true)


static func _on_mouse_exited(card_view: Control) -> void:
	card_view.set_hovered(false)


static func _on_gui_input(event: InputEvent, ctx: TableContext, card_view: Control, card: CardModel) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ctx.host.call_deferred("_dispatch_human_card_selected", card_view, card)
