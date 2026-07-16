class_name OnlineLobbyRegistry
extends RefCounted
## Registre HTTP des parties en ligne (Supabase PostgREST).


signal register_succeeded
signal register_failed
signal unregister_succeeded
signal unregister_failed
signal lookup_succeeded(entry: Dictionary)
signal lookup_failed
signal search_succeeded(entries: Array)
signal search_failed

const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")
const _INVALID_RESPONSE_CODE: int = 0

var _config: OnlineRegistryConfig = OnlineRegistryConfig.load_default()


func is_available() -> bool:
	return _config.is_configured()


func register_lobby(owner: Node, entry: Dictionary) -> void:
	if not is_available():
		register_failed.emit()
		return
	var body: String = JSON.stringify(_entry_to_payload(entry))
	_send_request(
		owner,
		HTTPClient.METHOD_POST,
		_config.get_rest_url(),
		body,
		{"Prefer": "resolution=merge-duplicates"},
		func(response_code: int, _body: PackedByteArray) -> void:
			if response_code >= 200 and response_code < 300:
				register_succeeded.emit()
			else:
				register_failed.emit()
	)


func unregister_lobby(owner: Node, invite_code: String) -> void:
	if not is_available() or invite_code.is_empty():
		unregister_failed.emit()
		return
	var normalized_code: String = _InviteCodeGenerator.normalize_input(invite_code)
	if normalized_code.is_empty():
		unregister_failed.emit()
		return
	var url: String = "%s?invite_code=eq.%s" % [_config.get_rest_url(), normalized_code.uri_encode()]
	_send_request(
		owner,
		HTTPClient.METHOD_DELETE,
		url,
		"",
		{},
		func(response_code: int, _body: PackedByteArray) -> void:
			if response_code >= 200 and response_code < 300:
				unregister_succeeded.emit()
			else:
				unregister_failed.emit()
	)


func lookup_by_invite_code(owner: Node, invite_code: String) -> void:
	if not is_available():
		lookup_failed.emit()
		return
	var normalized_code: String = _InviteCodeGenerator.normalize_input(invite_code)
	if normalized_code.is_empty():
		lookup_failed.emit()
		return
	var url: String = (
		"%s?invite_code=eq.%s&select=invite_code,host_name,host_address,port,player_count,max_players,updated_at"
		% [_config.get_rest_url(), normalized_code.uri_encode()]
	)
	_send_request(
		owner,
		HTTPClient.METHOD_GET,
		url,
		"",
		{},
		func(response_code: int, body: PackedByteArray) -> void:
			if response_code != HTTPClient.RESPONSE_OK:
				lookup_failed.emit()
				return
			var entries: Array = _parse_entries(body.get_string_from_utf8())
			if entries.is_empty():
				lookup_failed.emit()
				return
			lookup_succeeded.emit(entries[0])
	)


func search_by_host_name(owner: Node, query: String) -> void:
	if not is_available():
		search_failed.emit()
		return
	var trimmed_query: String = query.strip_edges()
	if trimmed_query.length() < 2:
		search_failed.emit()
		return
	var min_updated_at: String = _format_timestamp_utc(Time.get_unix_time_from_system() - _config.lobby_max_age_sec)
	var encoded_query: String = "*%s*" % trimmed_query
	var url: String = (
		"%s?host_name=ilike.%s&updated_at=gte.%s"
		+ "&select=invite_code,host_name,host_address,port,player_count,max_players,updated_at"
		+ "&order=updated_at.desc&limit=12"
		% [_config.get_rest_url(), encoded_query, min_updated_at.uri_encode()]
	)
	_send_request(
		owner,
		HTTPClient.METHOD_GET,
		url,
		"",
		{},
		func(response_code: int, body: PackedByteArray) -> void:
			if response_code != HTTPClient.RESPONSE_OK:
				search_failed.emit()
				return
			search_succeeded.emit(_parse_entries(body.get_string_from_utf8()))
	)


static func entry_to_session(entry: Dictionary) -> Dictionary:
	return {
		"source": "online",
		"id": "online:%s" % str(entry.get("invite_code", "")),
		"invite_code": str(entry.get("invite_code", "")),
		"host_name": str(entry.get("host_name", "")),
		"address": str(entry.get("host_address", "")),
		"port": int(entry.get("port", NetworkService.DEFAULT_PORT)),
		"players": int(entry.get("player_count", entry.get("players", 1))),
		"max_players": int(entry.get("max_players", HeartsRules.PLAYER_COUNT)),
	}


static func _entry_to_payload(entry: Dictionary) -> Dictionary:
	return {
		"invite_code": str(entry.get("invite_code", "")),
		"host_name": str(entry.get("host_name", "")),
		"host_address": str(entry.get("host_address", "")),
		"port": int(entry.get("port", NetworkService.DEFAULT_PORT)),
		"player_count": int(entry.get("player_count", 1)),
		"max_players": int(entry.get("max_players", HeartsRules.PLAYER_COUNT)),
		"updated_at": _format_timestamp_utc(Time.get_unix_time_from_system()),
	}


static func _parse_entries(body: String) -> Array:
	var parsed: Variant = JSON.parse_string(body.strip_edges())
	if parsed is Array:
		return parsed
	return []


static func _format_timestamp_utc(unix_time: float) -> String:
	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(int(unix_time))
	return "%04d-%02d-%02dT%02d:%02d:%02dZ" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
	]


func _send_request(
	owner: Node,
	method: int,
	url: String,
	body: String,
	extra_headers: Dictionary,
	callback: Callable
) -> void:
	if owner == null or not is_instance_valid(owner):
		callback.call(_INVALID_RESPONSE_CODE, PackedByteArray())
		return
	var request := HTTPRequest.new()
	request.timeout = 10.0
	owner.add_child(request)
	request.request_completed.connect(
		func(_result: int, response_code: int, _headers: PackedStringArray, response_body: PackedByteArray) -> void:
			if is_instance_valid(request):
				request.queue_free()
			callback.call(response_code, response_body)
	)
	var headers: PackedStringArray = PackedStringArray([
		"apikey: %s" % _config.supabase_anon_key,
		"Authorization: Bearer %s" % _config.supabase_anon_key,
		"Content-Type: application/json",
	])
	for header_name: String in extra_headers.keys():
		headers.append("%s: %s" % [header_name, str(extra_headers[header_name])])
	var error_code: Error = request.request(url, headers, method, body)
	if error_code != OK:
		if is_instance_valid(request):
			request.queue_free()
		callback.call(_INVALID_RESPONSE_CODE, PackedByteArray())
