class_name TestRuleEngine
extends GdUnitTestSuite
## Tests unitaires de RuleEngine et HeartsRules (moteur de règles pur, sans
## scène). Voir docs/TEST_PLAN.md pour la stratégie générale.

static func _hand_of(cards: Array[CardModel]) -> PlayerHand:
	var hand := PlayerHand.new()
	for card in cards:
		hand.add_card(card)
	return hand


# --- get_legal_plays : suivre la couleur ------------------------------------

func test_must_follow_suit_when_possible() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	var hand := _hand_of([
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.SPADES, Rank.KING),
	])

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).has_size(1)
	assert_bool(legal[0].equals(CardModel.new(Suit.CLUBS, Rank.FIVE))).is_true()


func test_any_card_legal_when_void_of_lead_suit_after_first_trick() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.SPADES, Rank.KING),
	])

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).has_size(2)


# --- Cœurs non défoncés ------------------------------------------------------

func test_cannot_lead_hearts_before_broken() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	engine.hearts_broken = false
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(1)
	assert_bool(legal[0].equals(CardModel.new(Suit.CLUBS, Rank.FIVE))).is_true()


func test_can_lead_hearts_when_only_hearts_in_hand_even_if_not_broken() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	engine.hearts_broken = false
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.HEARTS, Rank.SEVEN),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(2)


func test_can_lead_hearts_once_broken() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 3
	engine.is_first_trick = false
	engine.hearts_broken = true
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(2)


func test_discarding_a_heart_while_void_is_always_allowed_and_breaks_hearts() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	engine.hearts_broken = false
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).has_size(2)

	engine.record_card_played(CardModel.new(Suit.HEARTS, Rank.TWO))
	assert_bool(engine.hearts_broken).is_true()


func test_queen_of_spades_breaks_hearts() -> void:
	var engine := RuleEngine.new()
	engine.record_card_played(CardModel.new(Suit.SPADES, Rank.QUEEN))
	assert_bool(engine.hearts_broken).is_true()


# --- Premier pli : 2 de Trèfle obligatoire -----------------------------------

func test_first_trick_leader_must_play_two_of_clubs_if_held() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.CLUBS, Rank.TWO),
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(1)
	assert_bool(legal[0].equals(CardModel.new(Suit.CLUBS, Rank.TWO))).is_true()


func test_first_trick_leader_without_two_of_clubs_follows_normal_lead_rules() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(2)


# --- Premier pli : pas de carte à points (Cœur / Dame de Pique) -------------

func test_cannot_lead_penalty_card_on_first_trick() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, -1, true)

	assert_array(legal).has_size(1)
	assert_bool(legal[0].equals(CardModel.new(Suit.DIAMONDS, Rank.FIVE))).is_true()


func test_cannot_discard_penalty_card_on_first_trick_when_alternative_exists() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).has_size(1)
	assert_bool(legal[0].equals(CardModel.new(Suit.DIAMONDS, Rank.FIVE))).is_true()


func test_forced_to_play_penalty_card_on_first_trick_when_no_alternative() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
	])

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).has_size(2)


func test_legal_plays_empty_when_hand_is_empty() -> void:
	var engine := RuleEngine.new()
	var hand := PlayerHand.new()

	var legal := engine.get_legal_plays(hand, Suit.CLUBS, false)

	assert_array(legal).is_empty()


# --- validate_play ------------------------------------------------------------

func test_validate_play_returns_valid_for_legal_card() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	var hand := _hand_of([CardModel.new(Suit.CLUBS, Rank.FIVE)])

	var result := engine.validate_play(CardModel.new(Suit.CLUBS, Rank.FIVE), hand, Suit.CLUBS, false)

	assert_int(result).is_equal(RuleEngine.ValidationResult.VALID)


func test_validate_play_returns_card_not_in_hand() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([CardModel.new(Suit.CLUBS, Rank.FIVE)])

	var result := engine.validate_play(CardModel.new(Suit.DIAMONDS, Rank.NINE), hand, Suit.CLUBS, false)

	assert_int(result).is_equal(RuleEngine.ValidationResult.CARD_NOT_IN_HAND)


func test_validate_play_returns_must_follow_suit() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	var hand := _hand_of([
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.DIAMONDS, Rank.NINE),
	])

	var result := engine.validate_play(CardModel.new(Suit.DIAMONDS, Rank.NINE), hand, Suit.CLUBS, false)

	assert_int(result).is_equal(RuleEngine.ValidationResult.MUST_FOLLOW_SUIT)


func test_validate_play_returns_must_play_two_of_clubs() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.CLUBS, Rank.TWO),
		CardModel.new(Suit.DIAMONDS, Rank.NINE),
	])

	var result := engine.validate_play(CardModel.new(Suit.DIAMONDS, Rank.NINE), hand, -1, true)

	assert_int(result).is_equal(RuleEngine.ValidationResult.MUST_PLAY_TWO_OF_CLUBS)


func test_validate_play_returns_cannot_lead_hearts_unbroken() -> void:
	var engine := RuleEngine.new()
	engine.trick_number = 2
	engine.is_first_trick = false
	engine.hearts_broken = false
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	])

	var result := engine.validate_play(CardModel.new(Suit.HEARTS, Rank.TWO), hand, -1, true)

	assert_int(result).is_equal(RuleEngine.ValidationResult.CANNOT_LEAD_HEARTS_UNBROKEN)


func test_validate_play_returns_cannot_play_penalty_on_first_trick() -> void:
	var engine := RuleEngine.new()
	var hand := _hand_of([
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.DIAMONDS, Rank.FIVE),
	])

	var result := engine.validate_play(CardModel.new(Suit.SPADES, Rank.QUEEN), hand, -1, true)

	assert_int(result).is_equal(RuleEngine.ValidationResult.CANNOT_PLAY_PENALTY_ON_FIRST_TRICK)


# --- can_lead_suit (statique) -------------------------------------------------

func test_can_lead_suit_allows_non_heart_suits_always() -> void:
	var hand := _hand_of([CardModel.new(Suit.CLUBS, Rank.FIVE)])
	assert_bool(RuleEngine.can_lead_suit(Suit.CLUBS, hand, false)).is_true()
	assert_bool(RuleEngine.can_lead_suit(Suit.SPADES, hand, false)).is_true()


func test_can_lead_suit_forbids_hearts_when_not_broken_and_other_suits_available() -> void:
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	])
	assert_bool(RuleEngine.can_lead_suit(Suit.HEARTS, hand, false)).is_false()


func test_can_lead_suit_allows_hearts_when_broken() -> void:
	var hand := _hand_of([
		CardModel.new(Suit.HEARTS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	])
	assert_bool(RuleEngine.can_lead_suit(Suit.HEARTS, hand, true)).is_true()


func test_can_lead_suit_allows_hearts_when_only_hearts_left() -> void:
	var hand := _hand_of([CardModel.new(Suit.HEARTS, Rank.FIVE)])
	assert_bool(RuleEngine.can_lead_suit(Suit.HEARTS, hand, false)).is_true()


# --- get_trick_winner ----------------------------------------------------------

func test_trick_winner_is_highest_card_of_lead_suit() -> void:
	var trick: Array[Dictionary] = [
		{"player_index": 0, "card": CardModel.new(Suit.CLUBS, Rank.FIVE)},
		{"player_index": 1, "card": CardModel.new(Suit.CLUBS, Rank.KING)},
		{"player_index": 2, "card": CardModel.new(Suit.HEARTS, Rank.ACE)},
		{"player_index": 3, "card": CardModel.new(Suit.CLUBS, Rank.NINE)},
	]

	var winner := RuleEngine.get_trick_winner(trick)

	assert_int(winner).is_equal(1)


func test_trick_winner_ignores_off_suit_cards_even_if_higher_rank() -> void:
	var trick: Array[Dictionary] = [
		{"player_index": 0, "card": CardModel.new(Suit.DIAMONDS, Rank.TWO)},
		{"player_index": 1, "card": CardModel.new(Suit.SPADES, Rank.ACE)},
		{"player_index": 2, "card": CardModel.new(Suit.DIAMONDS, Rank.THREE)},
	]

	var winner := RuleEngine.get_trick_winner(trick)

	assert_int(winner).is_equal(2)


# --- score_trick / score_hand ---------------------------------------------------

func test_score_trick_counts_hearts_and_queen_of_spades() -> void:
	var cards: Array[CardModel] = [
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
	]

	assert_int(RuleEngine.score_trick(cards)).is_equal(15)


func test_score_trick_of_cards_without_points_is_zero() -> void:
	var cards: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.SPADES, Rank.KING),
	]

	assert_int(RuleEngine.score_trick(cards)).is_equal(0)


func test_score_hand_without_shoot_the_moon_uses_raw_points() -> void:
	var tricks_taken_per_player: Array = [
		[CardModel.new(Suit.HEARTS, Rank.TWO)],
		[CardModel.new(Suit.SPADES, Rank.QUEEN)],
		[] as Array[CardModel],
		[CardModel.new(Suit.HEARTS, Rank.THREE), CardModel.new(Suit.HEARTS, Rank.FOUR)],
	]

	var scores := RuleEngine.score_hand(tricks_taken_per_player)

	assert_int(scores[0]).is_equal(1)
	assert_int(scores[1]).is_equal(13)
	assert_int(scores[2]).is_equal(0)
	assert_int(scores[3]).is_equal(2)


func test_score_hand_detects_shoot_the_moon() -> void:
	var all_hearts_and_queen: Array[CardModel] = []
	for rank in Rank.ALL:
		all_hearts_and_queen.append(CardModel.new(Suit.HEARTS, rank))
	all_hearts_and_queen.append(CardModel.new(Suit.SPADES, Rank.QUEEN))

	var tricks_taken_per_player: Array = [
		all_hearts_and_queen,
		[] as Array[CardModel],
		[] as Array[CardModel],
		[] as Array[CardModel],
	]

	var scores := RuleEngine.score_hand(tricks_taken_per_player)

	assert_int(scores[0]).is_equal(0)
	assert_int(scores[1]).is_equal(HeartsRules.TOTAL_POINTS_PER_HAND)
	assert_int(scores[2]).is_equal(HeartsRules.TOTAL_POINTS_PER_HAND)
	assert_int(scores[3]).is_equal(HeartsRules.TOTAL_POINTS_PER_HAND)


# --- État de l'instance (reset / avance de pli) ----------------------------------

func test_reset_for_new_hand_restores_initial_state() -> void:
	var engine := RuleEngine.new()
	engine.hearts_broken = true
	engine.trick_number = 7
	engine.is_first_trick = false

	engine.reset_for_new_hand()

	assert_bool(engine.hearts_broken).is_false()
	assert_int(engine.trick_number).is_equal(1)
	assert_bool(engine.is_first_trick).is_true()


func test_advance_to_next_trick_increments_and_clears_first_trick_flag() -> void:
	var engine := RuleEngine.new()

	engine.advance_to_next_trick()

	assert_int(engine.trick_number).is_equal(2)
	assert_bool(engine.is_first_trick).is_false()


# --- HeartsRules ------------------------------------------------------------------

func test_hearts_rules_card_points() -> void:
	assert_int(HeartsRules.card_points(CardModel.new(Suit.HEARTS, Rank.TWO))).is_equal(1)
	assert_int(HeartsRules.card_points(CardModel.new(Suit.SPADES, Rank.QUEEN))).is_equal(13)
	assert_int(HeartsRules.card_points(CardModel.new(Suit.CLUBS, Rank.ACE))).is_equal(0)


func test_hearts_rules_has_only_hearts() -> void:
	assert_bool(HeartsRules.has_only_hearts([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.HEARTS, Rank.THREE),
	] as Array[CardModel])).is_true()
	assert_bool(HeartsRules.has_only_hearts([
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.CLUBS, Rank.THREE),
	] as Array[CardModel])).is_false()
	assert_bool(HeartsRules.has_only_hearts([] as Array[CardModel])).is_false()
