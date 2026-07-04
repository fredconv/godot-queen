class_name TestAiPlayer
extends GdUnitTestSuite
## Tests unitaires de `AiPlayer` et de ses stratégies (`RandomLegalStrategy`,
## `HeuristicStrategy`), étape 5 : l'IA ne joue jamais un coup illégal, un
## même seed reproduit toujours le même choix, et les heuristiques de
## `HeuristicStrategy` se comportent comme documenté. Voir docs/TEST_PLAN.md.

const HAND_SEEDS_TO_CHECK: int = 20


# --- Jamais de coup illégal (croisé avec RuleEngine/MatchManager) -----------

func test_random_strategy_never_plays_illegal_card_across_full_simulated_hands() -> void:
	_assert_strategy_never_plays_illegal_card(RandomLegalStrategy.new())


func test_heuristic_strategy_never_plays_illegal_card_across_full_simulated_hands() -> void:
	_assert_strategy_never_plays_illegal_card(HeuristicStrategy.new())


func _assert_strategy_never_plays_illegal_card(strategy: AiStrategy) -> void:
	for hand_seed in range(HAND_SEEDS_TO_CHECK):
		var match_manager := MatchManager.new()
		match_manager.start_new_hand(hand_seed)
		var ai_player := AiPlayer.new(strategy, hand_seed)

		while match_manager.phase == MatchManager.Phase.PLAYING:
			var player_index: int = match_manager.current_player
			var legal := match_manager.get_legal_plays(player_index)
			var context := match_manager.build_ai_context(player_index)

			var chosen := ai_player.choose_card(legal, context)

			assert_bool(_contains(legal, chosen)).is_true()

			var result := match_manager.play_card(player_index, chosen)
			assert_bool(result.success).is_true()

		assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)


func test_choose_card_always_returns_a_card_from_legal_plays() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
	]
	var context := {"is_leading": false, "lead_suit": Suit.DIAMONDS, "trick_cards": []}
	var ai_player := AiPlayer.new(HeuristicStrategy.new(), 99)

	for _i in range(HAND_SEEDS_TO_CHECK):
		var chosen := ai_player.choose_card(legal, context)
		assert_bool(_contains(legal, chosen)).is_true()


# --- Déterminisme par seed ----------------------------------------------------

func test_same_seed_produces_the_same_choice_given_the_same_state() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.CLUBS, Rank.NINE),
	]
	var context := {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": [], "hearts_broken": false, "trick_number": 1}

	var ai_a := AiPlayer.new(RandomLegalStrategy.new(), 7)
	var ai_b := AiPlayer.new(RandomLegalStrategy.new(), 7)

	var choice_a := ai_a.choose_card(legal, context)
	var choice_b := ai_b.choose_card(legal, context)

	assert_bool(choice_a.equals(choice_b)).is_true()


func test_different_seeds_can_produce_different_choices() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.CLUBS, Rank.NINE),
		CardModel.new(Suit.CLUBS, Rank.TWO),
	]
	var context := {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": []}

	var seen_ids: Dictionary = {}
	for seed_value in range(10):
		var ai_player := AiPlayer.new(RandomLegalStrategy.new(), seed_value)
		var chosen := ai_player.choose_card(legal, context)
		seen_ids[chosen.get_id()] = true

	assert_int(seen_ids.size()).is_greater(1)


# --- HeuristicStrategy : entame de pli ----------------------------------------

func test_heuristic_avoids_leading_a_penalty_card_when_an_alternative_exists() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.HEARTS, Rank.ACE),
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.SPADES, Rank.QUEEN),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": true})

	assert_bool(chosen.equals(CardModel.new(Suit.CLUBS, Rank.FIVE))).is_true()


func test_heuristic_leads_the_lowest_non_penalty_card() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.THREE),
		CardModel.new(Suit.SPADES, Rank.NINE),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": true})

	assert_bool(chosen.equals(CardModel.new(Suit.DIAMONDS, Rank.THREE))).is_true()


func test_heuristic_is_forced_to_lead_a_penalty_card_when_hand_has_no_alternative() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.HEARTS, Rank.SEVEN),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": true})

	assert_bool(chosen.equals(CardModel.new(Suit.HEARTS, Rank.TWO))).is_true()


# --- HeuristicStrategy : défausse quand impossible de suivre la couleur -----

func test_heuristic_dumps_the_queen_of_spades_when_void_of_lead_suit() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.SPADES, Rank.QUEEN),
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.DIAMONDS, Rank.TWO),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": []})

	assert_bool(chosen.equals(CardModel.new(Suit.SPADES, Rank.QUEEN))).is_true()


func test_heuristic_dumps_the_highest_heart_when_no_queen_of_spades_available() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.HEARTS, Rank.KING),
		CardModel.new(Suit.HEARTS, Rank.TWO),
		CardModel.new(Suit.DIAMONDS, Rank.THREE),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": []})

	assert_bool(chosen.equals(CardModel.new(Suit.HEARTS, Rank.KING))).is_true()


func test_heuristic_dumps_the_highest_card_when_no_penalty_card_available() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.DIAMONDS, Rank.THREE),
		CardModel.new(Suit.DIAMONDS, Rank.JACK),
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": []})

	assert_bool(chosen.equals(CardModel.new(Suit.DIAMONDS, Rank.JACK))).is_true()


# --- HeuristicStrategy : suit de couleur (duck / gagne forcé) ----------------

func test_heuristic_ducks_below_the_current_winning_card_when_possible() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.FIVE),
		CardModel.new(Suit.CLUBS, Rank.NINE),
		CardModel.new(Suit.CLUBS, Rank.ACE),
	]
	var trick_cards: Array = [
		{"player_index": 0, "card": CardModel.new(Suit.CLUBS, Rank.TEN)},
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": trick_cards})

	assert_bool(chosen.equals(CardModel.new(Suit.CLUBS, Rank.NINE))).is_true()


func test_heuristic_plays_the_lowest_winning_card_when_forced_to_win() -> void:
	var legal: Array[CardModel] = [
		CardModel.new(Suit.CLUBS, Rank.JACK),
		CardModel.new(Suit.CLUBS, Rank.ACE),
	]
	var trick_cards: Array = [
		{"player_index": 0, "card": CardModel.new(Suit.CLUBS, Rank.TEN)},
	]
	var chosen := _choose(HeuristicStrategy.new(), legal, {"is_leading": false, "lead_suit": Suit.CLUBS, "trick_cards": trick_cards})

	assert_bool(chosen.equals(CardModel.new(Suit.CLUBS, Rank.JACK))).is_true()


# --- Utilitaires locaux --------------------------------------------------------

static func _choose(strategy: AiStrategy, legal_plays: Array[CardModel], context: Dictionary) -> CardModel:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	return strategy.choose_card(legal_plays, context, rng)


static func _contains(cards: Array[CardModel], card: CardModel) -> bool:
	for existing_card in cards:
		if existing_card.equals(card):
			return true
	return false
