class_name SoloSeatSetup
extends RefCounted
## Configuration des sièges pour une partie solo (1 humain + 3 IA).


static func create_assignments(
	local_display_name: String,
	local_player_id: String = "",
	local_avatar_id: String = "default"
) -> Array[SeatAssignment]:
	var assignments: Array[SeatAssignment] = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		var profile := PlayerProfile.new()
		profile.seat_index = seat_index
		profile.is_ai = seat_index != 0
		profile.is_human = seat_index == 0
		profile.is_ready = true
		profile.is_connected = true
		if seat_index == 0:
			profile.display_name = local_display_name
			profile.local_player_id = local_player_id
			profile.avatar_id = local_avatar_id
		else:
			profile.display_name = "AI %d" % seat_index
		assignments.append(SeatAssignment.new(seat_index, profile))
	return assignments
