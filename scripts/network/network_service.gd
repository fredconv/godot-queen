extends Node
## NetworkService (stub)
## Point d'entrée futur pour le multijoueur LAN. Non branché en phase 0-6.


func host_game(_port: int = 7777) -> bool:
	DebugService.log_warning("NetworkService.host_game : non implémenté (phase 7+)")
	return false


func join_game(_address: String, _port: int = 7777) -> bool:
	DebugService.log_warning("NetworkService.join_game : non implémenté (phase 7+)")
	return false


func disconnect_from_host() -> void:
	pass


func is_host() -> bool:
	return false


func get_peer_id() -> int:
	return 0


func send_action(_action: PlayerAction) -> void:
	DebugService.log_warning("NetworkService.send_action : non implémenté (phase 7+)")
