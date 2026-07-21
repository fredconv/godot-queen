class_name NetworkOnlineBridge
extends RefCounted
## Pont registry online (lookup / search / publish / heartbeat).
## Signaux remontés vers NetworkService.


signal lookup_completed(session: Dictionary)
signal lookup_failed
signal search_completed(sessions: Array)
signal search_failed
signal registry_changed

const _OnlineLobbyRegistry = preload("res://scripts/network/online_lobby_registry.gd")

var search_results: Array[Dictionary] = []
var invite_code: String = ""
var public_address: String = ""
var hosted_port: int = 7777
var active: bool = false

var _registry: RefCounted
var _heartbeat_accum: float = 0.0


func setup(registry: RefCounted) -> void:
	_registry = registry
	if _registry.lookup_succeeded.is_connected(_on_lookup_succeeded):
		return
	_registry.lookup_succeeded.connect(_on_lookup_succeeded)
	_registry.lookup_failed.connect(_on_lookup_failed)
	_registry.search_succeeded.connect(_on_search_succeeded)
	_registry.search_failed.connect(_on_search_failed)


func is_available() -> bool:
	return _registry.is_available()


func clear_search_results() -> void:
	search_results.clear()
	registry_changed.emit()


func lookup_by_invite_code(host: Node, code: String) -> void:
	_registry.lookup_by_invite_code(host, code)


func search_by_host_name(host: Node, query: String) -> void:
	_registry.search_by_host_name(host, query)


func stop(host: Node) -> void:
	if invite_code.is_empty():
		active = false
		return
	var code: String = invite_code
	invite_code = ""
	public_address = ""
	hosted_port = 7777
	active = false
	_heartbeat_accum = 0.0
	_registry.unregister_lobby(host, code)


func try_start(is_host: bool) -> bool:
	if not is_host or invite_code.is_empty() or public_address.is_empty():
		return false
	if not is_available():
		return false
	active = true
	_heartbeat_accum = OnlineRegistryConfig.load_default().heartbeat_interval_sec
	return true


func publish(host: Node, host_name: String, player_count: int) -> void:
	if not active:
		return
	_registry.register_lobby(
		host,
		{
			"invite_code": invite_code,
			"host_name": host_name,
			"host_address": public_address,
			"port": hosted_port,
			"player_count": player_count,
			"max_players": HeartsRules.PLAYER_COUNT,
		}
	)


func tick_heartbeat(delta: float, host: Node, host_name: String, player_count: int) -> void:
	if not active:
		return
	_heartbeat_accum += delta
	if _heartbeat_accum < OnlineRegistryConfig.load_default().heartbeat_interval_sec:
		return
	_heartbeat_accum = 0.0
	publish(host, host_name, player_count)


func _on_lookup_succeeded(entry: Dictionary) -> void:
	var session: Dictionary = _OnlineLobbyRegistry.entry_to_session(entry)
	search_results = [session]
	lookup_completed.emit(session)
	registry_changed.emit()


func _on_lookup_failed() -> void:
	search_results.clear()
	lookup_failed.emit()
	registry_changed.emit()


func _on_search_succeeded(entries: Array) -> void:
	search_results.clear()
	var sessions: Array = []
	for entry: Variant in entries:
		if entry is Dictionary:
			var session: Dictionary = _OnlineLobbyRegistry.entry_to_session(entry)
			search_results.append(session)
			sessions.append(session)
	search_completed.emit(sessions)
	registry_changed.emit()


func _on_search_failed() -> void:
	search_results.clear()
	search_failed.emit()
	registry_changed.emit()
