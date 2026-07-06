class_name TableDealing
extends RefCounted
## Animation visuelle de la distribution des cartes.


static func play_sequence(ctx: TableContext) -> void:
	ctx.turn_locked = true
	await ctx.host.get_tree().process_frame
	if not ctx.is_active():
		ctx.unlock_turn()
		return

	TableHumanHand.rebuild(ctx)
	TableDisplay.refresh_opponent_hand_counts(ctx)
	await ctx.host.get_tree().process_frame
	if not ctx.is_active():
		ctx.unlock_turn()
		return

	var human_final_positions: Array[Vector2] = []
	for card_view in ctx.hand_card_views:
		human_final_positions.append(card_view.position)
		card_view.position = human_final_positions[-1] + TableConstants.HUMAN_HAND_DEAL_OFFSET
		card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var opponent_deals: Array[Dictionary] = []
	for player_index in range(1, HeartsRules.PLAYER_COUNT):
		var seat: PlayerSeat = ctx.seats[player_index]
		if seat.get_hand_back_card_views().is_empty():
			seat.force_refresh_hand_back()
		var cards: Array[Control] = seat.get_hand_back_card_views()
		var offset: Vector2 = seat.get_deal_start_offset()
		var final_positions: Array[Vector2] = []
		for card_view in cards:
			final_positions.append(card_view.position)
			card_view.position = final_positions[-1] + offset
		opponent_deals.append({"cards": cards, "final_positions": final_positions})

	var card_count: int = human_final_positions.size()
	for round_index in card_count:
		if not ctx.is_active():
			ctx.unlock_turn()
			return

		var tween: Tween = ctx.host.create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		var tween_count := 0

		if round_index < ctx.hand_card_views.size():
			var human_card: Control = ctx.hand_card_views[round_index]
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

	for card_view in ctx.hand_card_views:
		card_view.mouse_filter = Control.MOUSE_FILTER_STOP

	var is_first_hand: bool = ctx.match_manager.hand_number == 1
	await TableHandStart.play(ctx, is_first_hand)
	if not ctx.is_active():
		ctx.unlock_turn()
		return
	ctx.unlock_turn()
