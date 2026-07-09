class_name TableHotSeat
extends RefCounted
## Hot seat : rotation du joueur local actif et overlay confidentialité.


static func is_enabled(ctx: TableContext) -> bool:
	return ctx.is_hot_seat_multi_human()


static func needs_handoff(ctx: TableContext) -> bool:
	if not is_enabled(ctx) or ctx.match_manager == null:
		return false
	return ctx.launch_config.needs_handoff_for_current_player(ctx.match_manager.current_player)


static func should_defer_trick_collection(ctx: TableContext) -> bool:
	if not is_enabled(ctx):
		return false
	return needs_handoff(ctx)


static func ensure_local_human_ready(ctx: TableContext) -> void:
	while needs_handoff(ctx) and ctx.is_active():
		await perform_handoff(ctx)


static func perform_handoff(ctx: TableContext) -> void:
	if ctx.match_manager == null or ctx.launch_config == null:
		return
	var target_seat: int = ctx.match_manager.current_player
	var player_name: String = ctx.launch_config.get_display_name_for_seat(target_seat)
	ctx.launch_config.hands_revealed_for_active_human = false
	TableHumanHand.clear(ctx)
	TableSeatDisplayMap.apply(ctx)
	ctx.hot_seat_overlay.show_handoff(player_name)
	await ctx.hot_seat_overlay.handoff_acknowledged
	if not ctx.is_active():
		return
	ctx.launch_config.active_human_seat_index = target_seat
	ctx.launch_config.hands_revealed_for_active_human = true
	TableSeatDisplayMap.apply(ctx)
	TableTrickDisplay.sync_card_positions(ctx)
	if ctx.pending_trick_collection_winner >= 0:
		await _reveal_pending_trick_after_handoff(ctx)
	TableHumanHand.rebuild(ctx)
	await MoonSuspicionManager.flush_pending_alerts(ctx)
	TableDisplay.refresh_turn_ui(ctx)


static func _reveal_pending_trick_after_handoff(ctx: TableContext) -> void:
	var winner_index: int = ctx.pending_trick_collection_winner
	var winner_card_view: Control = ctx.trick_card_views.get(winner_index) as Control
	if winner_card_view and is_instance_valid(winner_card_view):
		await TableAnimations.highlight_winning_card(ctx.host, winner_card_view)
		if not ctx.is_active():
			return
	await ctx.host.get_tree().create_timer(TableAnimations.HANDOFF_TRICK_VISIBLE_DURATION_SEC).timeout
	if not ctx.is_active():
		return
	await TablePlayFlow.collect_pending_trick(ctx, winner_index)
