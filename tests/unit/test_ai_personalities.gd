class_name TestAiPersonalities
extends GdUnitTestSuite


const HAND_SEEDS_TO_CHECK: int = 15


#region illegal_plays
func test_passive_strategy_never_plays_illegal_card() -> void:
	_assert_strategy_never_plays_illegal_card(PassiveStrategy.new())


func test_moon_shooter_strategy_never_plays_illegal_card() -> void:
	_assert_strategy_never_plays_illegal_card(MoonShooterStrategy.new())
#endregion


#region catalog
func test_mixed_mode_assigns_three_distinct_opponent_types() -> void:
	if not AiPersonalityCatalog.USE_MIXED_PERSONALITIES:
		return
	assert_that(AiPersonalityCatalog.create_for_opponent_seat(1)).is_instanceof(AdaptiveAiStrategy)
	assert_that(AiPersonalityCatalog.create_for_opponent_seat(2)).is_instanceof(AdaptiveAiStrategy)
	assert_that(AiPersonalityCatalog.create_for_opponent_seat(3)).is_instanceof(AdaptiveAiStrategy)


func test_catalog_creates_heuristic_when_balanced_personality() -> void:
	assert_that(AiPersonalityCatalog.create_strategy(AiPersonalityKind.Kind.BALANCED)) \
		.is_instanceof(HeuristicStrategy)
#endregion


func _assert_strategy_never_plays_illegal_card(strategy: AiStrategy) -> void:
	for hand_seed in range(HAND_SEEDS_TO_CHECK):
		var match_manager := MatchManager.new()
		match_manager.start_new_hand(hand_seed + 500)
		var ai_player := AiPlayer.new(strategy, hand_seed + 500)

		while match_manager.phase == MatchManager.Phase.PLAYING:
			var player_index: int = match_manager.current_player
			var legal := match_manager.get_legal_plays(player_index)
			var context := match_manager.build_ai_context(player_index)
			var chosen := ai_player.choose_card(legal, context)
			assert_bool(_contains(legal, chosen)).is_true()
			var result := match_manager.play_card(player_index, chosen)
			assert_bool(result.success).is_true()

		assert_int(match_manager.phase).is_equal(MatchManager.Phase.HAND_END)


static func _contains(cards: Array[CardModel], card: CardModel) -> bool:
	for entry in cards:
		if entry.equals(card):
			return true
	return false
