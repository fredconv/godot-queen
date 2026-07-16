class_name PlayerConnection
extends RefCounted
## État de connexion réseau d'un joueur (préparation multijoueur).


var seat_index: int = -1
var peer_id: int = -1
var local_player_id: String = ""
var display_name: String = ""
## Connexion réseau active (évite le shadow de Object.is_connected).
var peer_connected: bool = false
var is_ready: bool = false


func to_dict() -> Dictionary:
	return {
		"seat_index": seat_index,
		"peer_id": peer_id,
		"local_player_id": local_player_id,
		"display_name": display_name,
		"is_connected": peer_connected,
		"is_ready": is_ready,
	}


static func from_dict(data: Dictionary) -> PlayerConnection:
	var connection := PlayerConnection.new()
	connection.seat_index = int(data.get("seat_index", -1))
	connection.peer_id = int(data.get("peer_id", -1))
	connection.local_player_id = str(data.get("local_player_id", ""))
	connection.display_name = str(data.get("display_name", ""))
	connection.peer_connected = bool(data.get("is_connected", false))
	connection.is_ready = bool(data.get("is_ready", false))
	return connection
