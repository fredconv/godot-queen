class_name TestMatchAiSimulation
extends GdUnitTestSuite
## Tests d'intégration de bout en bout (étape 5) : manche puis partie
## complètes pilotées par 4 `AiPlayer` utilisant la stratégie IA par défaut
## (`HeuristicStrategy`), sans aucune scène ni UI. Vérifie que l'IA "solide"
## ne casse jamais le déroulement du jeu (`MatchManager.play_ai_turn()`) et
## que le résultat d'une partie complète est déterministe pour une seed
## fixée. Voir docs/TEST_PLAN.md et docs/DECISIONS.md (ADR-019).

## Garde-fou anti-boucle infinie : une manche rapporte toujours strictement
## plus de 0 point au total (26, ou 78 en cas de "shoot the moon"), donc une
## partie jusqu'à `MatchManager.MATCH_SCORE_THRESHOLD` termine forcément bien
## avant ce nombre de manches ; ce plafond ne sert qu'à éviter un test qui
## boucle indéfiniment si un bug de scoring venait à apparaître.
const MAX_HANDS: int = 200

static func _new_match_with_ai(seed_value: int) -> MatchManager:
	var match_manager := MatchManager.new()
	for player_index in range(HeartsRules.PLAYER_COUNT):
		match_manager.set_ai_player(player_index, AiPlayer.new(HeuristicStrategy.new(), seed_value + player_index))
	return match_manager

static func _play_current_hand(match_manager: MatchManager) -> void:
	while match_manager.phase == MatchManager.Phase.PLAYING:
		match_manager.play_ai_turn()

static func _play_full_match(seed_value: int) -> MatchManager:
	var match_manager := _new_match_with_ai(seed_value)
	match_manager.start_new_match(seed_value)
	_play_current_hand(match_manager)

	var hand_offset := 1
	while not match_manager.is_match_over() and hand_offset < MAX_HANDS:
		match_manager.start_new_hand(seed_value + hand_offset)
		_play_current_hand(match_manager)
		hand_offset += 1

	return match_manager


# --- Manche complète, 4 IA ---------------------------------------------------

func test_full_hand_with_four_ai_players_completes_without_error() -> void:
	var match_manager := _new_match_with_ai(50)
	match_manager.start_new_hand(50)

	_play_current_hand(match_manager)

	assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)
	for hand in match_manager.hands:
		assert_bool(hand.is_empty()).is_true()


func test_several_seeds_complete_a_full_ai_hand_without_error() -> void:
	for seed_value in range(60, 70):
		var match_manager := _new_match_with_ai(seed_value)
		match_manager.start_new_hand(seed_value)

		_play_current_hand(match_manager)

		assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)


func test_ai_hand_scores_sum_to_total_points_or_shoot_the_moon() -> void:
	var match_manager := _new_match_with_ai(51)
	match_manager.start_new_hand(51)

	_play_current_hand(match_manager)

	var total := 0
	for score in match_manager.score_manager.get_scores():
		total += score

	var is_normal_total := total == HeartsRules.TOTAL_POINTS_PER_HAND
	var is_shoot_the_moon_total := total == HeartsRules.TOTAL_POINTS_PER_HAND * 3
	assert_bool(is_normal_total or is_shoot_the_moon_total).is_true()


# --- Partie complète jusqu'au seuil de points, 4 IA --------------------------

func test_full_match_with_four_ai_players_reaches_match_end() -> void:
	var match_manager := _play_full_match(100)

	assert_bool(match_manager.is_match_over()).is_true()

	var winner := match_manager.get_match_winner()
	assert_bool(winner >= 0 and winner < HeartsRules.PLAYER_COUNT).is_true()

	var max_score := 0
	for score in match_manager.score_manager.get_scores():
		max_score = max(max_score, score)
	assert_int(max_score).is_greater_equal(MatchManager.MATCH_SCORE_THRESHOLD)


func test_same_seed_produces_a_deterministic_match_end_state() -> void:
	var match_a := _play_full_match(200)
	var match_b := _play_full_match(200)

	assert_int(match_a.hand_number).is_equal(match_b.hand_number)
	assert_int(match_a.get_match_winner()).is_equal(match_b.get_match_winner())
	assert_array(match_a.score_manager.get_scores()).is_equal(match_b.score_manager.get_scores())
