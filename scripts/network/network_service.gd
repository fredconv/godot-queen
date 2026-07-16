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
signal lan_sessions_changed
signal online_registry_changed
signal host_invite_code_changed(invite_code: String)
signal online_lobby_lookup_completed(session: Dictionary)
signal online_lobby_lookup_failed
signal online_lobby_search_completed(sessions: Array)
signal online_lobby_search_failed

const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 3
const COUNTDOWN_BROADCAST_INTERVAL_SEC: float = 1.0
const _LanGameDiscovery = preload("res://scripts/network/lan_game_discovery.gd")
const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")
const _OnlineLobbyRegistry = preload("res://scripts/network/online_lobby_registry.gd")

var lobby: LobbyState = LobbyState.new()
var peer_to_seat: Dictionary = {}
var local_seat_index: int = -1
var _is_host: bool = false
var _is_connected: bool = false
var _peer: ENetMultiplayerPeer
var _disconnect_state: DisconnectState = DisconnectState.new()
var _countdown_broadcast_accum: float = 0.0
var _lan_discovery: RefCounted
var _online_registry: RefCounted
var _host_invite_code: String = ""
var _host_public_address: String = ""
var _hosted_port: int = DEFAULT_PORT
var _online_search_results: Array[Dictionary] = []
var _registry_heartbeat_accum: float = 0.0
var _online_registry_active: bool = false


func _ready() -> void:
	_lan_discovery = _LanGameDiscovery.new()
	_online_registry = _OnlineLobbyRegistry.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_lan_discovery.entries_changed.connect(_on_lan_entries_changed)
	_bind_online_registry_signals()
	set_process(false)


func _process(delta: float) -> void:
	_lan_discovery.poll(delta)
	if _is_host:
		_tick_disconnect_state(delta)
		_tick_online_registry(delta)


func is_online_registry_available() -> bool:
	return _online_registry.is_available()


func get_host_invite_code() -> String:
	return _host_invite_code


func get_online_search_results() -> Array[Dictionary]:
	return _online_search_results.duplicate()


func set_host_public_address(public_address: String) -> void:
	_host_public_address = public_address.strip_edges()
	_try_start_online_registry()


func prepare_host_invite_code() -> String:
	if _host_invite_code.is_empty():
		_host_invite_code = _InviteCodeGenerator.generate()
		host_invite_code_changed.emit(_host_invite_code)
	return _host_invite_code


func lookup_lobby_by_invite_code(invite_code: String) -> void:
	_online_registry.lookup_by_invite_code(self, invite_code)


func search_lobbies_by_host_name(query: String) -> void:
	_online_registry.search_by_host_name(self, query)


func clear_online_search_results() -> void:
	_online_search_results.clear()
	online_registry_changed.emit()


func start_lan_browsing() -> Error:
	var error_code: Error = _lan_discovery.start_listening()
	_update_process_enabled()
	return error_code


func stop_lan_browsing() -> void:
	_lan_discovery.stop_listening()
	_update_process_enabled()


func get_lan_sessions() -> Array[Dictionary]:
	return _lan_discovery.get_entries()


func start_lan_advertising(host_name: String, game_port: int, player_count: int) -> Error:
	var error_code: Error = _lan_discovery.start_advertising(
		host_name,
		game_port,
		player_count,
		HeartsRules.PLAYER_COUNT
	)
	_update_process_enabled()
	return error_code


func stop_lan_advertising() -> void:
	_lan_discovery.stop_advertising()
	_update_process_enabled()


func update_lan_advertising_player_count(player_count: int) -> void:
	_lan_discovery.set_player_count(player_count)


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
	_hosted_port = port
	_host_invite_code = _InviteCodeGenerator.generate()
	host_invite_code_changed.emit(_host_invite_code)
	_register_host_player()
	start_lan_advertising(
		PlayerProfileService.get_display_name(),
		port,
		get_connected_human_count()
	)
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
	stop_online_registry()
	stop_lan_advertising()
	stop_lan_browsing()
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_peer = null
	_is_host = false
	_is_connected = false
	_disconnect_state = DisconnectState.new()
	_update_process_enabled()
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
		if assignment.profile != null and assignment.profile.is_human and assignment.profile.peer_connected:
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
	return assignment.profile.is_human and not assignment.profile.peer_connected


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
	host_profile.peer_connected = true
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
	profile.peer_connected = true
	profile.is_ready = false
	lobby.seats[seat_index] = SeatAssignment.new(seat_index, profile)
	lobby_state_changed.emit()
	_update_lan_advertising_from_lobby()
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
	_update_lan_advertising_from_lobby()
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
	profile.peer_connected = false
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
	assignment.profile.peer_connected = true
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
	assignment.profile.peer_connected = false
	assignment.profile.peer_id = -1
	var host_controller: HostMatchController = NetworkMatchRelay.get_host_controller()
	if host_controller != null:
		SeatSetup.apply_ai_to_match_manager(host_controller.get_match_manager(), lobby.seats)
	NetworkMatchRelay.broadcast_seat_replaced_by_ai(seat_index, display_name)


func _on_lan_entries_changed() -> void:
	lan_sessions_changed.emit()


func _update_lan_advertising_from_lobby() -> void:
	if not _is_host:
		return
	update_lan_advertising_player_count(get_connected_human_count())
	if _online_registry_active:
		_publish_online_registry()


func _update_process_enabled() -> void:
	set_process(_is_host or _lan_discovery.is_active() or _online_registry_active)


func stop_online_registry() -> void:
	if _host_invite_code.is_empty():
		_online_registry_active = false
		_update_process_enabled()
		return
	var invite_code: String = _host_invite_code
	_host_invite_code = ""
	_host_public_address = ""
	_hosted_port = DEFAULT_PORT
	_online_registry_active = false
	_registry_heartbeat_accum = 0.0
	_online_registry.unregister_lobby(self, invite_code)
	_update_process_enabled()


func _try_start_online_registry() -> void:
	if not _is_host or _host_invite_code.is_empty() or _host_public_address.is_empty():
		return
	if not is_online_registry_available():
		return
	_online_registry_active = true
	_registry_heartbeat_accum = OnlineRegistryConfig.load_default().heartbeat_interval_sec
	_publish_online_registry()
	_update_process_enabled()


func _publish_online_registry() -> void:
	if not _online_registry_active:
		return
	_online_registry.register_lobby(
		self,
		{
			"invite_code": _host_invite_code,
			"host_name": PlayerProfileService.get_display_name(),
			"host_address": _host_public_address,
			"port": _hosted_port,
			"player_count": get_connected_human_count(),
			"max_players": HeartsRules.PLAYER_COUNT,
		}
	)


func _tick_online_registry(delta: float) -> void:
	if not _online_registry_active:
		return
	_registry_heartbeat_accum += delta
	if _registry_heartbeat_accum < OnlineRegistryConfig.load_default().heartbeat_interval_sec:
		return
	_registry_heartbeat_accum = 0.0
	_publish_online_registry()


func _bind_online_registry_signals() -> void:
	if _online_registry.lookup_succeeded.is_connected(_on_online_lookup_succeeded):
		return
	_online_registry.lookup_succeeded.connect(_on_online_lookup_succeeded)
	_online_registry.lookup_failed.connect(_on_online_lookup_failed)
	_online_registry.search_succeeded.connect(_on_online_search_succeeded)
	_online_registry.search_failed.connect(_on_online_search_failed)


func _on_online_lookup_succeeded(entry: Dictionary) -> void:
	var session: Dictionary = _OnlineLobbyRegistry.entry_to_session(entry)
	_online_search_results = [session]
	online_lobby_lookup_completed.emit(session)
	online_registry_changed.emit()


func _on_online_lookup_failed() -> void:
	_online_search_results.clear()
	online_lobby_lookup_failed.emit()
	online_registry_changed.emit()


func _on_online_search_succeeded(entries: Array) -> void:
	_online_search_results.clear()
	var sessions: Array = []
	for entry: Variant in entries:
		if entry is Dictionary:
			var session: Dictionary = _OnlineLobbyRegistry.entry_to_session(entry)
			_online_search_results.append(session)
			sessions.append(session)
	online_lobby_search_completed.emit(sessions)
	online_registry_changed.emit()


func _on_online_search_failed() -> void:
	_online_search_results.clear()
	online_lobby_search_failed.emit()
	online_registry_changed.emit()
