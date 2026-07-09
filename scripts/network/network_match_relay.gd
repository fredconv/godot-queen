extends Node
## NetworkMatchRelay (autoload)
## RPC gameplay : intentions client → host, coups confirmés host → clients.


signal play_confirmed(action_result: ActionResult)
signal play_rejected(error_code: StringName)

var _table_ctx: TableContext = null
var _host_controller: HostMatchController = null


func register_table(ctx: TableContext, host_controller: HostMatchController = null) -> void:
	_table_ctx = ctx
	_host_controller = host_controller


func unregister_table() -> void:
	_table_ctx = null
	_host_controller = null


@rpc("authority", "call_remote", "reliable")
func rpc_register_player(display_name: String, local_player_id: String) -> void:
	if not NetworkService.is_host():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	NetworkService.apply_remote_player_profile(peer_id, display_name, local_player_id)


@rpc("authority", "call_remote", "reliable")
func rpc_lobby_sync(state_dict: Dictionary) -> void:
	if NetworkService.is_host():
		return
	NetworkService.apply_lobby_from_network(state_dict)


@rpc("authority", "call_remote", "reliable")
func rpc_start_match(seed_value: int, seat_dicts: Array) -> void:
	if NetworkService.is_host():
		return
	NetworkService.receive_match_start(seed_value, seat_dicts)
	get_tree().call_deferred("change_scene_to_file", TableConstants.TABLE_SCENE_PATH)


@rpc("any_peer", "call_remote", "reliable")
func rpc_request_play_card(action_dict: Dictionary) -> void:
	if not NetworkService.is_host():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var seat_index: int = NetworkService.get_seat_for_peer(peer_id)
	if seat_index < 0:
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
	if NetworkService.is_host():
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


func _broadcast_play(action: PlayCardAction, result: ActionResult) -> void:
	var action_dict: Dictionary = NetworkPlayPayload.action_to_dict(action)
	var result_dict: Dictionary = NetworkPlayPayload.play_result_to_dict(result.play_result)
	for peer_id: int in multiplayer.get_peers():
		rpc_apply_play.rpc_id(peer_id, action_dict, result_dict)
