class_name SeatAssignment
extends RefCounted
## Association siège ↔ profil joueur pour une table.


var seat_index: int = -1
var profile: PlayerProfile = null


func _init(seat_index_value: int = -1, profile_value: PlayerProfile = null) -> void:
	seat_index = seat_index_value
	profile = profile_value


func to_dict() -> Dictionary:
	return {
		"seat_index": seat_index,
		"profile": profile.to_dict() if profile != null else {},
	}


static func from_dict(data: Dictionary) -> SeatAssignment:
	var profile_data: Dictionary = data.get("profile", {})
	return SeatAssignment.new(int(data.get("seat_index", -1)), PlayerProfile.from_dict(profile_data))
