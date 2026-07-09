class_name TableLocale
extends RefCounted
## Rafraîchissement i18n de la scène table (noms de sièges, chrome, HUD actif).


static func apply(ctx: TableContext) -> void:
	refresh_seat_names(ctx)
	if ctx.top_menu_bar.has_method("refresh_locale"):
		ctx.top_menu_bar.refresh_locale()
	if ctx.match_manager == null:
		return
	TableDisplay.refresh_scores(ctx)
	TableDisplay.refresh_turn_ui(ctx)


static func refresh_seat_names(ctx: TableContext) -> void:
	if ctx.launch_config != null and TableSeatDisplayMap.uses_rotation(ctx):
		TableSeatDisplayMap.apply(ctx)
		return
	if ctx.launch_config != null:
		for assignment: SeatAssignment in ctx.launch_config.seat_assignments:
			var seat_index: int = assignment.seat_index
			if seat_index >= 0 and seat_index < ctx.seats.size() and assignment.profile != null:
				ctx.seats[seat_index].player_name = assignment.profile.display_name
		return
	for player_index in range(ctx.seats.size()):
		if player_index == 0:
			ctx.seats[player_index].player_name = PlayerProfileService.get_display_name()
		else:
			ctx.seats[player_index].player_name = TableCopy.default_player_name(player_index)
