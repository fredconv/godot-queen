class_name AiConfidence
extends RefCounted
## Score de confiance IA (0.0–1.0) : monte quand la partie se passe bien,
## baisse après les mauvaises manches. Module l'audace (lune, agressivité).


const DEFAULT: float = 0.5
const MIN: float = 0.0
const MAX: float = 1.0

const HAND_WIN_BOOST: float = 0.12
const LOW_HAND_SCORE_BOOST: float = 0.06
const LOW_HAND_SCORE_MAX: int = 5
const BAD_HAND_PENALTY: float = 0.14
const BAD_HAND_SCORE_MIN: int = 15
const MOON_SUCCESS_BOOST: float = 0.22
const MATCH_LEADER_BOOST: float = 0.05


static func clamp_value(value: float) -> float:
	return clampf(value, MIN, MAX)


static func apply_hand_result(
	confidence: float,
	player_index: int,
	hand_scores: Array,
	hand_winner_index: int,
	match_scores: Array
) -> float:
	var next := confidence

	if player_index == hand_winner_index:
		next += HAND_WIN_BOOST

	var hand_score: int = hand_scores[player_index]
	if hand_score <= LOW_HAND_SCORE_MAX:
		next += LOW_HAND_SCORE_BOOST
	if hand_score >= BAD_HAND_SCORE_MIN:
		next -= BAD_HAND_PENALTY

	if did_shoot_the_moon(player_index, hand_scores):
		next += MOON_SUCCESS_BOOST

	if _is_match_leader(player_index, match_scores):
		next += MATCH_LEADER_BOOST

	return clamp_value(next)


static func did_shoot_the_moon(player_index: int, hand_scores: Array) -> bool:
	if hand_scores[player_index] != 0:
		return false
	for other_index in range(hand_scores.size()):
		if other_index == player_index:
			continue
		if hand_scores[other_index] >= HeartsRules.TOTAL_POINTS_PER_HAND:
			return true
	return false


static func _is_match_leader(player_index: int, match_scores: Array) -> bool:
	if match_scores.is_empty():
		return false
	var leader_index := 0
	for index in range(1, match_scores.size()):
		if match_scores[index] < match_scores[leader_index]:
			leader_index = index
	return player_index == leader_index
