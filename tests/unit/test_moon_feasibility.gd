class_name TestMoonFeasibility
extends GdUnitTestSuite


#region control_score
func test_classic_control_hand_scores_high() -> void:
	var hand := _classic_moon_control_hand()
	assert_int(MoonFeasibility.compute_control_score(hand)).is_greater(50)


func test_weak_balanced_hand_scores_low() -> void:
	var hand: Array[CardModel] = []
	for suit in [Suit.CLUBS, Suit.DIAMONDS, Suit.SPADES, Suit.HEARTS]:
		for rank in [Rank.TWO, Rank.THREE, Rank.FOUR]:
			hand.append(CardModel.new(suit, rank))
	hand.append(CardModel.new(Suit.CLUBS, Rank.FIVE))
	assert_int(MoonFeasibility.compute_control_score(hand)).is_less(30)
#endregion


#region is_viable_for_player
func test_moon_viable_for_classic_control_hand_at_deal() -> void:
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, _classic_moon_control_hand(), tricks_taken, 0.9)
	).is_true()


func test_many_low_hearts_without_control_is_not_viable() -> void:
	var hand: Array[CardModel] = []
	for rank in [Rank.TWO, Rank.THREE, Rank.FOUR, Rank.FIVE, Rank.SIX, Rank.SEVEN]:
		hand.append(CardModel.new(Suit.HEARTS, rank))
	hand.append(CardModel.new(Suit.SPADES, Rank.QUEEN))
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken)
	).is_false()


func test_moon_not_viable_when_opponent_captured_penalty() -> void:
	var hand: Array[CardModel] = [CardModel.new(Suit.HEARTS, Rank.ACE)]
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
	]
	assert_bool(
		MoonFeasibility.is_viable_for_player(0, hand, tricks_taken)
	).is_false()
	assert_bool(
		MoonFeasibility.is_viable_for_player(2, _classic_moon_control_hand(), tricks_taken)
	).is_false()
	assert_int(MoonFeasibility.sole_penalty_collector_index(tricks_taken)).is_equal(1)


func test_sole_collector_can_still_chase_with_strong_hand() -> void:
	var hand: Array[CardModel] = []
	for rank in [
		Rank.THREE, Rank.FOUR, Rank.FIVE, Rank.SIX, Rank.SEVEN, Rank.EIGHT,
		Rank.NINE, Rank.TEN, Rank.JACK, Rank.QUEEN, Rank.KING, Rank.ACE,
	]:
		hand.append(CardModel.new(Suit.HEARTS, rank))
	hand.append(CardModel.new(Suit.SPADES, Rank.QUEEN))
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
	]
	assert_bool(
		MoonFeasibility.is_viable_for_player(
			1, hand, tricks_taken, 0.95, 2
		)
	).is_true()


func test_sole_collector_after_accidental_trick_needs_commitment() -> void:
	var weak_hand: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.TWO),
		CardModel.new(Suit.DIAMONDS, Rank.THREE),
		CardModel.new(Suit.SPADES, Rank.FOUR),
	]
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
	]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, weak_hand, tricks_taken, 0.5, 3)
	).is_false()


func test_moon_not_viable_when_opponent_captured_queen_of_spades() -> void:
	var hand: Array[CardModel] = _classic_moon_control_hand()
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.SPADES, Rank.QUEEN)],
		[],
		[],
	]
	assert_bool(
		MoonFeasibility.is_viable_for_player(0, hand, tricks_taken)
	).is_false()


func test_moon_not_viable_when_opening_hand_is_too_weak() -> void:
	var hand: Array[CardModel] = [
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.HEARTS, Rank.ACE),
	]
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken)
	).is_false()


func test_high_confidence_relaxes_opening_requirements() -> void:
	var hand := _borderline_opening_hand()
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.2)
	).is_false()
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.95)
	).is_true()


func test_moon_hunter_relaxes_opening_requirements() -> void:
	var hand := _borderline_opening_hand()
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.60, 1)
	).is_false()
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.60, 1, true)
	).is_true()


func test_late_start_without_capturing_penalties_is_not_viable() -> void:
	var hand := _classic_moon_control_hand()
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.5, 6)
	).is_false()


func test_moon_hunter_does_not_extend_late_start_window() -> void:
	var hand := _classic_moon_control_hand()
	var tricks_taken: Array = [[], [], [], []]
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, hand, tricks_taken, 0.7, 4, true)
	).is_false()
#endregion


#region is_moon_busted_globally
func test_moon_busted_when_two_players_have_penalty_points() -> void:
	var tricks_taken: Array = [
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[CardModel.new(Suit.HEARTS, Rank.THREE)],
		[],
		[],
	]
	assert_bool(MoonFeasibility.is_moon_busted_globally(tricks_taken)).is_true()
	assert_int(MoonFeasibility.sole_penalty_collector_index(tricks_taken)).is_equal(-1)
	assert_bool(
		MoonFeasibility.is_viable_for_player(0, _classic_moon_control_hand(), tricks_taken, 0.9, 3)
	).is_false()
	assert_bool(
		MoonFeasibility.is_viable_for_player(1, _classic_moon_control_hand(), tricks_taken, 0.9, 3)
	).is_false()


func test_moon_not_busted_when_only_one_player_has_points() -> void:
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
	]
	assert_bool(MoonFeasibility.is_moon_busted_globally(tricks_taken)).is_false()
	assert_int(MoonFeasibility.sole_penalty_collector_index(tricks_taken)).is_equal(1)
#endregion


#region estimate_success_probability
func test_estimate_probability_zero_when_not_viable() -> void:
	var tricks_taken: Array = [
		[],
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[],
		[],
	]
	assert_float(
		MoonFeasibility.estimate_success_probability(0, [], tricks_taken)
	).is_equal(0.0)


func test_estimate_probability_higher_for_control_hand() -> void:
	var tricks_taken: Array = [[], [], [], []]
	var weak_prob := MoonFeasibility.estimate_success_probability(
		1, [CardModel.new(Suit.CLUBS, Rank.TWO)], tricks_taken, 0.5
	)
	var strong_prob := MoonFeasibility.estimate_success_probability(
		1, _classic_moon_control_hand(), tricks_taken, 0.9
	)
	assert_float(strong_prob).is_greater(weak_prob)
#endregion


static func _borderline_opening_hand() -> Array[CardModel]:
	return [
		CardModel.new(Suit.HEARTS, Rank.ACE),
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.HEARTS, Rank.QUEEN),
		CardModel.new(Suit.HEARTS, Rank.TEN),
		CardModel.new(Suit.HEARTS, Rank.NINE),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.CLUBS, Rank.ACE),
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.ACE),
		CardModel.new(Suit.DIAMONDS, Rank.KING),
	]


static func _classic_moon_control_hand() -> Array[CardModel]:
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
