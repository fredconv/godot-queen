class_name NetworkLobbyBook
extends RefCounted
## État lobby + mapping peer ↔ siège. Muté par NetworkService (façade autoload).


var lobby: LobbyState = LobbyState.new()
var peer_to_seat: Dictionary = {}
var local_seat_index: int = -1


func reset() -> void:
	lobby = LobbyState.new()
	lobby.seats = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		lobby.seats.append(SeatAssignment.new(seat_index, null))
	peer_to_seat.clear()
	local_seat_index = -1


func register_host_player(peer_id: int, display_name: String, local_player_id: String) -> void:
	var host_profile := PlayerProfile.new()
	host_profile.seat_index = 0
	host_profile.display_name = display_name
	host_profile.local_player_id = local_player_id
	host_profile.peer_id = peer_id
	host_profile.is_human = true
	host_profile.is_ai = false
	host_profile.peer_connected = true
	host_profile.is_ready = true
	lobby.seats[0] = SeatAssignment.new(0, host_profile)
	peer_to_seat[peer_id] = 0
	local_seat_index = 0


func find_free_seat() -> int:
	for seat_index in range(1, HeartsRules.PLAYER_COUNT):
		var assignment: SeatAssignment = lobby.seats[seat_index]
		if assignment.profile == null:
			return seat_index
	return -1


## Place un peer sur un siège libre. Retourne l'index ou -1 si table pleine.
func assign_connecting_peer(peer_id: int) -> int:
	var seat_index: int = find_free_seat()
	if seat_index < 0:
		return -1
	peer_to_seat[peer_id] = seat_index
	var profile := PlayerProfile.new()
	profile.seat_index = seat_index
	profile.display_name = "Player %d" % (seat_index + 1)
	profile.peer_id = peer_id
	profile.is_human = true
	profile.is_ai = false
	profile.peer_connected = true
	profile.is_ready = false
	lobby.seats[seat_index] = SeatAssignment.new(seat_index, profile)
	return seat_index


func erase_peer(peer_id: int) -> int:
	var seat_index: int = int(peer_to_seat.get(peer_id, -1))
	peer_to_seat.erase(peer_id)
	return seat_index


func clear_seat(seat_index: int) -> void:
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return
	lobby.seats[seat_index] = SeatAssignment.new(seat_index, null)


func get_seat_for_peer(peer_id: int) -> int:
	return int(peer_to_seat.get(peer_id, -1))


func get_peer_for_seat(seat_index: int) -> int:
	for peer_id: int in peer_to_seat.keys():
		if int(peer_to_seat[peer_id]) == seat_index:
			return peer_id
	return -1


func get_connected_human_count() -> int:
	var count: int = 0
	for assignment: SeatAssignment in lobby.seats:
		if assignment.profile != null and assignment.profile.is_human and assignment.profile.peer_connected:
			count += 1
	return count


func apply_from_network(state_dict: Dictionary, local_player_id: String) -> void:
	lobby = LobbyState.from_dict(state_dict)
	peer_to_seat.clear()
	for assignment: SeatAssignment in lobby.seats:
		if assignment.profile != null and assignment.profile.peer_id > 0:
			peer_to_seat[assignment.profile.peer_id] = assignment.seat_index
			if assignment.profile.local_player_id == local_player_id:
				local_seat_index = assignment.seat_index


func apply_match_start_seats(seat_dicts: Array, local_player_id: String) -> void:
	var assignments: Array[SeatAssignment] = []
	for entry in seat_dicts:
		if entry is Dictionary:
			assignments.append(SeatAssignment.from_dict(entry))
	lobby.seats = assignments
	for assignment: SeatAssignment in assignments:
		if assignment.profile != null and assignment.profile.local_player_id == local_player_id:
			local_seat_index = assignment.seat_index


func get_profile(seat_index: int) -> PlayerProfile:
	if seat_index < 0 or seat_index >= lobby.seats.size():
		return null
	return lobby.seats[seat_index].profile


func is_human_disconnected(seat_index: int) -> bool:
	var profile: PlayerProfile = get_profile(seat_index)
	if profile == null:
		return false
	return profile.is_human and not profile.peer_connected
