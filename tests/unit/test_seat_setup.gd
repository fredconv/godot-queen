class_name SeatSetupTest
extends GdUnitTestSuite


const __source = "res://scripts/network/seat_setup.gd"


#region solo
func test_create_solo_assigns_one_human_and_three_ai() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid_alice", "default")
	assert_that(config.mode).is_equal(MatchMode.Type.SOLO)
	assert_int(config.seat_assignments.size()).is_equal(4)
	assert_bool(config.seat_assignments[0].profile.is_human).is_true()
	assert_str(config.seat_assignments[0].profile.display_name).is_equal("Alice")
	assert_str(config.seat_assignments[0].profile.local_player_id).is_equal("pid_alice")
	for seat_index in range(1, 4):
		assert_bool(config.seat_assignments[seat_index].profile.is_ai).is_true()
#endregion


#region hot_seat
func test_create_hot_seat_with_two_humans() -> void:
	var names := PackedStringArray(["Alice", "Bob"])
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, names)
	assert_that(config.mode).is_equal(MatchMode.Type.HOT_SEAT)
	assert_int(config.get_human_seat_indices().size()).is_equal(2)
	assert_bool(config.seat_assignments[2].profile.is_ai).is_true()
	assert_str(config.seat_assignments[1].profile.display_name).is_equal("Bob")
#endregion


#region ai
func test_apply_ai_to_match_manager_sets_only_ai_seats() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["A", "B"]))
	var manager := MatchManager.new()
	SeatSetup.apply_ai_to_match_manager(manager, config.seat_assignments)
	assert_bool(manager.is_ai_controlled(0)).is_false()
	assert_bool(manager.is_ai_controlled(1)).is_false()
	assert_bool(manager.is_ai_controlled(2)).is_true()
	assert_bool(manager.is_ai_controlled(3)).is_true()
#endregion
