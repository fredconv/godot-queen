class_name SoloSeatSetup
extends RefCounted
## Configuration des sièges pour une partie solo (1 humain + 3 IA).


static func create_assignments(
	local_display_name: String,
	local_player_id: String = "",
	local_avatar_id: String = "default"
) -> Array[SeatAssignment]:
	return SeatSetup.create_solo(local_display_name, local_player_id, local_avatar_id).seat_assignments
