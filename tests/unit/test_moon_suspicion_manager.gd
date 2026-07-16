class_name MoonSuspicionManagerTest
extends GdUnitTestSuite


const __source = "res://scripts/ui/table/moon_suspicion_manager.gd"


#region availability
func test_not_available_without_match_manager() -> void:
	var ctx := TableContext.new()
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_false()


func test_not_available_outside_playing_phase() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	var ctx := TableContext.new()
	ctx.launch_config = config
	ctx.match_manager = MatchManager.new()
	ctx.match_manager.phase = MatchManager.Phase.DEALING
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_false()


func test_available_during_playing_phase_solo() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	var ctx := TableContext.new()
	ctx.launch_config = config
	ctx.match_manager = MatchManager.new()
	ctx.match_manager.phase = MatchManager.Phase.PLAYING
	ctx.match_manager.rule_engine.trick_number = MoonSuspicion.MIN_TRICK_TO_BREAK
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_true()


func test_available_during_playing_phase_hot_seat() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(2, PackedStringArray(["A", "B"]))
	var ctx := TableContext.new()
	ctx.launch_config = config
	ctx.match_manager = MatchManager.new()
	ctx.match_manager.phase = MatchManager.Phase.PLAYING
	ctx.match_manager.rule_engine.hearts_broken = true
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_true()


func test_hidden_early_in_hand_before_min_trick() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	var ctx := TableContext.new()
	ctx.launch_config = config
	ctx.match_manager = MatchManager.new()
	ctx.match_manager.phase = MatchManager.Phase.PLAYING
	ctx.match_manager.rule_engine.trick_number = 1
	ctx.match_manager.rule_engine.hearts_broken = false
	assert_bool(MoonSuspicionManager.is_moon_declarable(ctx)).is_true()
	assert_bool(MoonSuspicionManager.should_show_button(ctx)).is_false()
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_false()


func test_not_available_when_moon_busted_in_hand() -> void:
	var config: MatchLaunchConfig = SeatSetup.create_solo("Alice", "pid")
	var ctx := TableContext.new()
	ctx.launch_config = config
	ctx.match_manager = MatchManager.new()
	ctx.match_manager.phase = MatchManager.Phase.PLAYING
	ctx.match_manager._tricks_taken = [
		[CardModel.new(Suit.HEARTS, Rank.TWO)] as Array[CardModel],
		[CardModel.new(Suit.HEARTS, Rank.THREE)] as Array[CardModel],
		[] as Array[CardModel],
		[] as Array[CardModel],
	]
	assert_bool(MoonSuspicionManager.is_moon_declarable(ctx)).is_false()
	assert_bool(MoonSuspicionManager.is_available(ctx)).is_false()
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
