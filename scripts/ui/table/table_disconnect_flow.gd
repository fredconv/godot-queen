class_name TableDisconnectFlow
extends RefCounted
## Messages table : déconnexion / reconnexion / remplacement IA (phase D).


static func bind_relay(ctx: TableContext) -> void:
	if ctx.get_meta(&"disconnect_flow_bound", false):
		return
	ctx.set_meta(&"disconnect_flow_bound", true)
	NetworkMatchRelay.seat_disconnect_announced.connect(_on_disconnect_announced.bind(ctx))
	NetworkMatchRelay.seat_reconnect_countdown.connect(_on_countdown.bind(ctx))
	NetworkMatchRelay.seat_replaced_by_ai.connect(_on_replaced_by_ai.bind(ctx))
	NetworkMatchRelay.seat_reconnected.connect(_on_reconnected.bind(ctx))


static func _on_disconnect_announced(ctx: TableContext, seat_index: int, display_name: String) -> void:
	if not ctx.is_active() or ctx.top_menu_bar == null:
		return
	ctx.top_menu_bar.set_turn_text(
		TranslationServer.translate(TableKeys.NET_PLAYER_DISCONNECTED) % display_name
	)


static func _on_countdown(ctx: TableContext, seat_index: int, display_name: String, remaining_sec: int) -> void:
	if not ctx.is_active() or ctx.top_menu_bar == null:
		return
	ctx.top_menu_bar.set_turn_text(
		TranslationServer.translate(TableKeys.NET_RECONNECT_COUNTDOWN) % [display_name, remaining_sec]
	)


static func _on_replaced_by_ai(ctx: TableContext, seat_index: int, display_name: String) -> void:
	if not ctx.is_active() or ctx.top_menu_bar == null:
		return
	ctx.top_menu_bar.set_turn_text(
		TranslationServer.translate(TableKeys.NET_SEAT_REPLACED_BY_AI) % display_name
	)
	TableDisplay.refresh_turn_ui(ctx)
	if ctx.is_online_host() and ctx.match_manager != null \
			and ctx.match_manager.phase == MatchManager.Phase.PLAYING:
		await TablePlayFlow.run_ai_turns(ctx)


static func _on_reconnected(ctx: TableContext, seat_index: int, display_name: String) -> void:
	if not ctx.is_active() or ctx.top_menu_bar == null:
		return
	ctx.top_menu_bar.set_turn_text(
		TranslationServer.translate(TableKeys.NET_PLAYER_RECONNECTED) % display_name
	)
	TableDisplay.refresh_turn_ui(ctx)
