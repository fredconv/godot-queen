class_name PlayerProfile
extends RefCounted
## Identité d'un joueur à un siège (solo, lobby ou multijoueur).


var seat_index: int = -1
var display_name: String = ""
var is_human: bool = true
var is_ai: bool = false
var peer_id: int = -1
var is_connected: bool = true
var is_ready: bool = false
var avatar_id: String = "default"
var local_player_id: String = ""


func to_dict() -> Dictionary:
	return {
		"seat_index": seat_index,
		"display_name": display_name,
		"is_human": is_human,
		"is_ai": is_ai,
		"peer_id": peer_id,
		"is_connected": is_connected,
		"is_ready": is_ready,
		"avatar_id": avatar_id,
		"local_player_id": local_player_id,
	}


static func from_dict(data: Dictionary) -> PlayerProfile:
	var profile := PlayerProfile.new()
	profile.seat_index = int(data.get("seat_index", -1))
	profile.display_name = str(data.get("display_name", ""))
	profile.is_human = bool(data.get("is_human", true))
	profile.is_ai = bool(data.get("is_ai", false))
	profile.peer_id = int(data.get("peer_id", -1))
	profile.is_connected = bool(data.get("is_connected", true))
	profile.is_ready = bool(data.get("is_ready", false))
	profile.avatar_id = str(data.get("avatar_id", "default"))
	profile.local_player_id = str(data.get("local_player_id", ""))
	return profile
