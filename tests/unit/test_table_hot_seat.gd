class_name TableHotSeatTest
extends GdUnitTestSuite


const __source = "res://scripts/ui/table/table_hot_seat.gd"


#region handoff
func test_needs_handoff_when_active_seat_differs_from_current_human() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["Alice", "Bob"]))
	config.active_human_seat_index = 0
	config.hands_revealed_for_active_human = true
	assert_bool(config.needs_handoff_for_current_player(1)).is_true()
	assert_bool(config.needs_handoff_for_current_player(0)).is_false()


func test_needs_handoff_false_for_ai_seat() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["Alice", "Bob"]))
	config.active_human_seat_index = 0
	assert_bool(config.needs_handoff_for_current_player(2)).is_false()


func test_needs_handoff_false_for_solo() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	assert_bool(config.needs_handoff_for_current_player(0)).is_false()


func test_needs_handoff_when_hands_not_revealed() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["Alice", "Bob"]))
	config.active_human_seat_index = 1
	config.hands_revealed_for_active_human = false
	assert_bool(config.needs_handoff_for_current_player(1)).is_true()


func test_local_player_seat_follows_active_index_in_hot_seat() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(3, PackedStringArray(["A", "B", "C"]))
	config.active_human_seat_index = 2
	assert_int(config.get_local_player_seat()).is_equal(2)
#endregion
