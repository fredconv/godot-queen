class_name MatchSimulator
extends RefCounted
## Simule une partie complète (4 IA) sans scène ni UI.
## Réutilise `MatchManager` / `AiPlayer` — même moteur que le jeu réel.

const MAX_HANDS: int = 200

var strategy_factory: Callable = _default_strategy_factory


func _default_strategy_factory(player_index: int, _seed_value: int) -> AiStrategy:
	return AiPersonalityCatalog.create_for_seat(player_index)


func play_match(seed_value: int) -> Dictionary:
	var match_manager := _new_match_manager(seed_value)
	match_manager.start_new_match(seed_value)
	_play_current_hand(match_manager)

	var hand_offset := 1
	while not match_manager.is_match_over() and hand_offset < MAX_HANDS:
		match_manager.start_new_hand(seed_value + hand_offset)
		_play_current_hand(match_manager)
		hand_offset += 1

	if not match_manager.is_match_over():
		push_warning("MatchSimulator: partie non terminée après %d manches (seed %d)" % [MAX_HANDS, seed_value])

	return {
		"seed": seed_value,
		"winner_index": match_manager.get_match_winner(),
		"final_scores": match_manager.score_manager.get_scores(),
		"hand_count": match_manager.hand_number,
		"match_completed": match_manager.is_match_over(),
	}


func _new_match_manager(seed_value: int) -> MatchManager:
	var match_manager := MatchManager.new()
	for player_index in range(HeartsRules.PLAYER_COUNT):
		var strategy: AiStrategy = strategy_factory.call(player_index, seed_value + player_index)
		match_manager.set_ai_player(
			player_index,
			AiPlayer.new(strategy, seed_value + player_index)
		)
	return match_manager


static func _play_current_hand(match_manager: MatchManager) -> void:
	while match_manager.phase == MatchManager.Phase.PLAYING:
		match_manager.play_ai_turn()
