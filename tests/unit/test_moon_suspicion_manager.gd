class_name MoonSuspicionManagerTest
extends GdUnitTestSuite


const __source = "res://scripts/ui/table/moon_suspicion_manager.gd"


#region availability
func test_not_available_in_solo() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	var ctx := TableContext.new()
	ctx.launch_config = config
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_false()


func test_available_in_hot_seat_multi_human() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["A", "B"]))
	var ctx := TableContext.new()
	ctx.launch_config = config
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_true()
#endregion


#region event
func test_event_tracks_seen_by_seats() -> void:
	var event := MoonSuspicionEvent.new()
	event.mark_seen_by(0)
	assert_bool(event.was_seen_by(0)).is_true()
	assert_bool(event.was_seen_by(1)).is_false()
	assert_bool(event.all_humans_seen([0, 1])).is_false()
	event.mark_seen_by(1)
	assert_bool(event.all_humans_seen([0, 1])).is_true()
#endregion
