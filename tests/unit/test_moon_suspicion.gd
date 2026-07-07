class_name TestMoonSuspicion
extends GdUnitTestSuite


#region suspicion
func test_no_suspicion_when_no_points_taken() -> void:
	var context := {
		"player_index": 0,
		"hand_raw_scores": [0, 0, 0, 0],
		"tricks_won_counts": [0, 1, 0, 0],
		"consecutive_trick_wins": [0, 1, 0, 0],
		"trick_number": 2,
	}
	assert_bool(MoonSuspicion.should_break_moon(context)).is_false()


func test_detects_likely_moon_attempt() -> void:
	var context := {
		"player_index": 0,
		"hand_raw_scores": [0, 9, 0, 0],
		"tricks_won_counts": [0, 3, 0, 0],
		"consecutive_trick_wins": [0, 2, 0, 0],
		"trick_number": 4,
	}
	assert_bool(MoonSuspicion.should_break_moon(context)).is_true()
	var suspect: Dictionary = MoonSuspicion.find_top_suspect(context)
	assert_int(suspect.get("player_index", -1)).is_equal(1)
#endregion
