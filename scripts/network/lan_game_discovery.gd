class_name LanGameDiscovery
extends RefCounted
## Annonce et détection de parties LAN via UDP broadcast (port dédié, distinct d'ENet).


const MAGIC: String = "dame-de-pique-v1"
const DISCOVERY_PORT: int = 7778
const BROADCAST_INTERVAL_SEC: float = 1.25
const ENTRY_TTL_SEC: float = 4.5
const BROADCAST_ADDRESS: String = "255.255.255.255"

signal entries_changed

var _listener: PacketPeerUDP = null
var _broadcaster: PacketPeerUDP = null
var _entries: Dictionary = {}
var _listening: bool = false
var _advertising: bool = false
var _advertise_host_name: String = ""
var _advertise_game_port: int = 7777
var _advertise_player_count: int = 1
var _advertise_max_players: int = 4
var _broadcast_accum: float = 0.0


func is_active() -> bool:
	return _listening or _advertising


func start_listening() -> Error:
	if _listening:
		return OK
	stop_listening()
	var listener := PacketPeerUDP.new()
	var error_code: Error = listener.bind(DISCOVERY_PORT)
	if error_code != OK:
		listener.close()
		DebugService.log_error("LanGameDiscovery.start_listening failed: %s" % error_string(error_code))
		return error_code
	_listener = listener
	_listening = true
	return OK


func stop_listening() -> void:
	_listening = false
	_entries.clear()
	if _listener != null:
		_listener.close()
		_listener = null
	entries_changed.emit()


func start_advertising(
	host_name: String,
	game_port: int,
	player_count: int,
	max_players: int = HeartsRules.PLAYER_COUNT
) -> Error:
	stop_advertising()
	var broadcaster := PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	var error_code: Error = broadcaster.bind(0)
	if error_code != OK:
		broadcaster.close()
		DebugService.log_error("LanGameDiscovery.start_advertising failed: %s" % error_string(error_code))
		return error_code
	_broadcaster = broadcaster
	_advertising = true
	_advertise_host_name = host_name.strip_edges()
	if _advertise_host_name.is_empty():
		_advertise_host_name = "Host"
	_advertise_game_port = game_port
	_advertise_player_count = clampi(player_count, 1, max_players)
	_advertise_max_players = clampi(max_players, 1, 99)
	_broadcast_accum = BROADCAST_INTERVAL_SEC
	_send_beacon()
	return OK


func stop_advertising() -> void:
	_advertising = false
	if _broadcaster != null:
		_broadcaster.close()
		_broadcaster = null


func set_player_count(player_count: int) -> void:
	_advertise_player_count = clampi(player_count, 1, _advertise_max_players)


func get_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var sorted_ids: Array = _entries.keys()
	sorted_ids.sort()
	for entry_id in sorted_ids:
		result.append(_entries[entry_id].duplicate())
	return result


func poll(delta: float) -> void:
	_poll_listener()
	if not _advertising:
		return
	_broadcast_accum += delta
	if _broadcast_accum < BROADCAST_INTERVAL_SEC:
		return
	_broadcast_accum = 0.0
	_send_beacon()


static func build_beacon_payload(
	host_name: String,
	game_port: int,
	player_count: int,
	max_players: int
) -> String:
	return JSON.stringify({
		"magic": MAGIC,
		"host_name": host_name,
		"port": game_port,
		"players": player_count,
		"max": max_players,
	})


static func parse_beacon_payload(payload: String, sender_ip: String) -> Dictionary:
	if payload.is_empty() or sender_ip.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(payload.strip_edges())
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = parsed
	if str(data.get("magic", "")) != MAGIC:
		return {}
	var port: int = int(data.get("port", 0))
	if port <= 0 or port > 65535:
		return {}
	var host_name: String = str(data.get("host_name", "")).strip_edges()
	if host_name.is_empty():
		host_name = sender_ip
	var max_players: int = clampi(int(data.get("max", HeartsRules.PLAYER_COUNT)), 1, 99)
	var players: int = clampi(int(data.get("players", 1)), 1, max_players)
	return {
		"id": "%s:%d" % [sender_ip, port],
		"address": sender_ip,
		"port": port,
		"host_name": host_name,
		"players": players,
		"max_players": max_players,
	}


func _poll_listener() -> void:
	if not _listening or _listener == null:
		return
	var changed: bool = false
	while _listener.get_available_packet_count() > 0:
		var packet: PackedByteArray = _listener.get_packet()
		var sender_ip: String = _listener.get_packet_ip()
		var entry: Dictionary = parse_beacon_payload(packet.get_string_from_utf8(), sender_ip)
		if entry.is_empty():
			continue
		entry["last_seen_sec"] = Time.get_ticks_msec() / 1000.0
		_entries[entry["id"]] = entry
		changed = true
	var now_sec: float = Time.get_ticks_msec() / 1000.0
	for entry_id: String in _entries.keys():
		var entry: Dictionary = _entries[entry_id]
		if now_sec - float(entry.get("last_seen_sec", 0.0)) > ENTRY_TTL_SEC:
			_entries.erase(entry_id)
			changed = true
	if changed:
		entries_changed.emit()


func _send_beacon() -> void:
	if _broadcaster == null:
		return
	var payload: String = build_beacon_payload(
		_advertise_host_name,
		_advertise_game_port,
		_advertise_player_count,
		_advertise_max_players
	)
	_broadcaster.set_dest_address(BROADCAST_ADDRESS, DISCOVERY_PORT)
	_broadcaster.put_packet(payload.to_utf8_buffer())
