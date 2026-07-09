extends Node
## NetworkMatchRelay (autoload)
## RPC gameplay : intentions client → host, coups confirmés host → clients.


signal play_confirmed(action_result: ActionResult)
signal play_rejected(error_code: StringName)
signal seat_disconnect_announced(seat_index: int, display_name: String)
signal seat_reconnect_countdown(seat_index: int, display_name: String, remaining_sec: int)
signal seat_replaced_by_ai(seat_index: int, display_name: String)
signal seat_reconnected(seat_index: int, display_name: String)

var _table_ctx: TableContext = null
var _host_controller: HostMatchController = null


func _network() -> Node:
	# Évite la dépendance circulaire autoload NetworkService ↔ NetworkMatchRelay.
	return get_node("/root/NetworkService")


func register_table(ctx: TableContext, host_controller: HostMatchController = null) -> void:
	_table_ctx = ctx
	_host_controller = host_controller


func unregister_table() -> void:
	_table_ctx = null
	_host_controller = null


func get_host_controller() -> HostMatchController:
	return _host_controller


@rpc("authority", "call_remote", "reliable")
func rpc_register_player(display_name: String, local_player_id: String) -> void:
	if not _network().is_host():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	_network().apply_remote_player_profile(peer_id, display_name, local_player_id)


@rpc("authority", "call_remote", "reliable")
func rpc_lobby_sync(state_dict: Dictionary) -> void:
	if _network().is_host():
		return
	_network().apply_lobby_from_network(state_dict)


@rpc("authority", "call_remote", "reliable")
func rpc_start_match(seed_value: int, seat_dicts: Array) -> void:
	if _network().is_host():
		return
	_network().receive_match_start(seed_value, seat_dicts)
	get_tree().call_deferred("change_scene_to_file", TableConstants.TABLE_SCENE_PATH)


@rpc("any_peer", "call_remote", "reliable")
func rpc_request_play_card(action_dict: Dictionary) -> void:
	if not _network().is_host():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var seat_index: int = _network().get_seat_for_peer(peer_id)
	if seat_index < 0:
		return
	if _network().is_player_disconnected(seat_index) or _network().is_seat_pending_reconnect(seat_index):
		rpc_play_rejected.rpc_id(peer_id, ActionResult.ERROR_PLAYER_DISCONNECTED)
		return
	var action: PlayCardAction = PlayCardAction.from_dict(action_dict)
	if action == null or action.player_index != seat_index:
		rpc_play_rejected.rpc_id(peer_id, ActionResult.ERROR_NOT_YOUR_TURN)
		return
	if _host_controller == null:
		rpc_play_rejected.rpc_id(peer_id, ActionResult.ERROR_INVALID_ACTION)
		return
	var result: ActionResult = _host_controller.submit_action(action)
	if result.success:
		_broadcast_play(action, result)
	else:
		rpc_play_rejected.rpc_id(peer_id, result.error_code)


@rpc("authority", "call_remote", "reliable")
func rpc_apply_play(action_dict: Dictionary, result_dict: Dictionary) -> void:
	if _network().is_host():
		return
	if _table_ctx == null or not _table_ctx.is_active():
		return
	var action: PlayCardAction = PlayCardAction.from_dict(action_dict)
	var play_result: MatchManager.PlayResult = NetworkPlayPayload.play_result_from_dict(result_dict)
	var action_result := ActionResult.from_play_result(play_result)
	await TablePlayFlow.apply_network_play(_table_ctx, action, action_result)
	play_confirmed.emit(action_result)


@rpc("authority", "call_remote", "reliable")
func rpc_play_rejected(error_code: StringName) -> void:
	play_rejected.emit(error_code)


func broadcast_play_from_host(action: PlayCardAction, result: ActionResult) -> void:
	_broadcast_play(action, result)


func broadcast_moon_suspicion_from_host(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	if not _network().is_host():
		return
	await MoonSuspicionManager.apply_network_event(ctx, event)
	var event_dict: Dictionary = event.to_dict()
	for peer_id: int in multiplayer.get_peers():
		rpc_apply_moon_suspicion.rpc_id(peer_id, event_dict)


@rpc("any_peer", "call_remote", "reliable")
func rpc_request_moon_suspicion(suspected_seat: int) -> void:
	if not _network().is_host():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var suspector_seat: int = _network().get_seat_for_peer(peer_id)
	if suspector_seat < 0 or _table_ctx == null:
		return
	if not MoonSuspicionManager.validate_server(_table_ctx, suspector_seat, suspected_seat):
		return
	var event: MoonSuspicionEvent = MoonSuspicionManager.create_event_for_seats(
		_table_ctx,
		suspector_seat,
		suspected_seat
	)
	await broadcast_moon_suspicion_from_host(_table_ctx, event)


@rpc("authority", "call_remote", "reliable")
func rpc_apply_moon_suspicion(event_dict: Dictionary) -> void:
	if _network().is_host():
		return
	if _table_ctx == null or not _table_ctx.is_active():
		return
	var event: MoonSuspicionEvent = MoonSuspicionEvent.from_dict(event_dict)
	await MoonSuspicionManager.apply_network_event(_table_ctx, event)


@rpc("authority", "call_remote", "reliable")
func rpc_peer_disconnected(seat_index: int, display_name: String) -> void:
	if _network().is_host():
		return
	seat_disconnect_announced.emit(seat_index, display_name)


@rpc("authority", "call_remote", "reliable")
func rpc_seat_reconnect_countdown(seat_index: int, display_name: String, remaining_sec: int) -> void:
	if _network().is_host():
		return
	seat_reconnect_countdown.emit(seat_index, display_name, remaining_sec)


@rpc("authority", "call_remote", "reliable")
func rpc_seat_replaced_by_ai(seat_index: int, display_name: String) -> void:
	if _network().is_host():
		return
	seat_replaced_by_ai.emit(seat_index, display_name)


@rpc("authority", "call_remote", "reliable")
func rpc_peer_reconnected(seat_index: int, display_name: String) -> void:
	if _network().is_host():
		return
	seat_reconnected.emit(seat_index, display_name)


func broadcast_disconnect_event(seat_index: int, display_name: String) -> void:
	seat_disconnect_announced.emit(seat_index, display_name)
	for peer_id: int in multiplayer.get_peers():
		rpc_peer_disconnected.rpc_id(peer_id, seat_index, display_name)


func broadcast_countdown(seat_index: int, display_name: String, remaining_sec: int) -> void:
	seat_reconnect_countdown.emit(seat_index, display_name, remaining_sec)
	for peer_id: int in multiplayer.get_peers():
		rpc_seat_reconnect_countdown.rpc_id(peer_id, seat_index, display_name, remaining_sec)


func broadcast_seat_replaced_by_ai(seat_index: int, display_name: String) -> void:
	_sync_table_launch_config_from_lobby()
	seat_replaced_by_ai.emit(seat_index, display_name)
	for peer_id: int in multiplayer.get_peers():
		rpc_seat_replaced_by_ai.rpc_id(peer_id, seat_index, display_name)


func broadcast_peer_reconnected(seat_index: int, display_name: String) -> void:
	_sync_table_launch_config_from_lobby()
	seat_reconnected.emit(seat_index, display_name)
	for peer_id: int in multiplayer.get_peers():
		rpc_peer_reconnected.rpc_id(peer_id, seat_index, display_name)


func _broadcast_play(action: PlayCardAction, result: ActionResult) -> void:
	var action_dict: Dictionary = NetworkPlayPayload.action_to_dict(action)
	var result_dict: Dictionary = NetworkPlayPayload.play_result_to_dict(result.play_result)
	for peer_id: int in multiplayer.get_peers():
		rpc_apply_play.rpc_id(peer_id, action_dict, result_dict)


func _sync_table_launch_config_from_lobby() -> void:
	if _table_ctx == null or _table_ctx.launch_config == null or not _network().is_host():
		return
	_table_ctx.launch_config.seat_assignments = _network().lobby.seats.duplicate()
