class_name StatsStore
extends RefCounted
## Logique pure des statistiques joueur (parties terminées, victoires).
## Persistée par `StatsService` sous la clé `"stats"` de `savegame.json`.

const HUMAN_PLAYER_ID: int = 0

const KEY_MATCHES_PLAYED: String = "matches_played"
const KEY_MATCHES_WON: String = "matches_won"
const KEY_MATCHES_LOST: String = "matches_lost"


static func default_stats() -> Dictionary:
	return {
		KEY_MATCHES_PLAYED: 0,
		KEY_MATCHES_WON: 0,
		KEY_MATCHES_LOST: 0,
	}


static func normalize(raw: Variant) -> Dictionary:
	if raw is not Dictionary:
		return default_stats()
	return {
		KEY_MATCHES_PLAYED: maxi(int(raw.get(KEY_MATCHES_PLAYED, 0)), 0),
		KEY_MATCHES_WON: maxi(int(raw.get(KEY_MATCHES_WON, 0)), 0),
		KEY_MATCHES_LOST: maxi(int(raw.get(KEY_MATCHES_LOST, 0)), 0),
	}


static func record_match_end(stats: Dictionary, winner_id: int, human_id: int = HUMAN_PLAYER_ID) -> Dictionary:
	var next := normalize(stats)
	next[KEY_MATCHES_PLAYED] = next[KEY_MATCHES_PLAYED] + 1
	if winner_id == human_id:
		next[KEY_MATCHES_WON] = next[KEY_MATCHES_WON] + 1
	else:
		next[KEY_MATCHES_LOST] = next[KEY_MATCHES_LOST] + 1
	return next


static func win_rate_percent(stats: Dictionary) -> int:
	var normalized := normalize(stats)
	var played: int = normalized[KEY_MATCHES_PLAYED]
	if played == 0:
		return 0
	return int(round(float(normalized[KEY_MATCHES_WON]) / float(played) * 100.0))
