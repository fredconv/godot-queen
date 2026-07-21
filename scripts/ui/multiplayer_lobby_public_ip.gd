class_name MultiplayerLobbyPublicIp
extends RefCounted
## Lookup IP publique pour le host lobby (IDEA-00010).


signal lookup_succeeded(public_ip: String)
signal lookup_failed

const _PublicIpLookup = preload("res://scripts/network/public_ip_lookup.gd")

var _lookup: RefCounted
var cached_public_ip: String = ""


func start(host: Node) -> void:
	cancel()
	_lookup = _PublicIpLookup.new()
	_lookup.lookup_succeeded.connect(_on_lookup_succeeded)
	_lookup.lookup_failed.connect(_on_lookup_failed)
	_lookup.fetch(host)


func cancel() -> void:
	if _lookup == null:
		return
	if _lookup.lookup_succeeded.is_connected(_on_lookup_succeeded):
		_lookup.lookup_succeeded.disconnect(_on_lookup_succeeded)
	if _lookup.lookup_failed.is_connected(_on_lookup_failed):
		_lookup.lookup_failed.disconnect(_on_lookup_failed)
	_lookup = null


func clear_cache() -> void:
	cached_public_ip = ""


func _on_lookup_succeeded(public_ip: String) -> void:
	cached_public_ip = public_ip
	cancel()
	lookup_succeeded.emit(public_ip)


func _on_lookup_failed() -> void:
	cancel()
	lookup_failed.emit()
