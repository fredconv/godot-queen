class_name TestMatchManager
extends GdUnitTestSuite
## Tests d'intégration de MatchManager : déroulement complet d'une manche à
## 4 joueurs pilotés par une IA déterministe (`AiPlayer` + `RandomLegalStrategy`,
## voir tests/integration/test_match_ai_simulation.gd pour la simulation avec
## la stratégie IA par défaut de l'étape 5), sans aucune scène ni UI. Voir
## docs/TEST_PLAN.md.

## Simule une manche complète (jusqu'à `Phase.PLAYING` terminé) en assignant
## un `AiPlayer` aux 4 sièges puis en enchaînant `MatchManager.play_ai_turn()`.
## `seed_value` pilote à la fois le mélange du paquet et les choix de l'IA
## (une seed différente par siège pour éviter des `AiPlayer` parfaitement
## synchronisés) : une même seed reproduit toujours la même manche.
func _play_full_hand(match_manager: MatchManager, seed_value: int) -> int:
	match_manager.start_new_hand(seed_value)
	for player_index in range(HeartsRules.PLAYER_COUNT):
		match_manager.set_ai_player(player_index, AiPlayer.new(RandomLegalStrategy.new(), seed_value + player_index))

	var tricks_played := 0
	while match_manager.phase == MatchManager.Phase.PLAYING:
		var result := match_manager.play_ai_turn()
		assert_bool(result.success).is_true()

		if result.trick_completed:
			tricks_played += 1

	return tricks_played


# --- Déroulement complet d'une manche ---------------------------------------

func test_full_hand_plays_thirteen_tricks() -> void:
	var match_manager := MatchManager.new()

	var tricks_played := _play_full_hand(match_manager, 1)

	assert_int(tricks_played).is_equal(HeartsRules.CARDS_PER_HAND)


func test_full_hand_empties_every_player_hand() -> void:
	var match_manager := MatchManager.new()

	_play_full_hand(match_manager, 1)

	for hand in match_manager.hands:
		assert_bool(hand.is_empty()).is_true()


func test_full_hand_reaches_hand_end_phase() -> void:
	var match_manager := MatchManager.new()

	_play_full_hand(match_manager, 2)

	assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)


func test_full_hand_scores_sum_to_total_points_or_shoot_the_moon() -> void:
	var match_manager := MatchManager.new()

	_play_full_hand(match_manager, 3)

	var total := 0
	for score in match_manager.score_manager.get_scores():
		total += score

	var is_normal_total := total == HeartsRules.TOTAL_POINTS_PER_HAND
	var is_shoot_the_moon_total := total == HeartsRules.TOTAL_POINTS_PER_HAND * 3
	assert_bool(is_normal_total or is_shoot_the_moon_total).is_true()


func test_several_seeds_always_produce_a_fully_played_hand() -> void:
	for seed_value in range(4, 14):
		var match_manager := MatchManager.new()
		var tricks_played := _play_full_hand(match_manager, seed_value)
		assert_int(tricks_played).is_equal(HeartsRules.CARDS_PER_HAND)


# --- start_new_match : cumul des scores sur plusieurs manches ---------------

func test_start_new_match_resets_cumulative_scores_then_deals_first_hand() -> void:
	var match_manager := MatchManager.new()
	match_manager.start_new_match(10)

	assert_int(match_manager.hand_number).is_equal(1)
	assert_int(match_manager.phase).is_equal(MatchManager.Phase.PLAYING)
	for score in match_manager.score_manager.get_scores():
		assert_int(score).is_equal(0)


func test_playing_two_hands_accumulates_scores_across_hands() -> void:
	var match_manager := MatchManager.new()

	_play_full_hand(match_manager, 20)
	var scores_after_first_hand := match_manager.score_manager.get_scores()

	_play_full_hand(match_manager, 21)
	var scores_after_second_hand := match_manager.score_manager.get_scores()

	var total_after_first := 0
	for score in scores_after_first_hand:
		total_after_first += score
	var total_after_second := 0
	for score in scores_after_second_hand:
		total_after_second += score

	assert_int(total_after_second).is_greater_equal(total_after_first)


# --- Validation des coups (délégation à RuleEngine) -------------------------

func test_illegal_play_is_rejected_and_state_unchanged() -> void:
	var match_manager := MatchManager.new()
	match_manager.start_new_hand(5)

	var leader: int = match_manager.current_player
	var hand: PlayerHand = match_manager.hands[leader]
	var illegal_card: CardModel = null
	for card in hand.cards():
		if not HeartsRules.is_two_of_clubs(card):
			illegal_card = card
			break
	var hand_count_before := hand.count()

	var result := match_manager.play_card(leader, illegal_card)

	assert_bool(result.success).is_false()
	assert_int(result.play_error).is_equal(MatchManager.PlayError.RULE_VIOLATION)
	assert_int(result.rule_violation).is_equal(RuleEngine.ValidationResult.MUST_PLAY_TWO_OF_CLUBS)
	assert_int(hand.count()).is_equal(hand_count_before)
	assert_int(match_manager.current_player).is_equal(leader)


func test_playing_out_of_turn_is_rejected() -> void:
	var match_manager := MatchManager.new()
	match_manager.start_new_hand(6)

	var leader: int = match_manager.current_player
	var other_player := (leader + 1) % HeartsRules.PLAYER_COUNT
	var some_card: CardModel = match_manager.hands[other_player].cards()[0]

	var result := match_manager.play_card(other_player, some_card)

	assert_bool(result.success).is_false()
	assert_int(result.play_error).is_equal(MatchManager.PlayError.NOT_YOUR_TURN)


func test_playing_before_a_hand_is_dealt_is_rejected() -> void:
	var match_manager := MatchManager.new()

	var result := match_manager.play_card(0, CardModel.new(Suit.CLUBS, Rank.TWO))

	assert_bool(result.success).is_false()
	assert_int(result.play_error).is_equal(MatchManager.PlayError.WRONG_PHASE)


func test_leader_holding_two_of_clubs_must_be_the_actual_holder() -> void:
	var match_manager := MatchManager.new()
	match_manager.start_new_hand(7)

	var leader: int = match_manager.current_player
	assert_bool(match_manager.hands[leader].contains(CardModel.new(Suit.CLUBS, Rank.TWO))).is_true()


# --- Scores affichés pendant la manche (progression + cumul) ----------------

func test_display_scores_include_current_hand_progress_while_playing() -> void:
	var match_manager := MatchManager.new()
	match_manager.start_new_hand(42)
	for player_index in range(HeartsRules.PLAYER_COUNT):
		match_manager.set_ai_player(player_index, AiPlayer.new(RandomLegalStrategy.new(), 42 + player_index))

	var saw_hand_progress := false
	while match_manager.phase == MatchManager.Phase.PLAYING:
		var result := match_manager.play_ai_turn()
		assert_bool(result.success).is_true()
		if result.trick_completed and match_manager.phase == MatchManager.Phase.PLAYING:
			var display := match_manager.get_display_scores()
			var cumulative := match_manager.score_manager.get_scores()
			var hand_raw := match_manager.get_current_hand_raw_scores()
			for player_index in range(HeartsRules.PLAYER_COUNT):
				assert_int(display[player_index]).is_equal(cumulative[player_index] + hand_raw[player_index])
			var hand_total := 0
			for score in hand_raw:
				hand_total += score
			if hand_total > 0:
				saw_hand_progress = true

	assert_bool(saw_hand_progress).is_true()


func test_display_scores_equal_cumulative_after_hand_end() -> void:
	var match_manager := MatchManager.new()
	_play_full_hand(match_manager, 55)

	assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)
	assert_int(match_manager.last_hand_scores.size()).is_equal(HeartsRules.PLAYER_COUNT)
