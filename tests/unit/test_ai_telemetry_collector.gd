class_name TestAiTelemetryCollector
extends GdUnitTestSuite


#region moon_attempt_tracking
func test_records_moon_attempt_and_success() -> void:
	var telemetry := AiTelemetryCollector.new()
	telemetry.begin_match()
	telemetry.begin_hand(1)

	var context := _chase_context(0, 3)
	telemetry.record_decision(0, context, AiPlayMode.Kind.CHASE_MOON)
	telemetry.record_trick_resolved(3, 0, 0, [])

	var tricks_taken: Array = [
		_fill_penalty_cards(),
		[],
		[],
		[],
	]
	telemetry.end_hand(tricks_taken, {0: 0, 1: 26, 2: 26, 3: 26}, [0, 0, 0, 0])
	telemetry.end_match(0, [12, 30, 40, 55], 1)

	var summary: Dictionary = telemetry.summarize()
	var seat0: Dictionary = summary["seats"][0]
	assert_int(seat0.get("moon_attempts", 0)).is_equal(1)
	assert_int(seat0.get("moon_successes", 0)).is_equal(1)
	assert_float(seat0.get("moon_success_rate", 0.0)).is_equal(1.0)


func test_records_detection_when_break_mode_targets_suspect() -> void:
	var telemetry := AiTelemetryCollector.new()
	telemetry.begin_match()
	telemetry.begin_hand(1)

	telemetry.record_decision(1, _chase_context(1, 4), AiPlayMode.Kind.CHASE_MOON)
	var break_context := _chase_context(0, 5)
	break_context["hand_raw_scores"] = [0, 8, 0, 0]
	break_context["tricks_won_counts"] = [0, 3, 0, 0]
	break_context["consecutive_trick_wins"] = [0, 2, 0, 0]
	telemetry.record_decision(0, break_context, AiPlayMode.Kind.BREAK_MOON)

	var tricks_taken: Array = [[], [CardModel.new(Suit.HEARTS, Rank.TWO)], [], []]
	telemetry.end_hand(tricks_taken, {0: 1, 1: 1, 2: 0, 3: 0}, [0, 0, 0, 0])
	telemetry.end_match(2, [5, 12, 3, 8], 1)

	var seat1: Dictionary = telemetry.summarize()["seats"][1]
	assert_int(seat1.get("moon_detected", 0)).is_equal(1)
	assert_int(seat1.get("moon_attempts", 0)).is_equal(1)
#endregion


#region regret
func test_regret_buckets_track_estimated_vs_actual() -> void:
	var telemetry := AiTelemetryCollector.new()
	telemetry.begin_match()
	telemetry.begin_hand(1)

	var context := _chase_context(0, 2)
	context["confidence"] = 0.95
	telemetry.record_decision(0, context, AiPlayMode.Kind.CHASE_MOON)
	telemetry.end_hand([[], [], [], []], {0: 14, 1: 4, 2: 4, 3: 4}, [0, 0, 0, 0])
	telemetry.end_match(1, [20, 10, 12, 14], 1)

	var regret: Array = telemetry.summarize().get("regret_analysis", [])
	assert_int(regret.size()).is_equal(3)
	assert_str(regret[0].get("bucket", "")).is_equal("0.0-0.04")
#endregion


static func _chase_context(player_index: int, trick_number: int) -> Dictionary:
	return {
		"player_index": player_index,
		"trick_number": trick_number,
		"confidence": 0.8,
		"hand_cards": _strong_moon_hand(),
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
		"tricks_won_counts": [0, 0, 0, 0],
		"consecutive_trick_wins": [0, 0, 0, 0],
	}


static func _strong_moon_hand() -> Array[CardModel]:
	return [
		CardModel.new(Suit.HEARTS, Rank.ACE),
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.HEARTS, Rank.QUEEN),
		CardModel.new(Suit.HEARTS, Rank.JACK),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
	]


static func _fill_penalty_cards() -> Array:
	var cards: Array = []
	for rank in [
		Rank.TWO, Rank.THREE, Rank.FOUR, Rank.FIVE, Rank.SIX, Rank.SEVEN,
		Rank.EIGHT, Rank.NINE, Rank.TEN, Rank.JACK, Rank.QUEEN, Rank.KING, Rank.ACE,
	]:
		cards.append(CardModel.new(Suit.HEARTS, rank))
	cards.append(CardModel.new(Suit.SPADES, Rank.QUEEN))
	return cards
