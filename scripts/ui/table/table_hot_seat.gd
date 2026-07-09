class_name TableHotSeat
extends RefCounted
## Hot seat : rotation du joueur local actif et overlay confidentialité.


static func is_enabled(ctx: TableContext) -> bool:
	return ctx.is_hot_seat_multi_human()


static func needs_handoff(ctx: TableContext) -> bool:
	if not is_enabled(ctx) or ctx.match_manager == null:
		return false
	return ctx.launch_config.needs_handoff_for_current_player(ctx.match_manager.current_player)


static func ensure_local_human_ready(ctx: TableContext) -> void:
	while needs_handoff(ctx) and ctx.is_active():
		await perform_handoff(ctx)


static func perform_handoff(ctx: TableContext) -> void:
	if ctx.match_manager == null or ctx.launch_config == null:
		return
	var target_seat: int = ctx.match_manager.current_player
	var player_name: String = ctx.launch_config.get_display_name_for_seat(target_seat)
	if ctx.human_hand_area != null:
		ctx.human_hand_area.visible = false
	ctx.hot_seat_overlay.show_handoff(player_name)
	await ctx.hot_seat_overlay.handoff_acknowledged
	if not ctx.is_active():
		return
	ctx.launch_config.active_human_seat_index = target_seat
	if ctx.human_hand_area != null:
		ctx.human_hand_area.visible = true
	TableHumanHand.rebuild(ctx)
	TableDisplay.refresh_turn_ui(ctx)
