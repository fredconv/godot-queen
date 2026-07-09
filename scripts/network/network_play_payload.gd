class_name NetworkPlayPayload
extends RefCounted
## Sérialisation des coups confirmés host → clients.


static func action_to_dict(action: PlayCardAction) -> Dictionary:
	return action.to_dict()


static func play_result_to_dict(play_result: MatchManager.PlayResult) -> Dictionary:
	if play_result == null:
		return {}
	return {
		"success": play_result.success,
		"play_error": play_result.play_error,
		"rule_violation": play_result.rule_violation,
		"trick_completed": play_result.trick_completed,
		"trick_winner": play_result.trick_winner,
		"trick_points": play_result.trick_points,
		"hand_completed": play_result.hand_completed,
		"match_completed": play_result.match_completed,
	}


static func play_result_from_dict(data: Dictionary) -> MatchManager.PlayResult:
	var play_result := MatchManager.PlayResult.new()
	play_result.success = bool(data.get("success", false))
	play_result.play_error = int(data.get("play_error", MatchManager.PlayError.NONE))
	play_result.rule_violation = int(data.get("rule_violation", RuleEngine.ValidationResult.VALID))
	play_result.trick_completed = bool(data.get("trick_completed", false))
	play_result.trick_winner = int(data.get("trick_winner", -1))
	play_result.trick_points = int(data.get("trick_points", 0))
	play_result.hand_completed = bool(data.get("hand_completed", false))
	play_result.match_completed = bool(data.get("match_completed", false))
	return play_result
