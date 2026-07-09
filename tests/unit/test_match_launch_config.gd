class_name MatchLaunchConfigTest
extends GdUnitTestSuite


const __source = "res://scripts/match/match_launch_config.gd"


#region local_seat
func test_get_local_player_seat_is_zero_for_solo() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid_1")
	assert_int(config.get_local_player_seat()).is_equal(0)


func test_hot_seat_starts_with_unassigned_active_seat() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(3, PackedStringArray(["A", "B", "C"]))
	assert_int(config.get_active_human_seat()).is_equal(-1)
	assert_bool(config.hands_revealed_for_active_human).is_false()
	assert_int(config.get_human_seat_indices().size()).is_equal(3)
	assert_bool(config.is_multiplayer_social()).is_true()
#endregion
