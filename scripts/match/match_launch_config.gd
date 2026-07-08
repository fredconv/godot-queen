class_name MatchLaunchConfig
extends RefCounted
## Configuration de lancement : mode, sièges et joueur humain actif (hot seat).


var mode: MatchMode.Type = MatchMode.Type.SOLO
var seat_assignments: Array[SeatAssignment] = []
var active_human_seat_index: int = 0


func get_human_seat_indices() -> Array[int]:
	var indices: Array[int] = []
	for assignment: SeatAssignment in seat_assignments:
		if assignment.profile != null and assignment.profile.is_human:
			indices.append(assignment.seat_index)
	return indices


func get_active_human_seat() -> int:
	return active_human_seat_index


func get_local_player_seat() -> int:
	match mode:
		MatchMode.Type.HOT_SEAT:
			return active_human_seat_index
		MatchMode.Type.ONLINE_CLIENT:
			var local_id: String = PlayerProfileService.get_player_id()
			for assignment: SeatAssignment in seat_assignments:
				if assignment.profile != null and assignment.profile.local_player_id == local_id:
					return assignment.seat_index
			return 0
		_:
			return 0
