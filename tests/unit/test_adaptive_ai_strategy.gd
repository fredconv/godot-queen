class_name TestAdaptiveAiStrategy
extends GdUnitTestSuite


#region strategy_switch
func test_moon_hunter_switches_silently_when_moon_not_feasible() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.MOON_HUNTER,
		MoonShooterStrategy.new()
	)
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
	]
	var context := {
		"hand_number": 1,
		"player_index": 1,
		"moon_feasible": false,
		"moon_busted": false,
		"is_leading": true,
		"trick_number": 6,
		"match_scores": [0, 0, 0, 0],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	strategy.choose_card(legal, context, rng)
	assert_dict(strategy.consume_pending_announcement()).is_empty()


func test_moon_hunter_chases_with_relaxed_opening_viability() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.MOON_HUNTER,
		MoonShooterStrategy.new()
	)
	var hand := TestMoonFeasibility._borderline_opening_hand()
	var context := {
		"hand_number": 1,
		"player_index": 1,
		"confidence": 0.60,
		"moon_feasible": false,
		"moon_busted": false,
		"trick_number": 1,
		"hand_cards": hand,
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, [[], [], [], []], 0.60, 1)
	).is_false()
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, [[], [], [], []], 0.60, 1, true)
	).is_true()
	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.CHASE_MOON)


func test_moon_hunter_stays_committed_while_still_viable() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.MOON_HUNTER,
		MoonShooterStrategy.new()
	)
	var hand := TestMoonFeasibility._classic_moon_control_hand()
	var context := {
		"hand_number": 1,
		"player_index": 1,
		"confidence": 0.85,
		"moon_feasible": true,
		"moon_busted": false,
		"trick_number": 1,
		"hand_cards": hand,
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	var legal: Array[CardModel] = [CardModel.new(Suit.CLUBS, Rank.FIVE)]
	var rng := RandomNumberGenerator.new()
	strategy.choose_card(legal, context, rng)
	context["trick_number"] = 3
	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.CHASE_MOON)


func test_moon_hunter_abandons_when_opponent_takes_penalties() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.MOON_HUNTER,
		MoonShooterStrategy.new()
	)
	var hand := TestMoonFeasibility._classic_moon_control_hand()
	var context := {
		"hand_number": 1,
		"player_index": 1,
		"confidence": 0.85,
		"moon_feasible": true,
		"moon_busted": false,
		"trick_number": 1,
		"hand_cards": hand,
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	var legal: Array[CardModel] = [CardModel.new(Suit.CLUBS, Rank.FIVE)]
	var rng := RandomNumberGenerator.new()
	strategy.choose_card(legal, context, rng)
	context["tricks_taken"] = [
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
		[],
	]
	context["hand_raw_scores"] = [1, 0, 0, 0]
	context["trick_number"] = 3
	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.MINIMIZE)


func test_passive_announces_more_aggressive_when_giving_up() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.PASSIVE,
		PassiveStrategy.new()
	)
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
	]
	var context := {
		"hand_number": 1,
		"player_index": 2,
		"moon_feasible": true,
		"moon_busted": false,
		"is_leading": true,
		"trick_number": 6,
		"match_scores": [0, 0, 70, 0],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = 7

	strategy.choose_card(legal, context, rng)
	var announcement: Dictionary = strategy.consume_pending_announcement()
	assert_str(announcement.get("reason_key", "")).is_equal("more_aggressive")


func test_chase_mode_does_not_announce_moon_intent() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.BALANCED,
		HeuristicStrategy.new()
	)
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
	]
	var context := {
		"hand_number": 1,
		"player_index": 3,
		"confidence": 0.9,
		"moon_feasible": true,
		"moon_busted": false,
		"is_leading": true,
		"trick_number": 6,
		"match_scores": [10, 20, 15, 8],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = 3

	strategy.choose_card(legal, context, rng)
	var announcement: Dictionary = strategy.consume_pending_announcement()
	assert_str(announcement.get("reason_key", "")).is_equal("more_aggressive")


func test_suspect_moon_when_opponent_looks_dangerous() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.BALANCED,
		HeuristicStrategy.new()
	)
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
	]
	var context := {
		"hand_number": 1,
		"player_index": 0,
		"confidence": 0.5,
		"moon_feasible": false,
		"moon_busted": false,
		"is_leading": true,
		"trick_number": 6,
		"match_scores": [10, 20, 15, 8],
		"hand_raw_scores": [0, 9, 0, 0],
		"tricks_won_counts": [0, 3, 0, 0],
		"consecutive_trick_wins": [0, 2, 0, 0],
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = 11

	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.BREAK_MOON)
	strategy.choose_card(legal, context, rng)
	var announcement: Dictionary = strategy.consume_pending_announcement()
	assert_str(announcement.get("reason_key", "")).is_equal("suspect_moon")
	assert_int(announcement.get("target_player_index", -1)).is_equal(1)


func test_second_announcement_blocked_same_hand() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.BALANCED,
		HeuristicStrategy.new()
	)
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
	]
	var context := {
		"hand_number": 1,
		"player_index": 0,
		"confidence": 0.5,
		"moon_feasible": false,
		"moon_busted": false,
		"is_leading": true,
		"trick_number": 6,
		"match_scores": [10, 20, 15, 8],
		"hand_raw_scores": [0, 9, 0, 0],
		"tricks_won_counts": [0, 3, 0, 0],
		"consecutive_trick_wins": [0, 2, 0, 0],
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = 11

	strategy.choose_card(legal, context, rng)
	assert_bool(strategy.consume_pending_announcement().is_empty()).is_false()

	context["trick_number"] = 12
	strategy.choose_card(legal, context, rng)
	assert_dict(strategy.consume_pending_announcement()).is_empty()
#endregion


#region passive_excellent_moon
func test_passive_does_not_chase_moon_with_average_hand() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.PASSIVE,
		PassiveStrategy.new()
	)
	var context := {
		"hand_number": 1,
		"player_index": 2,
		"confidence": 0.85,
		"moon_feasible": true,
		"moon_busted": false,
		"trick_number": 1,
		"hand_cards": [
			CardModel.new(Suit.HEARTS, Rank.ACE),
			CardModel.new(Suit.HEARTS, Rank.KING),
			CardModel.new(Suit.CLUBS, Rank.TWO),
		],
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.MINIMIZE)


func test_passive_chases_moon_with_excellent_opening_hand() -> void:
	var strategy := AdaptiveAiStrategy.new(
		AiPersonalityKind.Kind.PASSIVE,
		PassiveStrategy.new()
	)
	var context := {
		"hand_number": 1,
		"player_index": 2,
		"confidence": 0.95,
		"moon_feasible": true,
		"moon_busted": false,
		"trick_number": 1,
		"hand_cards": _excellent_moon_hand(),
		"tricks_taken": [[], [], [], []],
		"hand_raw_scores": [0, 0, 0, 0],
	}
	assert_bool(
		MoonFeasibility.is_viable_for_player(
			2, _excellent_moon_hand(), [[], [], [], []], 0.95, 1
		)
	).is_true()
	assert_int(strategy.peek_play_mode(context)).is_equal(AiPlayMode.Kind.CHASE_MOON)


static func _excellent_moon_hand() -> Array[CardModel]:
	return [
		CardModel.new(Suit.HEARTS, Rank.ACE),
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.HEARTS, Rank.QUEEN),
		CardModel.new(Suit.HEARTS, Rank.JACK),
		CardModel.new(Suit.CLUBS, Rank.ACE),
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.ACE),
		CardModel.new(Suit.DIAMONDS, Rank.KING),
		CardModel.new(Suit.SPADES, Rank.ACE),
		CardModel.new(Suit.SPADES, Rank.KING),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.CLUBS, Rank.QUEEN),
		CardModel.new(Suit.DIAMONDS, Rank.QUEEN),
	]
#endregion
