class_name MoonSuspicion
extends RefCounted
## Estime si un adversaire prépare une tentative de Lune.


const BREAK_THRESHOLD: float = 40.0
const MIN_TRICK_TO_BREAK: int = 3

const POINTS_WEIGHT: float = 1.2
const TRICKS_WON_WEIGHT: float = 8.0
const STREAK_WEIGHT: float = 10.0
const SOLE_COLLECTOR_BONUS: float = 25.0
const EARLY_HEARTS_BONUS: float = 15.0
const MID_HAND_BONUS: float = 5.0


static func find_top_suspect(context: Dictionary) -> Dictionary:
	var observer_index: int = context.get("player_index", -1)
	var hand_scores: Array = context.get("hand_raw_scores", [])
	var tricks_won: Array = context.get("tricks_won_counts", [])
	var consecutive_wins: Array = context.get("consecutive_trick_wins", [])
	var trick_number: int = context.get("trick_number", 1)

	var best_index := -1
	var best_score := 0.0
	for suspect_index in range(HeartsRules.PLAYER_COUNT):
		if suspect_index == observer_index:
			continue
		var suspicion := evaluate_player(
			suspect_index,
			hand_scores,
			tricks_won,
			consecutive_wins,
			trick_number
		)
		if suspicion > best_score:
			best_score = suspicion
			best_index = suspect_index

	return {
		"player_index": best_index,
		"score": best_score,
	}


static func evaluate_player(
	suspect_index: int,
	hand_scores: Array,
	tricks_won: Array,
	consecutive_wins: Array,
	trick_number: int
) -> float:
	if hand_scores.size() <= suspect_index:
		return 0.0

	var suspect_points: int = hand_scores[suspect_index]
	var tricks_won_count: int = tricks_won[suspect_index] if tricks_won.size() > suspect_index else 0
	var streak: int = consecutive_wins[suspect_index] if consecutive_wins.size() > suspect_index else 0

	if suspect_points == 0 and tricks_won_count <= 1:
		return 0.0

	var score := 0.0
	score += float(suspect_points) * POINTS_WEIGHT
	score += float(tricks_won_count) * TRICKS_WON_WEIGHT
	score += float(streak) * STREAK_WEIGHT

	if _is_sole_penalty_collector(suspect_index, hand_scores):
		score += SOLE_COLLECTOR_BONUS
	if suspect_points >= 3 and _others_have_no_points(suspect_index, hand_scores):
		score += EARLY_HEARTS_BONUS
	if trick_number >= 2:
		score += MID_HAND_BONUS

	return score


static func should_break_moon(context: Dictionary) -> bool:
	if context.get("moon_busted", false):
		return false
	if context.get("trick_number", 1) < MIN_TRICK_TO_BREAK:
		return false
	var suspect: Dictionary = find_top_suspect(context)
	if suspect.get("player_index", -1) < 0:
		return false
	return float(suspect.get("score", 0.0)) >= BREAK_THRESHOLD


static func _is_sole_penalty_collector(suspect_index: int, hand_scores: Array) -> bool:
	if hand_scores[suspect_index] <= 0:
		return false
	return _others_have_no_points(suspect_index, hand_scores)


static func _others_have_no_points(suspect_index: int, hand_scores: Array) -> bool:
	for player_index in range(hand_scores.size()):
		if player_index == suspect_index:
			continue
		if hand_scores[player_index] > 0:
			return false
	return true
