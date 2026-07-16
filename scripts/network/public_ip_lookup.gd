class_name PublicIpLookup
extends RefCounted
## Récupère l'adresse IPv4 publique via un service HTTP minimal (api.ipify.org).


const LOOKUP_URL: String = "https://api.ipify.org"
const REQUEST_TIMEOUT_SEC: float = 8.0

signal lookup_succeeded(public_ip: String)
signal lookup_failed


func fetch(owner: Node) -> void:
	if owner == null or not is_instance_valid(owner):
		lookup_failed.emit()
		return
	var request := HTTPRequest.new()
	request.timeout = REQUEST_TIMEOUT_SEC
	owner.add_child(request)
	request.request_completed.connect(
		func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			if is_instance_valid(request):
				request.queue_free()
			if response_code != HTTPClient.RESPONSE_OK:
				lookup_failed.emit()
				return
			var public_ip: String = parse_response(body.get_string_from_utf8())
			if public_ip.is_empty():
				lookup_failed.emit()
				return
			lookup_succeeded.emit(public_ip)
	)
	var error_code: Error = request.request(LOOKUP_URL)
	if error_code != OK:
		if is_instance_valid(request):
			request.queue_free()
		lookup_failed.emit()


static func parse_response(body: String) -> String:
	var candidate: String = body.strip_edges()
	if candidate.is_empty():
		return ""
	if not _is_valid_ipv4(candidate):
		return ""
	return candidate


static func format_share_address(public_ip: String, port: int) -> String:
	if public_ip.is_empty():
		return ""
	return "%s:%d" % [public_ip, clampi(port, 1, 65535)]


static func _is_valid_ipv4(value: String) -> bool:
	var parts: PackedStringArray = value.split(".")
	if parts.size() != 4:
		return false
	for part: String in parts:
		if not part.is_valid_int():
			return false
		var octet: int = int(part)
		if octet < 0 or octet > 255:
			return false
	return true
