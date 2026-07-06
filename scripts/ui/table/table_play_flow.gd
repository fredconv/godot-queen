class_name TablePlayFlow
extends RefCounted
## Enchaînement des coups : humain, IA, animations de pose et résolution de pli.


static func on_human_card_selected(ctx: TableContext, card_view: Control, card: CardModel) -> void:
	if not is_instance_valid(card_view):
		return
	if ctx.turn_locked or ctx.match_manager.current_player != TableConstants.HUMAN_INDEX:
		return
	if ctx.match_manager.is_match_over():
		return
	if not TableDisplay.card_in_list(card, TableDisplay.current_human_legal_plays(ctx)):
		return

	var result: MatchManager.PlayResult = ctx.match_manager.play_card(TableConstants.HUMAN_INDEX, card)
	if not result.success:
		return

	ctx.turn_locked = true
	var start_center: Vector2 = card_view.get_global_transform_with_canvas() * (card_view.size / 2.0)
	TableHumanHand.rebuild(ctx)
	await animate_card_play(ctx, TableConstants.HUMAN_INDEX, card, start_center)
	if not ctx.is_active():
		return
	await handle_post_play(ctx, result)
	if not ctx.is_active():
		return
	ctx.unlock_turn()

	if ctx.match_manager.is_match_over():
		return

	if ctx.match_manager.phase == MatchManager.Phase.PLAYING \
			and ctx.match_manager.is_ai_controlled(ctx.match_manager.current_player):
		await run_ai_turns(ctx)


static func run_ai_turns(ctx: TableContext) -> void:
	if ctx.turn_locked or ctx.match_manager.is_match_over():
		return
	ctx.turn_locked = true

	while ctx.match_manager.phase == MatchManager.Phase.PLAYING \
			and ctx.match_manager.is_ai_controlled(ctx.match_manager.current_player):
		await ctx.host.get_tree().create_timer(TableConstants.AI_TURN_DELAY_SEC).timeout
		if not ctx.is_active():
			ctx.unlock_turn()
			return

		var player_index: int = ctx.match_manager.current_player
		var ai_player: AiPlayer = ctx.match_manager.ai_players[player_index]
		var legal: Array[CardModel] = ctx.match_manager.get_legal_plays(player_index)
		var context: Dictionary = ctx.match_manager.build_ai_context(player_index)
		var card: CardModel = ai_player.choose_card(legal, context)

		var result: MatchManager.PlayResult = ctx.match_manager.play_card(player_index, card)
		if not result.success:
			TableServiceAccess.debug(ctx.host).log_error(
				"Table: l'IA du siège %d a proposé un coup invalide" % player_index
			)
			break

		var seat: PlayerSeat = ctx.seats[player_index]
		var start_center: Vector2 = seat.get_global_transform_with_canvas() * (seat.size / 2.0)
		seat.hand_card_count = maxi(seat.hand_card_count - 1, 0)

		await animate_card_play(ctx, player_index, card, start_center)
		if not ctx.is_active():
			ctx.unlock_turn()
			return
		await handle_post_play(ctx, result)
		if not ctx.is_active():
			ctx.unlock_turn()
			return

		if result.match_completed or ctx.match_manager.is_match_over():
			ctx.unlock_turn()
			return

	ctx.unlock_turn()
	TableDisplay.refresh_turn_ui(ctx)


static func animate_card_play(
	ctx: TableContext,
	player_index: int,
	card: CardModel,
	start_center: Vector2
) -> void:
	var traveling_card: Control = _spawn_traveling_card(ctx, card, start_center)
	var target_slot: Control = ctx.trick_slots[player_index]
	var target_center: Vector2 = target_slot.get_global_transform_with_canvas() * (target_slot.size / 2.0)
	var cards_in_trick: int = ctx.match_manager.trick_manager.played_count()
	if cards_in_trick >= 2:
		TableFx.fade_lead_suit_indicator(ctx, TableAnimations.CARD_PLAY_DURATION_SEC)
	if card.is_queen_of_spades():
		TableServiceAccess.audio(ctx.host).play_queen_of_spades()
		ctx.queen_avatar_burst.play(ctx.seats[player_index].character_id)
		await TableAnimations.play_queen_bullet_time(
			ctx.host,
			traveling_card,
			target_center,
			ctx.bullet_time_camera,
			ctx.bullet_time_dim
		)
	else:
		await TableAnimations.play_card_to_trick(ctx.host, traveling_card, target_center)
	if not ctx.is_active():
		return
	ctx.trick_card_views[player_index] = traveling_card
	TableFx.refresh_lead_suit_indicator(ctx)


static func handle_post_play(ctx: TableContext, result: MatchManager.PlayResult) -> void:
	TableDisplay.refresh_opponent_hand_counts(ctx)

	if not result.trick_completed:
		TableDisplay.refresh_turn_ui(ctx)
		return

	await resolve_trick_sequence(ctx, result.trick_winner, result.match_completed)
	if not ctx.is_active():
		return
	TableDisplay.refresh_scores(ctx)

	if result.hand_completed:
		if result.match_completed or ctx.match_manager.is_match_over():
			TableMatchFlow.show_match_end_popup(ctx)
			return
		await TableMatchFlow.show_hand_end_popup(ctx)
		if not ctx.is_active():
			return
		ctx.match_manager.start_new_hand()
		await TableDealing.play_sequence(ctx)
		if not ctx.is_active():
			return
		TableDisplay.refresh_scores(ctx)
		await TablePlayFlow.run_ai_turns(ctx)
		if not ctx.is_active():
			return

	TableDisplay.refresh_turn_ui(ctx)


static func resolve_trick_sequence(
	ctx: TableContext,
	winner_index: int,
	is_final_match_trick: bool = false
) -> void:
	var winner_card_view: Control = ctx.trick_card_views.get(winner_index)
	if winner_card_view:
		await TableAnimations.highlight_winning_card(ctx.host, winner_card_view)
		if not ctx.is_active():
			return

	var visible_duration: float = (
		TableAnimations.MATCH_END_TRICK_VISIBLE_DURATION_SEC
		if is_final_match_trick
		else TableAnimations.TRICK_VISIBLE_DURATION_SEC
	)
	await ctx.host.get_tree().create_timer(visible_duration).timeout
	if not ctx.is_active():
		return

	if is_final_match_trick:
		return

	var winner_seat: PlayerSeat = ctx.seats[winner_index]
	var target_center: Vector2 = winner_seat.get_global_transform_with_canvas() * (winner_seat.size / 2.0)
	var card_views: Array[Control] = []
	for card_view in ctx.trick_card_views.values():
		card_views.append(card_view as Control)
	await TableAnimations.collect_trick(ctx.host, card_views, target_center)
	if not ctx.is_active():
		return
	ctx.trick_card_views.clear()


static func _spawn_traveling_card(ctx: TableContext, card: CardModel, start_global_center: Vector2) -> Control:
	var card_view: Control = TableConstants.CardViewScene.instantiate()
	card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_view.face_up = true
	card_view.front_texture = CardTexturePaths.get_front_texture(card)
	card_view.scale = Vector2(TableConstants.TRICK_CARD_SCALE, TableConstants.TRICK_CARD_SCALE)
	ctx.animation_layer.add_child(card_view)
	var visual_half_size: Vector2 = TableConstants.CARD_BASE_SIZE * TableConstants.TRICK_CARD_SCALE / 2.0
	card_view.global_position = start_global_center - visual_half_size
	return card_view
