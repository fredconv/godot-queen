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
	for player_index in range(ctx.seats.size()):
		ctx.seats[player_index].player_name = TableCopy.default_player_name(player_index)
