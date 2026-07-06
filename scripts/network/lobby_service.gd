class_name LobbyService
extends RefCounted
## Lobby local simulé (sans réseau réel). Prépare le multijoueur futur.


var state: LobbyState = LobbyState.new()


func create_lobby(host_display_name: String, local_player_id: String) -> LobbyState:
	state = LobbyState.new()
	state.lobby_id = "local_%d" % Time.get_unix_time_from_system()
	state.host_peer_id = 1
	state.seats = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		state.seats.append(SeatAssignment.new(seat_index, null))
	var host_profile := PlayerProfile.new()
	host_profile.seat_index = 0
	host_profile.display_name = host_display_name
	host_profile.local_player_id = local_player_id
	host_profile.peer_id = state.host_peer_id
	host_profile.is_human = true
	host_profile.is_ready = false
	state.seats[0] = SeatAssignment.new(0, host_profile)
	return state


func join_lobby_fake(seat_index: int, display_name: String, local_player_id: String = "") -> StringName:
	if seat_index < 0 or seat_index >= state.max_seats:
		return LobbyState.ERROR_INVALID_SEAT
	var assignment := state.seats[seat_index]
	if assignment.profile != null and assignment.profile.is_human:
		return LobbyState.ERROR_SEAT_OCCUPIED
	var profile := PlayerProfile.new()
	profile.seat_index = seat_index
	profile.display_name = display_name
	profile.local_player_id = local_player_id
	profile.is_human = true
	profile.peer_id = seat_index + 1
	state.seats[seat_index] = SeatAssignment.new(seat_index, profile)
	return LobbyState.ERROR_NONE


func leave_lobby(seat_index: int) -> void:
	if seat_index < 0 or seat_index >= state.seats.size():
		return
	state.seats[seat_index] = SeatAssignment.new(seat_index, null)


func set_ready(seat_index: int, ready: bool) -> StringName:
	if seat_index < 0 or seat_index >= state.seats.size():
		return LobbyState.ERROR_INVALID_SEAT
	var profile := state.seats[seat_index].profile
	if profile == null:
		return LobbyState.ERROR_INVALID_SEAT
	profile.is_ready = ready
	return LobbyState.ERROR_NONE


func assign_ai_to_empty_seats() -> void:
	for seat_index in range(state.seats.size()):
		var assignment := state.seats[seat_index]
		if assignment.profile == null:
			var ai_profile := PlayerProfile.new()
			ai_profile.seat_index = seat_index
			ai_profile.display_name = "AI %d" % seat_index
			ai_profile.is_ai = true
			ai_profile.is_human = false
			ai_profile.is_ready = true
			state.seats[seat_index] = SeatAssignment.new(seat_index, ai_profile)


func can_start_match() -> StringName:
	if state.match_started:
		return LobbyState.ERROR_NOT_READY
	var has_ready_human := false
	for assignment in state.seats:
		if assignment.profile == null:
			continue
		if assignment.profile.is_human:
			if not assignment.profile.is_ready:
				return LobbyState.ERROR_NOT_READY
			has_ready_human = true
	if not has_ready_human:
		return LobbyState.ERROR_NOT_READY
	return LobbyState.ERROR_NONE


func start_match() -> StringName:
	var error_code := can_start_match()
	if error_code != LobbyState.ERROR_NONE:
		return error_code
	assign_ai_to_empty_seats()
	state.match_started = true
	return LobbyState.ERROR_NONE
