class_name LocalMatchController
extends MatchControllerBase
## Contrôleur de partie locale : actions, événements et snapshots sans réseau.


var match_manager: MatchManager


func _init(manager: MatchManager = null) -> void:
	match_manager = manager if manager != null else MatchManager.new()


func start_new_match(seed_value: int = -1) -> void:
	match_manager.start_new_match(seed_value)


func get_match_manager() -> MatchManager:
	return match_manager


func submit_action(action: PlayerAction) -> ActionResult:
	if action == null:
		return _invalid_action_result()
	if action is PlayCardAction:
		return _submit_play_card(action as PlayCardAction)
	return _invalid_action_result()


func get_public_snapshot() -> PublicGameSnapshot:
	return GameSnapshotBuilder.build_public(match_manager)


func get_private_snapshot(player_index: int) -> PrivatePlayerSnapshot:
	return GameSnapshotBuilder.build_private(match_manager, player_index)


func play_ai_turn() -> ActionResult:
	var player_index: int = match_manager.current_player
	if not match_manager.is_ai_controlled(player_index):
		return _invalid_action_result()
	var legal: Array[CardModel] = match_manager.get_legal_plays(player_index)
	var context: Dictionary = match_manager.build_ai_context(player_index)
	var card: CardModel = match_manager.ai_players[player_index].choose_card(legal, context)
	return submit_action(PlayCardAction.new(player_index, card))


func _submit_play_card(action: PlayCardAction) -> ActionResult:
	if action.card == null:
		return _invalid_action_result()
	var trick_index: int = match_manager.rule_engine.trick_number
	var play_result: MatchManager.PlayResult = match_manager.play_card(action.player_index, action.card)
	var events: Array[GameEvent] = []
	if play_result.success:
		var next_player: int = match_manager.current_player if not play_result.trick_completed else play_result.trick_winner
		events.append(CardPlayedEvent.new(action.player_index, action.card, trick_index, next_player))
		if play_result.trick_completed:
			events.append(TrickResolvedEvent.new(
				play_result.trick_winner,
				play_result.trick_points,
				trick_index
			))
		if play_result.hand_completed:
			events.append(HandCompletedEvent.new(
				match_manager.last_hand_scores,
				match_manager.hand_number
			))
			events.append(ScoresUpdatedEvent.new(match_manager.score_manager.get_scores()))
		if play_result.match_completed:
			events.append(MatchCompletedEvent.new(
				match_manager.get_match_winner(),
				match_manager.score_manager.get_scores()
			))
	return ActionResult.from_play_result(play_result, events)


func _invalid_action_result() -> ActionResult:
	var result := ActionResult.new()
	result.success = false
	result.error_code = ActionResult.ERROR_INVALID_ACTION
	return result
