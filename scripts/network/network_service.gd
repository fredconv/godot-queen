extends Node
## NetworkService (autoload)
## Façade ENet P2P + lobby LAN/online. Logique découpée (IDEA-00009) :
## NetworkLobbyBook · NetworkMatchDisconnectCoordinator · NetworkOnlineBridge · LanGameDiscovery.


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
const _LanGameDiscovery = preload("res://scripts/network/lan_game_discovery.gd")
const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")
const _OnlineLobbyRegistry = preload("res://scripts/network/online_lobby_registry.gd")

var _book: NetworkLobbyBook = NetworkLobbyBook.new()
var _disconnect: NetworkMatchDisconnectCoordinator = NetworkMatchDisconnectCoordinator.new()
var _online: NetworkOnlineBridge = NetworkOnlineBridge.new()
var _lan_discovery: RefCounted
var _is_host: bool = false
var _is_connected: bool = false
var _peer: ENetMultiplayerPeer


## API publique — état lobby (rétrocompat)
var lobby: LobbyState:
	get:
		return _book.lobby
	set(value):
		_book.lobby = value

var peer_to_seat: Dictionary:
	get:
		return _book.peer_to_seat
	set(value):
		_book.peer_to_seat = value

var local_seat_index: int:
	get:
		return _book.local_seat_index
	set(value):
		_book.local_seat_index = value


func _ready() -> void:
	_lan_discovery = _LanGameDiscovery.new()
	_online.setup(_OnlineLobbyRegistry.new())
	_online.lookup_completed.connect(func(session: Dictionary) -> void: online_lobby_lookup_completed.emit(session))
	_online.lookup_failed.connect(func() -> void: online_lobby_lookup_failed.emit())
	_online.search_completed.connect(func(sessions: Array) -> void: online_lobby_search_completed.emit(sessions))
	_online.search_failed.connect(func() -> void: online_lobby_search_failed.emit())
	_online.registry_changed.connect(func() -> void: online_registry_changed.emit())
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_lan_discovery.entries_changed.connect(_on_lan_entries_changed)
	set_process(false)


func _process(delta: float) -> void:
	_lan_discovery.poll(delta)
	if _is_host:
		_tick_disconnect_state(delta)
		_online.tick_heartbeat(
			delta,
			self,
			PlayerProfileService.get_display_name(),
			get_connected_human_count()
		)


func is_online_registry_available() -> bool:
	return _online.is_available()


func get_host_invite_code() -> String:
	return _online.invite_code


func get_online_search_results() -> Array[Dictionary]:
	return _online.search_results.duplicate()


func set_host_public_address(public_address: String) -> void:
	_online.public_address = public_address.strip_edges()
	if _online.try_start(_is_host):
		_online.publish(self, PlayerProfileService.get_display_name(), get_connected_human_count())
		_update_process_enabled()


func prepare_host_invite_code() -> String:
	if _online.invite_code.is_empty():
		_online.invite_code = _InviteCodeGenerator.generate()
		host_invite_code_changed.emit(_online.invite_code)
	return _online.invite_code


func lookup_lobby_by_invite_code(invite_code: String) -> void:
	_online.lookup_by_invite_code(self, invite_code)


func search_lobbies_by_host_name(query: String) -> void:
	_online.search_by_host_name(self, query)


func clear_online_search_results() -> void:
	_online.clear_search_results()


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
	_online.hosted_port = port
	_online.invite_code = _InviteCodeGenerator.generate()
	host_invite_code_changed.emit(_online.invite_code)
	_book.register_host_player(
		multiplayer.get_unique_id(),
		PlayerProfileService.get_display_name(),
		PlayerProfileService.get_player_id()
	)
	lobby_state_changed.emit()
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
	_disconnect.reset()
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
	return _book.get_seat_for_peer(peer_id)


func get_peer_for_seat(seat_index: int) -> int:
	return _book.get_peer_for_seat(seat_index)


func get_connected_human_count() -> int:
	return _book.get_connected_human_count()


func is_seat_pending_reconnect(seat_index: int) -> bool:
	return _disconnect.is_pending(seat_index)


func is_player_disconnected(seat_index: int) -> bool:
	return _book.is_human_disconnected(seat_index)


func build_launch_config_for_local() -> MatchLaunchConfig:
	var config := MatchLaunchConfig.new()
	config.seat_assignments = _book.lobby.seats.duplicate()
	if _is_host:
		config.mode = MatchMode.Type.ONLINE_HOST
		config.active_human_seat_index = 0
	else:
		config.mode = MatchMode.Type.ONLINE_CLIENT
		config.active_human_seat_index = _book.local_seat_index
	return config


func host_start_match() -> Error:
	if not _is_host:
		return ERR_UNAUTHORIZED
	var lobby_service := LobbyService.new()
	lobby_service.state = _book.lobby
	var error_code: StringName = lobby_service.start_match()
	if error_code != LobbyState.ERROR_NONE:
		return ERR_UNAVAILABLE
	var seed_value: int = randi()
	var launch_config: MatchLaunchConfig = SeatSetup.create_online_from_lobby(
		_book.lobby, true, _book.local_seat_index
	)
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


func apply_lobby_from_network(state_dict: Dictionary) -> void:
	_book.apply_from_network(state_dict, PlayerProfileService.get_player_id())
	lobby_state_changed.emit()


func apply_remote_player_profile(peer_id: int, display_name: String, local_player_id: String) -> void:
	if not _is_host:
		return
	var reconnect_seat: int = _disconnect.find_pending_seat_by_player_id(local_player_id)
	if reconnect_seat >= 0:
		if _disconnect.complete_reconnection(
			_book, peer_id, reconnect_seat, display_name, local_player_id
		):
			lobby_state_changed.emit()
			NetworkMatchRelay.broadcast_peer_reconnected(reconnect_seat, display_name)
		return
	var seat_index: int = _book.get_seat_for_peer(peer_id)
	if seat_index < 0:
		return
	var profile: PlayerProfile = _book.get_profile(seat_index)
	if profile == null:
		return
	profile.display_name = display_name
	profile.local_player_id = local_player_id
	profile.is_ready = true
	lobby_state_changed.emit()
	NetworkMatchRelay.rpc_lobby_sync.rpc(_book.lobby.to_dict())


func receive_match_start(seed_value: int, seat_dicts: Array) -> void:
	_book.apply_match_start_seats(seat_dicts, PlayerProfileService.get_player_id())
	var launch_config: MatchLaunchConfig = SeatSetup.create_online_from_lobby(
		_book.lobby, false, _book.local_seat_index
	)
	GameSession.set_launch_config(launch_config)
	GameSession.online_match_seed = seed_value
	set_process(true)
	match_start_received.emit(seed_value, launch_config)


func stop_online_registry() -> void:
	_online.stop(self)
	_update_process_enabled()


func _reset_lobby() -> void:
	_book.reset()


func _on_peer_connected(peer_id: int) -> void:
	if not _is_host:
		return
	var seat_index: int = _book.assign_connecting_peer(peer_id)
	if seat_index < 0:
		DebugService.log_warning("NetworkService: table pleine, refus peer %d" % peer_id)
		return
	lobby_state_changed.emit()
	_update_lan_advertising_from_lobby()
	peer_connected_to_lobby.emit(peer_id)
	NetworkMatchRelay.rpc_lobby_sync.rpc_id(peer_id, _book.lobby.to_dict())


func _on_peer_disconnected(peer_id: int) -> void:
	if not _is_host:
		return
	var seat_index: int = _book.erase_peer(peer_id)
	if seat_index < 0:
		return
	var profile: PlayerProfile = _book.get_profile(seat_index)
	if profile == null:
		return
	if GameSession.match_in_progress and profile.is_human:
		_disconnect.begin_match_disconnect(seat_index, profile)
		seat_pending_disconnect.emit(seat_index, profile.display_name)
		NetworkMatchRelay.broadcast_disconnect_event(seat_index, profile.display_name)
		return
	_book.clear_seat(seat_index)
	lobby_state_changed.emit()
	_update_lan_advertising_from_lobby()
	peer_disconnected_from_lobby.emit(peer_id)
	NetworkMatchRelay.rpc_lobby_sync.rpc(_book.lobby.to_dict())


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


func _tick_disconnect_state(delta: float) -> void:
	var tick_result: Dictionary = _disconnect.tick(delta, GameSession.match_in_progress)
	var expired: Array = tick_result.get("expired", [])
	for seat_index_variant: Variant in expired:
		_replace_seat_with_ai(int(seat_index_variant))
	if not bool(tick_result.get("broadcast_countdown", false)):
		return
	var pending: Array = tick_result.get("pending_indices", [])
	for seat_index_variant: Variant in pending:
		var seat_index: int = int(seat_index_variant)
		var display_name: String = _disconnect.get_display_name(seat_index)
		var remaining: int = int(ceil(_disconnect.get_remaining_sec(seat_index)))
		NetworkMatchRelay.broadcast_countdown(seat_index, display_name, remaining)


func _replace_seat_with_ai(seat_index: int) -> void:
	var display_name: String = _disconnect.apply_ai_replacement(_book, seat_index)
	if display_name.is_empty():
		return
	var host_controller: HostMatchController = NetworkMatchRelay.get_host_controller()
	if host_controller != null:
		SeatSetup.apply_ai_to_match_manager(host_controller.get_match_manager(), _book.lobby.seats)
	NetworkMatchRelay.broadcast_seat_replaced_by_ai(seat_index, display_name)


func _on_lan_entries_changed() -> void:
	lan_sessions_changed.emit()


func _update_lan_advertising_from_lobby() -> void:
	if not _is_host:
		return
	update_lan_advertising_player_count(get_connected_human_count())
	if _online.active:
		_online.publish(self, PlayerProfileService.get_display_name(), get_connected_human_count())


func _update_process_enabled() -> void:
	set_process(_is_host or _lan_discovery.is_active() or _online.active)
