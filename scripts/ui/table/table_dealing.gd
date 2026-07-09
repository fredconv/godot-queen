class_name TableDealing
extends RefCounted
## Animation visuelle de la distribution des cartes.


static func play_sequence(ctx: TableContext) -> void:
	ctx.turn_locked = true
	if ctx.is_hot_seat_multi_human() and ctx.launch_config != null:
		ctx.launch_config.hands_revealed_for_active_human = false
	await ctx.host.get_tree().process_frame
	if not ctx.is_active():
		ctx.unlock_turn()
		return

	var hide_human_hand: bool = _should_hide_human_hand(ctx)
	if hide_human_hand:
		if ctx.human_hand_area != null:
			ctx.human_hand_area.visible = false
		TableSeatDisplayMap.apply(ctx)
	else:
		TableHumanHand.rebuild(ctx)
	TableDisplay.refresh_opponent_hand_counts(ctx)
	await ctx.host.get_tree().process_frame
	if not ctx.is_active():
		ctx.unlock_turn()
		return

	var human_final_positions: Array[Vector2] = []
	var human_card_views: Array[Control] = []
	if hide_human_hand:
		human_card_views = _prepare_hidden_bottom_deal(ctx, human_final_positions)
	else:
		for card_view in ctx.hand_card_views:
			human_final_positions.append(card_view.position)
			card_view.position = human_final_positions[-1] + TableConstants.HUMAN_HAND_DEAL_OFFSET
			card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		human_card_views = ctx.hand_card_views

	var opponent_deals: Array[Dictionary] = _prepare_opponent_deals(ctx, hide_human_hand)

	var card_count: int = human_final_positions.size()
	if card_count == 0:
		for deal_entry in opponent_deals:
			var cards: Array[Control] = deal_entry["cards"]
			card_count = maxi(card_count, cards.size())

	for round_index in card_count:
		if not ctx.is_active():
			ctx.unlock_turn()
			return

		var tween: Tween = ctx.host.create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		var tween_count := 0

		if round_index < human_card_views.size():
			var human_card: Control = human_card_views[round_index]
			if is_instance_valid(human_card):
				tween.tween_property(
					human_card,
					"position",
					human_final_positions[round_index],
					TableAnimations.DEAL_CARD_DURATION_SEC
				)
				tween_count += 1

		for deal_entry in opponent_deals:
			var cards: Array[Control] = deal_entry["cards"]
			var finals: Array[Vector2] = deal_entry["final_positions"]
			if round_index >= cards.size():
				continue
			var opponent_card: Control = cards[round_index]
			if not is_instance_valid(opponent_card):
				continue
			tween.tween_property(
				opponent_card,
				"position",
				finals[round_index],
				TableAnimations.DEAL_CARD_DURATION_SEC
			)
			tween_count += 1

		if tween_count == 0:
			continue

		TableServiceAccess.audio(ctx.host).play_deal_card()
		await tween.finished
		if not ctx.is_active():
			ctx.unlock_turn()
			return
		if round_index < card_count - 1:
			await ctx.host.get_tree().create_timer(TableAnimations.DEAL_CARD_STAGGER_SEC).timeout
			if not ctx.is_active():
				ctx.unlock_turn()
				return

	if not hide_human_hand:
		for card_view in ctx.hand_card_views:
			card_view.mouse_filter = Control.MOUSE_FILTER_STOP

	var is_first_hand: bool = ctx.match_manager.hand_number == 1
	await TableHandStart.play(ctx, is_first_hand)
	if not ctx.is_active():
		ctx.unlock_turn()
		return
	ctx.unlock_turn()


static func _should_hide_human_hand(ctx: TableContext) -> bool:
	return ctx.is_hot_seat_multi_human() \
		and ctx.launch_config != null \
		and not ctx.launch_config.hands_revealed_for_active_human


static func _prepare_opponent_deals(ctx: TableContext, hide_human_hand: bool) -> Array[Dictionary]:
	var opponent_deals: Array[Dictionary] = []
	var pivot: int = TableSeatDisplayMap.get_pivot_seat(ctx)
	var first_visual_slot: int = 0 if hide_human_hand else 1
	for visual_slot in range(first_visual_slot, HeartsRules.PLAYER_COUNT):
		var logical_seat: int = TableSeatDisplayMap.logical_seat_for_visual_slot(visual_slot, pivot)
		var seat: PlayerSeat = ctx.seats[visual_slot]
		seat.hand_card_count = ctx.match_manager.hands[logical_seat].count()
		if seat.get_hand_back_card_views().is_empty():
			seat.force_refresh_hand_back()
		var cards: Array[Control] = seat.get_hand_back_card_views()
		var offset: Vector2 = seat.get_deal_start_offset()
		var final_positions: Array[Vector2] = []
		for card_view in cards:
			final_positions.append(card_view.position)
			card_view.position = final_positions[-1] + offset
		opponent_deals.append({"cards": cards, "final_positions": final_positions})
	return opponent_deals


static func _prepare_hidden_bottom_deal(
	ctx: TableContext,
	out_final_positions: Array[Vector2]
) -> Array[Control]:
	var pivot: int = TableSeatDisplayMap.get_pivot_seat(ctx)
	var bottom_seat: PlayerSeat = ctx.seats[TableSeatDisplayMap.VisualSlot.BOTTOM]
	bottom_seat.show_hand_back = true
	bottom_seat.hand_card_count = ctx.match_manager.hands[pivot].count()
	if bottom_seat.get_hand_back_card_views().is_empty():
		bottom_seat.force_refresh_hand_back()
	var cards: Array[Control] = bottom_seat.get_hand_back_card_views()
	var offset: Vector2 = bottom_seat.get_deal_start_offset()
	for card_view in cards:
		out_final_positions.append(card_view.position)
		card_view.position = out_final_positions[-1] + offset
	return cards
