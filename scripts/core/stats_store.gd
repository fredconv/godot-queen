class_name StatsStore
extends RefCounted
## Logique pure des statistiques joueur locales (solo uniquement).
## Persistées par `StatsService` sous `stats` dans `savegame.json`.

const HUMAN_PLAYER_ID: int = 0

const KEY_MATCHES_PLAYED: String = "matches_played"
const KEY_MATCHES_WON: String = "matches_won"
const KEY_MATCHES_LOST: String = "matches_lost"
const KEY_HANDS_PLAYED: String = "hands_played"
const KEY_BEST_SCORE: String = "best_score"
const KEY_SHOOT_THE_MOON_COUNT: String = "shoot_the_moon_count"


static func default_stats() -> Dictionary:
	return {
		KEY_MATCHES_PLAYED: 0,
		KEY_MATCHES_WON: 0,
		KEY_MATCHES_LOST: 0,
		KEY_HANDS_PLAYED: 0,
		KEY_BEST_SCORE: null,
		KEY_SHOOT_THE_MOON_COUNT: 0,
	}


static func normalize(raw: Variant) -> Dictionary:
	if raw is not Dictionary:
		return default_stats()
	var best_score: Variant = raw.get(KEY_BEST_SCORE, null)
	if best_score != null:
		best_score = int(best_score)
	return {
		KEY_MATCHES_PLAYED: maxi(int(raw.get(KEY_MATCHES_PLAYED, 0)), 0),
		KEY_MATCHES_WON: maxi(int(raw.get(KEY_MATCHES_WON, 0)), 0),
		KEY_MATCHES_LOST: maxi(int(raw.get(KEY_MATCHES_LOST, 0)), 0),
		KEY_HANDS_PLAYED: maxi(int(raw.get(KEY_HANDS_PLAYED, 0)), 0),
		KEY_BEST_SCORE: best_score,
		KEY_SHOOT_THE_MOON_COUNT: maxi(int(raw.get(KEY_SHOOT_THE_MOON_COUNT, 0)), 0),
	}


static func record_match_end(stats: Dictionary, winner_id: int, human_id: int = HUMAN_PLAYER_ID) -> Dictionary:
	var next := normalize(stats)
	next[KEY_MATCHES_PLAYED] = next[KEY_MATCHES_PLAYED] + 1
	if winner_id == human_id:
		next[KEY_MATCHES_WON] = next[KEY_MATCHES_WON] + 1
	else:
		next[KEY_MATCHES_LOST] = next[KEY_MATCHES_LOST] + 1
	return next


static func record_hand_end(stats: Dictionary, human_hand_score: int, shot_the_moon: bool) -> Dictionary:
	var next := normalize(stats)
	next[KEY_HANDS_PLAYED] = next[KEY_HANDS_PLAYED] + 1
	if shot_the_moon:
		next[KEY_SHOOT_THE_MOON_COUNT] = next[KEY_SHOOT_THE_MOON_COUNT] + 1
	var best: Variant = next[KEY_BEST_SCORE]
	if best == null or human_hand_score < int(best):
		next[KEY_BEST_SCORE] = human_hand_score
	return next


static func win_rate_percent(stats: Dictionary) -> int:
	var normalized := normalize(stats)
	var played: int = normalized[KEY_MATCHES_PLAYED]
	if played == 0:
		return 0
	return int(round(float(normalized[KEY_MATCHES_WON]) / float(played) * 100.0))
