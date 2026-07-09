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


func is_hot_seat_multi_human() -> bool:
	return mode == MatchMode.Type.HOT_SEAT and get_human_seat_indices().size() > 1


func get_display_name_for_seat(seat_index: int) -> String:
	for assignment: SeatAssignment in seat_assignments:
		if assignment.seat_index == seat_index and assignment.profile != null:
			return assignment.profile.display_name
	return "Player %d" % (seat_index + 1)


func needs_handoff_for_current_player(current_player: int) -> bool:
	if not is_hot_seat_multi_human():
		return false
	if current_player not in get_human_seat_indices():
		return false
	return current_player != active_human_seat_index
