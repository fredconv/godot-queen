extends Node
## NetworkService (autoload)
## Transport ENet P2P, lobby LAN et mapping peer ↔ siège.


signal connection_succeeded
signal connection_failed
signal peer_connected_to_lobby(peer_id: int)
signal peer_disconnected_from_lobby(peer_id: int)
signal lobby_state_changed
signal match_start_received(seed_value: int, launch_config: MatchLaunchConfig)
signal seat_pending_disconnect(seat_index: int, display_name: String)

const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 3
const COUNTDOWN_BROADCAST_INTERVAL_SEC: float = 1.0

var lobby: LobbyState = LobbyState.new()
var peer_to_seat: Dictionary = {}
var local_seat_index: int = -1
var _is_host: bool = false
var _is_connected: bool = false
var _peer: ENetMultiplayerPeer
var _disconnect_state: DisconnectState = DisconnectState.new()
var _countdown_broadcast_accum: float = 0.0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	set_process(false)


func _process(delta: float) -> void:
	if not _is_host:
		return
	_tick_disconnect_state(delta)


func host_game(port: int = DEFAULT_PORT) -> Error:
	_reset_lobby()
	var peer := ENetMultiplayerPeer.new()
	var error_code: Error = peer.create_server(port, MAX_CLIENTS)
	if error_code != OK:
		DebugService.log_error("NetworkService.host_game failed: %s" % error_string(error_code))
		return error_code
	multiplayer.multiplayer_peer = peer
	_peer = peer
	_is_host = true
	_is_connected = true
	_register_host_player()
	DebugService.log_info("NetworkService hosting on port %d" % port)
	return OK


func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	_reset_lobby()
	var peer := ENetMultiplayerPeer.new()
	var error_code: Error = peer.create_client(address, port)
	if error_code != OK:
		DebugService.log_error("NetworkService.join_game failed: %s" % error_string(error_code))
		return error_code
	multiplayer.multiplayer_peer = peer
	_peer = peer
	_is_host = false
	_is_connected = false
	DebugService.log_info("NetworkService connecting to %s:%d" % [address, port])
	return OK


func disconnect_from_host() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_peer = null
	_is_host = false
	_is_connected = false
	_disconnect_state = DisconnectState.new()
	set_process(false)
	_reset_lobby()


func is_host() -> bool:
	return _is_host


func is_online() -> bool:
	return multiplayer.multiplayer_peer != null and _is_connected


func is_online_client() -> bool:
	return is_online() and not _is_host


func get_peer_id() -> int:
	return multiplayer.get_unique_id()


func get_seat_for_peer(peer_id: int) -> int:
	return int(peer_to_seat.get(peer_id, -1))


func get_peer_for_seat(seat_index: int) -> int:
	for peer_id: int in peer_to_seat.keys():
		if int(peer_to_seat[peer_id]) == seat_index:
			return peer_id
	return -1


func get_connected_human_count() -> int:
	var count: int = 0
	for assignment: SeatAssignment in lobby.seats:
		if assignment.profile != null and assignment.profile.is_human and assignment.profile.is_connected:
			count += 1
	return count


func is_seat_pending_reconnect(seat_index: int) -> bool:
	return _disconnect_state.is_pending(seat_index)


func is_player_disconnected(seat_index: int) -> bool:
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return false
	var assignment: SeatAssignment = lobby.seats[seat_index]
	if assignment.profile == null:
		return false
	return assignment.profile.is_human and not assignment.profile.is_connected


func build_launch_config_for_local() -> MatchLaunchConfig:
	var config := MatchLaunchConfig.new()
	config.seat_assignments = lobby.seats.duplicate()
	if _is_host:
		config.mode = MatchMode.Type.ONLINE_HOST
		config.active_human_seat_index = 0
	else:
		config.mode = MatchMode.Type.ONLINE_CLIENT
		config.active_human_seat_index = local_seat_index
	return config


func host_start_match() -> Error:
	if not _is_host:
		return ERR_UNAUTHORIZED
	var lobby_service := LobbyService.new()
	lobby_service.state = lobby
	var error_code: StringName = lobby_service.start_match()
	if error_code != LobbyState.ERROR_NONE:
		return ERR_UNAVAILABLE
	var seed_value: int = randi()
	var launch_config: MatchLaunchConfig = SeatSetup.create_online_from_lobby(lobby, true, local_seat_index)
	launch_config.mode = MatchMode.Type.ONLINE_HOST
	var seat_dicts: Array = []
	for assignment: SeatAssignment in launch_config.seat_assignments:
		seat_dicts.append(assignment.to_dict())
	NetworkMatchRelay.rpc_start_match.rpc(seed_value, seat_dicts)
	GameSession.set_launch_config(launch_config)
	GameSession.online_match_seed = seed_value
	set_process(true)
	match_start_received.emit(seed_value, launch_config)
	return OK


func _reset_lobby() -> void:
	lobby = LobbyState.new()
	lobby.seats = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		lobby.seats.append(SeatAssignment.new(seat_index, null))
	peer_to_seat.clear()
	local_seat_index = -1


func _register_host_player() -> void:
	var host_profile := PlayerProfile.new()
	host_profile.seat_index = 0
	host_profile.display_name = PlayerProfileService.get_display_name()
	host_profile.local_player_id = PlayerProfileService.get_player_id()
	host_profile.peer_id = multiplayer.get_unique_id()
	host_profile.is_human = true
	host_profile.is_ai = false
	host_profile.is_connected = true
	host_profile.is_ready = true
	lobby.seats[0] = SeatAssignment.new(0, host_profile)
	peer_to_seat[multiplayer.get_unique_id()] = 0
	local_seat_index = 0
	lobby_state_changed.emit()


func _on_peer_connected(peer_id: int) -> void:
	if not _is_host:
		return
	var seat_index: int = _find_free_seat()
	if seat_index < 0:
		DebugService.log_warning("NetworkService: table pleine, refus peer %d" % peer_id)
		return
	peer_to_seat[peer_id] = seat_index
	var profile := PlayerProfile.new()
	profile.seat_index = seat_index
	profile.display_name = "Player %d" % (seat_index + 1)
	profile.peer_id = peer_id
	profile.is_human = true
	profile.is_ai = false
	profile.is_connected = true
	profile.is_ready = false
	lobby.seats[seat_index] = SeatAssignment.new(seat_index, profile)
	lobby_state_changed.emit()
	peer_connected_to_lobby.emit(peer_id)
	NetworkMatchRelay.rpc_lobby_sync.rpc_id(peer_id, lobby.to_dict())


func _on_peer_disconnected(peer_id: int) -> void:
	if not _is_host:
		return
	var seat_index: int = int(peer_to_seat.get(peer_id, -1))
	peer_to_seat.erase(peer_id)
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return
	var assignment: SeatAssignment = lobby.seats[seat_index]
	if assignment.profile == null:
		return
	if GameSession.match_in_progress and assignment.profile.is_human:
		_handle_match_disconnect(seat_index, assignment.profile)
		return
	lobby.seats[seat_index] = SeatAssignment.new(seat_index, null)
	lobby_state_changed.emit()
	peer_disconnected_from_lobby.emit(peer_id)
	NetworkMatchRelay.rpc_lobby_sync.rpc(lobby.to_dict())


func _on_connected_to_server() -> void:
	_is_connected = true
	connection_succeeded.emit()
	NetworkMatchRelay.rpc_register_player.rpc_id(
		1,
		PlayerProfileService.get_display_name(),
		PlayerProfileService.get_player_id()
	)


func _on_connection_failed() -> void:
	_is_connected = false
	connection_failed.emit()
	DebugService.log_error("NetworkService: connexion échouée")


func _on_server_disconnected() -> void:
	_is_connected = false
	disconnect_from_host()
	DebugService.log_warning("NetworkService: serveur déconnecté")


func _find_free_seat() -> int:
	for seat_index in range(1, HeartsRules.PLAYER_COUNT):
		var assignment: SeatAssignment = lobby.seats[seat_index]
		if assignment.profile == null:
			return seat_index
	return -1


func apply_lobby_from_network(state_dict: Dictionary) -> void:
	lobby = LobbyState.from_dict(state_dict)
	peer_to_seat.clear()
	for assignment: SeatAssignment in lobby.seats:
		if assignment.profile != null and assignment.profile.peer_id > 0:
			peer_to_seat[assignment.profile.peer_id] = assignment.seat_index
			if assignment.profile.local_player_id == PlayerProfileService.get_player_id():
				local_seat_index = assignment.seat_index
	lobby_state_changed.emit()


func apply_remote_player_profile(peer_id: int, display_name: String, local_player_id: String) -> void:
	if not _is_host:
		return
	var reconnect_seat: int = _disconnect_state.find_pending_seat_by_player_id(local_player_id)
	if reconnect_seat >= 0:
		_complete_reconnection(peer_id, reconnect_seat, display_name, local_player_id)
		return
	var seat_index: int = int(peer_to_seat.get(peer_id, -1))
	if seat_index < 0:
		return
	var profile := lobby.seats[seat_index].profile
	if profile == null:
		return
	profile.display_name = display_name
	profile.local_player_id = local_player_id
	profile.is_ready = true
	lobby_state_changed.emit()
	NetworkMatchRelay.rpc_lobby_sync.rpc(lobby.to_dict())


func receive_match_start(seed_value: int, seat_dicts: Array) -> void:
	var assignments: Array[SeatAssignment] = []
	for entry in seat_dicts:
		if entry is Dictionary:
			assignments.append(SeatAssignment.from_dict(entry))
	lobby.seats = assignments
	for assignment: SeatAssignment in assignments:
		if assignment.profile != null and assignment.profile.local_player_id == PlayerProfileService.get_player_id():
			local_seat_index = assignment.seat_index
	var launch_config: MatchLaunchConfig = SeatSetup.create_online_from_lobby(lobby, false, local_seat_index)
	GameSession.set_launch_config(launch_config)
	GameSession.online_match_seed = seed_value
	set_process(true)
	match_start_received.emit(seed_value, launch_config)


func _handle_match_disconnect(seat_index: int, profile: PlayerProfile) -> void:
	profile.is_connected = false
	_disconnect_state.begin_disconnect(seat_index, profile.display_name, profile.local_player_id)
	seat_pending_disconnect.emit(seat_index, profile.display_name)
	NetworkMatchRelay.broadcast_disconnect_event(seat_index, profile.display_name)
	_countdown_broadcast_accum = 0.0


func _complete_reconnection(
	peer_id: int,
	seat_index: int,
	display_name: String,
	local_player_id: String
) -> void:
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return
	var assignment: SeatAssignment = lobby.seats[seat_index]
	if assignment.profile == null:
		return
	_disconnect_state.cancel_reconnect(seat_index)
	assignment.profile.display_name = display_name
	assignment.profile.local_player_id = local_player_id
	assignment.profile.peer_id = peer_id
	assignment.profile.is_connected = true
	assignment.profile.is_ready = true
	peer_to_seat[peer_id] = seat_index
	lobby_state_changed.emit()
	NetworkMatchRelay.broadcast_peer_reconnected(seat_index, display_name)


func _tick_disconnect_state(delta: float) -> void:
	if not GameSession.match_in_progress:
		return
	var expired: Array[int] = _disconnect_state.tick(delta)
	for seat_index in expired:
		_replace_seat_with_ai(seat_index)
	_countdown_broadcast_accum += delta
	if _countdown_broadcast_accum < COUNTDOWN_BROADCAST_INTERVAL_SEC:
		return
	_countdown_broadcast_accum = 0.0
	for seat_index in _disconnect_state.get_pending_seat_indices():
		var display_name: String = _disconnect_state.get_display_name(seat_index)
		var remaining: int = int(ceil(_disconnect_state.get_remaining_sec(seat_index)))
		NetworkMatchRelay.broadcast_countdown(seat_index, display_name, remaining)


func _replace_seat_with_ai(seat_index: int) -> void:
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return
	var assignment: SeatAssignment = lobby.seats[seat_index]
	if assignment.profile == null:
		return
	var display_name: String = assignment.profile.display_name
	_disconnect_state.mark_replaced_by_ai(seat_index)
	assignment.profile.is_human = false
	assignment.profile.is_ai = true
	assignment.profile.is_connected = false
	assignment.profile.peer_id = -1
	var host_controller: HostMatchController = NetworkMatchRelay.get_host_controller()
	if host_controller != null:
		SeatSetup.apply_ai_to_match_manager(host_controller.get_match_manager(), lobby.seats)
	NetworkMatchRelay.broadcast_seat_replaced_by_ai(seat_index, display_name)
