class_name TestAiConfidence
extends GdUnitTestSuite


#region apply_hand_result
func test_hand_win_increases_confidence() -> void:
	var next := AiConfidence.apply_hand_result(
		AiConfidence.DEFAULT,
		0,
		[2, 10, 8, 12],
		0,
		[2, 10, 8, 12]
	)
	assert_float(next).is_greater(AiConfidence.DEFAULT)


func test_bad_hand_decreases_confidence() -> void:
	var next := AiConfidence.apply_hand_result(
		AiConfidence.DEFAULT,
		1,
		[0, 18, 4, 3],
		0,
		[0, 18, 4, 3]
	)
	assert_float(next).is_less(AiConfidence.DEFAULT)


func test_shoot_the_moon_gives_large_boost() -> void:
	var hand_scores: Array = [
		HeartsRules.TOTAL_POINTS_PER_HAND,
		0,
		HeartsRules.TOTAL_POINTS_PER_HAND,
		HeartsRules.TOTAL_POINTS_PER_HAND,
	]
	var next := AiConfidence.apply_hand_result(
		0.5,
		1,
		hand_scores,
		1,
		hand_scores
	)
	assert_float(next).is_greater(0.7)
#endregion


#region did_shoot_the_moon
func test_detects_moon_shooter() -> void:
	var hand_scores: Array = [26, 0, 26, 26]
	assert_bool(AiConfidence.did_shoot_the_moon(1, hand_scores)).is_true()
	assert_bool(AiConfidence.did_shoot_the_moon(0, hand_scores)).is_false()
#endregion
