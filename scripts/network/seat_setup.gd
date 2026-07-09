class_name SeatSetup
extends RefCounted
## Configuration unifiée des sièges : N humains + (4 − N) IA.


static func create_solo(
	local_display_name: String,
	local_player_id: String = "",
	local_avatar_id: String = "default"
) -> MatchLaunchConfig:
	return create_local_humans(
		1,
		PackedStringArray([local_display_name]),
		local_player_id,
		local_avatar_id,
		MatchMode.Type.SOLO
	)


static func create_hot_seat(human_count: int, display_names: PackedStringArray) -> MatchLaunchConfig:
	var config := create_local_humans(
		human_count,
		display_names,
		"",
		"default",
		MatchMode.Type.HOT_SEAT
	)
	if config.is_hot_seat_multi_human():
		config.reset_hot_seat_view_state()
	return config


static func create_local_humans(
	human_count: int,
	display_names: PackedStringArray,
	local_player_id: String = "",
	local_avatar_id: String = "default",
	mode: MatchMode.Type = MatchMode.Type.SOLO
) -> MatchLaunchConfig:
	var config := MatchLaunchConfig.new()
	config.mode = mode
	config.active_human_seat_index = 0
	var clamped_count: int = clampi(human_count, 1, HeartsRules.PLAYER_COUNT)
	var assignments: Array[SeatAssignment] = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		var profile := PlayerProfile.new()
		profile.seat_index = seat_index
		var is_human: bool = seat_index < clamped_count
		profile.is_human = is_human
		profile.is_ai = not is_human
		profile.is_ready = true
		profile.is_connected = true
		if is_human:
			if seat_index < display_names.size() and not display_names[seat_index].is_empty():
				profile.display_name = display_names[seat_index]
			else:
				profile.display_name = "Player %d" % (seat_index + 1)
			if seat_index == 0:
				if local_player_id.is_empty():
					profile.local_player_id = PlayerProfileService.get_player_id()
				else:
					profile.local_player_id = local_player_id
				profile.avatar_id = local_avatar_id
		else:
			profile.display_name = "AI %d" % seat_index
		assignments.append(SeatAssignment.new(seat_index, profile))
	config.seat_assignments = assignments
	return config


static func shuffle_human_seats(config: MatchLaunchConfig) -> void:
	if not config.is_hot_seat_multi_human():
		return

	var human_profiles: Array[PlayerProfile] = []
	for assignment: SeatAssignment in config.seat_assignments:
		if assignment.profile != null and assignment.profile.is_human:
			human_profiles.append(assignment.profile)

	var seat_pool: Array[int] = []
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		seat_pool.append(seat_index)
	seat_pool.shuffle()

	var assignments: Array[SeatAssignment] = []
	for human_index in range(human_profiles.size()):
		var seat_index: int = seat_pool[human_index]
		var profile: PlayerProfile = human_profiles[human_index]
		profile.seat_index = seat_index
		assignments.append(SeatAssignment.new(seat_index, profile))

	for seat_index in seat_pool.slice(human_profiles.size()):
		var profile := PlayerProfile.new()
		profile.seat_index = seat_index
		profile.is_human = false
		profile.is_ai = true
		profile.is_ready = true
		profile.is_connected = true
		profile.display_name = "AI %d" % seat_index
		assignments.append(SeatAssignment.new(seat_index, profile))

	assignments.sort_custom(func(a: SeatAssignment, b: SeatAssignment) -> bool: return a.seat_index < b.seat_index)
	config.seat_assignments = assignments
	config.reset_hot_seat_view_state()


static func create_online_from_lobby(
	lobby: LobbyState,
	is_host: bool,
	local_seat_index: int
) -> MatchLaunchConfig:
	var config := MatchLaunchConfig.new()
	config.mode = MatchMode.Type.ONLINE_HOST if is_host else MatchMode.Type.ONLINE_CLIENT
	config.seat_assignments = lobby.seats.duplicate()
	config.active_human_seat_index = local_seat_index if local_seat_index >= 0 else 0
	return config


static func apply_ai_to_match_manager(match_manager: MatchManager, assignments: Array[SeatAssignment]) -> void:
	for assignment: SeatAssignment in assignments:
		var seat_index: int = assignment.seat_index
		if assignment.profile != null and assignment.profile.is_ai:
			var strategy: AiStrategy = AiPersonalityCatalog.create_for_opponent_seat(seat_index)
			match_manager.set_ai_player(seat_index, AiPlayer.new(strategy))
		else:
			match_manager.set_ai_player(seat_index, null)
