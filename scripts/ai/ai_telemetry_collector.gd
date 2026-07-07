class_name AiTelemetryCollector
extends RefCounted
## Collecte les décisions IA (modes, Lune, suspicion) pour analyse batch.
## Utilisé par la simulation ; optionnel sur `MatchManager.telemetry`.


const PROB_HIGH_THRESHOLD: float = 0.10
const PROB_LOW_THRESHOLD: float = 0.04
const REGRET_BUCKETS: Array[String] = ["0.0-0.04", "0.04-0.10", "0.10-0.14"]

var enabled: bool = true

var _batch: Dictionary = {}
var _match: Dictionary = {}
var _hand: Dictionary = {}
var _last_modes: Array[int] = [0, 0, 0, 0]


func _init() -> void:
	reset_batch()


func reset_batch() -> void:
	_batch = {
		"matches_played": 0,
		"hands_played": 0,
		"seats": _new_seat_array(),
	}


func begin_match() -> void:
	_match = {
		"hands": 0,
		"failed_moon_attempts": [],
	}


func begin_hand(hand_number: int) -> void:
	_hand = {
		"hand_number": hand_number,
		"attempts": {},  # seat -> attempt dict
		"tricks_won": [0, 0, 0, 0],
		"max_streak": [0, 0, 0, 0],
		"current_streak": [0, 0, 0, 0],
		"had_attempt": [false, false, false, false],
		"attempter_raw_scores": {},
	}


func record_decision(
	player_index: int,
	context: Dictionary,
	play_mode: AiPlayMode.Kind,
	announcement: Dictionary = {}
) -> void:
	if not enabled or player_index < 0:
		return

	var trick_number: int = context.get("trick_number", 1)
	var hand_cards: Array = context.get("hand_cards", [])
	var tricks_taken: Array = context.get("tricks_taken", [])
	if tricks_taken.is_empty():
		tricks_taken = _empty_tricks_taken()

	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	var probability := MoonFeasibility.estimate_success_probability(
		player_index,
		hand_cards,
		tricks_taken,
		confidence,
		trick_number
	)
	_last_modes[player_index] = play_mode

	var seat_stats: Dictionary = _batch["seats"][player_index]
	if play_mode == AiPlayMode.Kind.CHASE_MOON:
		_start_moon_attempt(player_index, trick_number, probability, seat_stats)
	elif play_mode == AiPlayMode.Kind.BREAK_MOON:
		_record_break_decision(player_index, trick_number, context, seat_stats)

	if not announcement.is_empty():
		if announcement.get("reason_key", "") == "suspect_moon":
			seat_stats["detections_made"] = int(seat_stats["detections_made"]) + 1


func record_trick_resolved(
	trick_number: int,
	winner_index: int,
	trick_points: int,
	trick_cards: Array
) -> void:
	if not enabled:
		return

	_hand["tricks_won"][winner_index] = int(_hand["tricks_won"][winner_index]) + 1
	_hand["current_streak"][winner_index] = int(_hand["current_streak"][winner_index]) + 1
	_hand["max_streak"][winner_index] = maxi(
		int(_hand["max_streak"][winner_index]),
		int(_hand["current_streak"][winner_index])
	)
	for seat in range(HeartsRules.PLAYER_COUNT):
		if seat != winner_index:
			_hand["current_streak"][seat] = 0

	if trick_points <= 0:
		return

	_process_moon_break_signals(trick_number, winner_index, trick_cards)


func end_hand(
	tricks_taken: Array,
	final_hand_scores: Dictionary,
	display_scores_before_hand: Array
) -> void:
	if not enabled:
		return

	_batch["hands_played"] = int(_batch["hands_played"]) + 1
	_match["hands"] = int(_match["hands"]) + 1

	var raw_scores := RuleEngine.compute_raw_hand_scores(tricks_taken)
	var moon_shooter := RuleEngine.find_moon_shooter(raw_scores)

	for seat in range(HeartsRules.PLAYER_COUNT):
		var seat_stats: Dictionary = _batch["seats"][seat]
		var raw_score: int = int(raw_scores.get(seat, 0))
		seat_stats["hand_score_sum"] = int(seat_stats["hand_score_sum"]) + raw_score
		seat_stats["tricks_won_total"] = int(seat_stats["tricks_won_total"]) + int(_hand["tricks_won"][seat])
		seat_stats["max_consecutive_trick_streak"] = maxi(
			int(seat_stats["max_consecutive_trick_streak"]),
			int(_hand["max_streak"][seat])
		)
		_record_queen_hand_stats(seat, tricks_taken[seat], seat_stats)

		var had_attempt: bool = _hand["had_attempt"][seat]
		if had_attempt:
			seat_stats["hands_with_attempt_score_sum"] = int(seat_stats["hands_with_attempt_score_sum"]) + raw_score
			seat_stats["hands_with_attempt_count"] = int(seat_stats["hands_with_attempt_count"]) + 1
		else:
			seat_stats["hands_without_attempt_score_sum"] = int(seat_stats["hands_without_attempt_score_sum"]) + raw_score
			seat_stats["hands_without_attempt_count"] = int(seat_stats["hands_without_attempt_count"]) + 1

		if not _hand["attempts"].has(seat):
			continue

		var attempt: Dictionary = _hand["attempts"][seat]
		_finalize_moon_attempt(seat, attempt, moon_shooter == seat, raw_score, seat_stats)


func end_match(winner_index: int, final_scores: Array, hand_count: int) -> void:
	if not enabled:
		return

	_batch["matches_played"] = int(_batch["matches_played"]) + 1
	var ranks := _compute_ranks(final_scores)

	for seat in range(HeartsRules.PLAYER_COUNT):
		var seat_stats: Dictionary = _batch["seats"][seat]
		seat_stats["matches"] = int(seat_stats["matches"]) + 1
		seat_stats["total_final_score"] = int(seat_stats["total_final_score"]) + int(final_scores[seat])
		seat_stats["total_hands"] = int(seat_stats["total_hands"]) + hand_count

		var rank: int = int(ranks[seat])
		match rank:
			1:
				seat_stats["wins"] = int(seat_stats["wins"]) + 1
				seat_stats["hands_before_win_sum"] = int(seat_stats["hands_before_win_sum"]) + hand_count
				seat_stats["hands_before_win_count"] = int(seat_stats["hands_before_win_count"]) + 1
			2:
				seat_stats["second"] = int(seat_stats["second"]) + 1
			3:
				seat_stats["third"] = int(seat_stats["third"]) + 1
			4:
				seat_stats["fourth"] = int(seat_stats["fourth"]) + 1

	for attempt_variant: Variant in _match.get("failed_moon_attempts", []):
		if not attempt_variant is Dictionary:
			continue
		var attempt: Dictionary = attempt_variant
		var seat: int = int(attempt.get("seat", -1))
		if seat < 0 or seat >= HeartsRules.PLAYER_COUNT:
			continue
		var seat_stats: Dictionary = _batch["seats"][seat]
		var rank: int = int(ranks[seat])
		seat_stats["moon_failed_ranks"][rank - 1] = int(seat_stats["moon_failed_ranks"][rank - 1]) + 1
		seat_stats["moon_failed_raw_score_sum"] = int(seat_stats["moon_failed_raw_score_sum"]) + int(attempt.get("raw_score", 0))
		seat_stats["moon_failed_count"] = int(seat_stats["moon_failed_count"]) + 1


func summarize() -> Dictionary:
	var seats_summary: Array[Dictionary] = []
	for seat in range(HeartsRules.PLAYER_COUNT):
		var seat_stats: Dictionary = _batch["seats"][seat]
		var summary := _summarize_seat(seat_stats)
		summary["seat"] = seat
		seats_summary.append(summary)

	return {
		"matches_played": _batch["matches_played"],
		"hands_played": _batch["hands_played"],
		"seats": seats_summary,
		"regret_analysis": _summarize_regret(_batch["seats"]),
		"priority_table": _build_priority_table(seats_summary),
	}


static func _new_seat_array() -> Array:
	var seats: Array = []
	for _i in range(HeartsRules.PLAYER_COUNT):
		seats.append(_empty_seat_stats())
	return seats


static func _empty_seat_stats() -> Dictionary:
	var regret: Dictionary = {}
	for bucket in REGRET_BUCKETS:
		regret[bucket] = {"attempts": 0, "successes": 0}

	return {
		"matches": 0,
		"wins": 0,
		"second": 0,
		"third": 0,
		"fourth": 0,
		"total_final_score": 0,
		"total_hands": 0,
		"hands_before_win_sum": 0,
		"hands_before_win_count": 0,
		"moon_attempts": 0,
		"moon_successes": 0,
		"moon_detected": 0,
		"moon_undetected": 0,
		"detection_tricks_sum": 0,
		"detection_tricks_count": 0,
		"moons_broken": 0,
		"moons_stopped_after_detection": 0,
		"broken_first_heart": 0,
		"broken_queen": 0,
		"broken_lost_trick": 0,
		"break_actions": 0,
		"break_success": 0,
		"break_fail": 0,
		"sacrifice_points": 0,
		"sacrifice_events": 0,
		"moon_attempt_high_prob": 0,
		"moon_attempt_low_prob": 0,
		"moon_failed_ranks": [0, 0, 0, 0],
		"moon_failed_raw_score_sum": 0,
		"moon_failed_count": 0,
		"hand_score_sum": 0,
		"hands_with_attempt_score_sum": 0,
		"hands_with_attempt_count": 0,
		"hands_without_attempt_score_sum": 0,
		"hands_without_attempt_count": 0,
		"moon_success_hand_score_sum": 0,
		"regret_buckets": regret,
		"tricks_won_total": 0,
		"max_consecutive_trick_streak": 0,
		"queen_taken": 0,
		"queen_dumped": 0,
		"queen_held_to_end": 0,
		"queen_broke_moon": 0,
		"detections_made": 0,
	}


func _start_moon_attempt(
	seat: int,
	trick_number: int,
	probability: float,
	seat_stats: Dictionary
) -> void:
	if _hand["attempts"].has(seat):
		return

	_hand["attempts"][seat] = {
		"start_trick": trick_number,
		"estimated_probability": probability,
		"detected": false,
		"detection_trick": -1,
		"broken": false,
		"broken_reason": "",
	}
	_hand["had_attempt"][seat] = true
	seat_stats["moon_attempts"] = int(seat_stats["moon_attempts"]) + 1

	if probability >= PROB_HIGH_THRESHOLD:
		seat_stats["moon_attempt_high_prob"] = int(seat_stats["moon_attempt_high_prob"]) + 1
	elif probability < PROB_LOW_THRESHOLD:
		seat_stats["moon_attempt_low_prob"] = int(seat_stats["moon_attempt_low_prob"]) + 1

	var bucket := _probability_bucket(probability)
	seat_stats["regret_buckets"][bucket]["attempts"] = int(seat_stats["regret_buckets"][bucket]["attempts"]) + 1


func _record_break_decision(
	seat: int,
	trick_number: int,
	context: Dictionary,
	seat_stats: Dictionary
) -> void:
	seat_stats["break_actions"] = int(seat_stats["break_actions"]) + 1
	var suspect_index: int = int(MoonSuspicion.find_top_suspect(context).get("player_index", -1))
	if suspect_index < 0:
		return

	if not _hand["attempts"].has(suspect_index):
		return

	var attempt: Dictionary = _hand["attempts"][suspect_index]
	if attempt.get("detected", false):
		return

	attempt["detected"] = true
	attempt["detection_trick"] = trick_number
	var suspect_stats: Dictionary = _batch["seats"][suspect_index]
	suspect_stats["moon_detected"] = int(suspect_stats["moon_detected"]) + 1
	suspect_stats["detection_tricks_sum"] = int(suspect_stats["detection_tricks_sum"]) + trick_number
	suspect_stats["detection_tricks_count"] = int(suspect_stats["detection_tricks_count"]) + 1


func _process_moon_break_signals(
	trick_number: int,
	winner_index: int,
	trick_cards: Array
) -> void:
	for seat_variant: Variant in _hand["attempts"].keys():
		var seat: int = int(seat_variant)
		var attempt: Dictionary = _hand["attempts"][seat]
		if attempt.get("broken", false):
			continue

		if winner_index == seat:
			continue

		var reason := ""
		for card_variant: Variant in trick_cards:
			if not card_variant is CardModel:
				continue
			var card: CardModel = card_variant
			if card.is_heart():
				reason = "first_heart"
				break
			if card.is_queen_of_spades():
				reason = "queen"

		if reason.is_empty():
			reason = "lost_trick"

		_mark_moon_broken(seat, attempt, reason)

		var breaker_stats: Dictionary = _batch["seats"][winner_index]
		if _last_modes[winner_index] == AiPlayMode.Kind.BREAK_MOON:
			var points := 0
			for card_variant: Variant in trick_cards:
				if card_variant is CardModel:
					points += HeartsRules.card_points(card_variant)
			if points > 0:
				breaker_stats["sacrifice_points"] = int(breaker_stats["sacrifice_points"]) + points
				breaker_stats["sacrifice_events"] = int(breaker_stats["sacrifice_events"]) + 1
				breaker_stats["break_success"] = int(breaker_stats["break_success"]) + 1
				if reason == "queen":
					breaker_stats["queen_broke_moon"] = int(breaker_stats["queen_broke_moon"]) + 1


func _mark_moon_broken(seat: int, attempt: Dictionary, reason: String) -> void:
	if attempt.get("broken", false):
		return
	attempt["broken"] = true
	attempt["broken_reason"] = reason
	var seat_stats: Dictionary = _batch["seats"][seat]
	seat_stats["moons_broken"] = int(seat_stats["moons_broken"]) + 1
	match reason:
		"first_heart":
			seat_stats["broken_first_heart"] = int(seat_stats["broken_first_heart"]) + 1
		"queen":
			seat_stats["broken_queen"] = int(seat_stats["broken_queen"]) + 1
		_:
			seat_stats["broken_lost_trick"] = int(seat_stats["broken_lost_trick"]) + 1


func _finalize_moon_attempt(
	seat: int,
	attempt: Dictionary,
	succeeded: bool,
	raw_score: int,
	seat_stats: Dictionary
) -> void:
	if succeeded:
		seat_stats["moon_successes"] = int(seat_stats["moon_successes"]) + 1
		seat_stats["moon_success_hand_score_sum"] = int(seat_stats["moon_success_hand_score_sum"]) + raw_score
		var bucket: String = _probability_bucket(float(attempt.get("estimated_probability", 0.0)))
		seat_stats["regret_buckets"][bucket]["successes"] = int(seat_stats["regret_buckets"][bucket]["successes"]) + 1
	else:
		_match["failed_moon_attempts"].append({
			"seat": seat,
			"raw_score": raw_score,
			"start_trick": int(attempt.get("start_trick", -1)),
			"estimated_probability": float(attempt.get("estimated_probability", 0.0)),
		})

	if attempt.get("detected", false) and not succeeded:
		seat_stats["moons_stopped_after_detection"] = int(seat_stats["moons_stopped_after_detection"]) + 1

	if not attempt.get("detected", false):
		seat_stats["moon_undetected"] = int(seat_stats["moon_undetected"]) + 1


func _record_queen_hand_stats(seat: int, captured: Array, seat_stats: Dictionary) -> void:
	var took_queen := false
	var dumped_queen := false
	for card_variant: Variant in captured:
		if card_variant is CardModel and card_variant.is_queen_of_spades():
			took_queen = true
			break
	if took_queen:
		seat_stats["queen_taken"] = int(seat_stats["queen_taken"]) + 1
		if _hand["had_attempt"][seat]:
			seat_stats["queen_held_to_end"] = int(seat_stats["queen_held_to_end"]) + 1


static func _summarize_seat(stats: Dictionary) -> Dictionary:
	var matches: int = int(stats["matches"])
	var attempts: int = int(stats["moon_attempts"])
	var successes: int = int(stats["moon_successes"])
	var detected: int = int(stats["moon_detected"])
	var broken: int = int(stats["moons_broken"])
	var break_actions: int = int(stats["break_actions"])
	var break_success: int = int(stats["break_success"])
	var hands: int = int(stats["total_hands"])
	var hand_count_attempt: int = int(stats["hands_with_attempt_count"])
	var hand_count_normal: int = int(stats["hands_without_attempt_count"])

	return {
		"seat": stats.get("seat", -1),
		"matches": matches,
		"wins": int(stats["wins"]),
		"second": int(stats["second"]),
		"third": int(stats["third"]),
		"fourth": int(stats["fourth"]),
		"win_rate": float(stats["wins"]) / float(matches) if matches > 0 else 0.0,
		"avg_final_score": float(stats["total_final_score"]) / float(matches) if matches > 0 else 0.0,
		"avg_hands_before_win": (
			float(stats["hands_before_win_sum"]) / float(stats["hands_before_win_count"])
			if int(stats["hands_before_win_count"]) > 0 else 0.0
		),
		"avg_hand_score": float(stats["hand_score_sum"]) / float(hands) if hands > 0 else 0.0,
		"moon_attempts": attempts,
		"moon_successes": successes,
		"moon_success_rate": float(successes) / float(attempts) if attempts > 0 else 0.0,
		"moon_detected": detected,
		"moon_undetected": int(stats["moon_undetected"]),
		"moon_detection_rate": float(detected) / float(attempts) if attempts > 0 else 0.0,
		"avg_detection_trick": (
			float(stats["detection_tricks_sum"]) / float(stats["detection_tricks_count"])
			if int(stats["detection_tricks_count"]) > 0 else 0.0
		),
		"moons_broken": broken,
		"moons_stopped_after_detection": int(stats["moons_stopped_after_detection"]),
		"broken_first_heart": int(stats["broken_first_heart"]),
		"broken_queen": int(stats["broken_queen"]),
		"broken_lost_trick": int(stats["broken_lost_trick"]),
		"moon_break_rate_on_detected": (
			float(stats["moons_stopped_after_detection"]) / float(detected)
			if detected > 0 else 0.0
		),
		"break_actions": break_actions,
		"break_success_rate": float(break_success) / float(break_actions) if break_actions > 0 else 0.0,
		"sacrifice_points": int(stats["sacrifice_points"]),
		"sacrifice_events": int(stats["sacrifice_events"]),
		"moon_attempt_high_prob": int(stats["moon_attempt_high_prob"]),
		"moon_attempt_low_prob": int(stats["moon_attempt_low_prob"]),
		"avg_score_after_failed_moon": (
			float(stats["moon_failed_raw_score_sum"]) / float(stats["moon_failed_count"])
			if int(stats["moon_failed_count"]) > 0 else 0.0
		),
		"failed_moon_rank_distribution": stats["moon_failed_ranks"].duplicate(),
		"avg_hand_score_with_attempt": (
			float(stats["hands_with_attempt_score_sum"]) / float(hand_count_attempt)
			if hand_count_attempt > 0 else 0.0
		),
		"avg_hand_score_without_attempt": (
			float(stats["hands_without_attempt_score_sum"]) / float(hand_count_normal)
			if hand_count_normal > 0 else 0.0
		),
		"avg_tricks_won_per_hand": float(stats["tricks_won_total"]) / float(hands) if hands > 0 else 0.0,
		"max_consecutive_trick_streak": int(stats["max_consecutive_trick_streak"]),
		"queen_taken": int(stats["queen_taken"]),
		"queen_held_to_end": int(stats["queen_held_to_end"]),
		"queen_broke_moon": int(stats["queen_broke_moon"]),
		"detections_made": int(stats["detections_made"]),
		"regret_buckets": stats["regret_buckets"].duplicate(true),
	}


static func _summarize_regret(seats: Array) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for bucket in REGRET_BUCKETS:
		var attempts := 0
		var successes := 0
		for seat_variant: Variant in seats:
			var seat_stats: Dictionary = seat_variant
			var bucket_stats: Dictionary = seat_stats["regret_buckets"][bucket]
			attempts += int(bucket_stats["attempts"])
			successes += int(bucket_stats["successes"])
		rows.append({
			"bucket": bucket,
			"attempts": attempts,
			"successes": successes,
			"actual_success_rate": float(successes) / float(attempts) if attempts > 0 else 0.0,
		})
	return rows


static func _build_priority_table(seats_summary: Array) -> Array[Dictionary]:
	var table: Array[Dictionary] = []
	for seat_variant: Variant in seats_summary:
		if not seat_variant is Dictionary:
			continue
		var seat: Dictionary = seat_variant
		table.append({
			"seat": seat.get("seat", -1),
			"wins": seat.get("wins", 0),
			"avg_hand_score": seat.get("avg_hand_score", 0.0),
			"moon_attempts": seat.get("moon_attempts", 0),
			"moon_success_rate": seat.get("moon_success_rate", 0.0),
			"moon_detection_rate": seat.get("moon_detection_rate", 0.0),
			"moon_break_rate_on_detected": seat.get("moon_break_rate_on_detected", 0.0),
			"avg_score_after_failed_moon": seat.get("avg_score_after_failed_moon", 0.0),
			"avg_hand_score_with_attempt": seat.get("avg_hand_score_with_attempt", 0.0),
			"avg_hand_score_without_attempt": seat.get("avg_hand_score_without_attempt", 0.0),
			"sacrifice_points": seat.get("sacrifice_points", 0),
		})
	return table


static func _compute_ranks(final_scores: Array) -> Dictionary:
	var order: Array[int] = []
	for seat in range(final_scores.size()):
		order.append(seat)
	order.sort_custom(func(a: int, b: int) -> bool:
		if int(final_scores[a]) == int(final_scores[b]):
			return a < b
		return int(final_scores[a]) < int(final_scores[b])
	)
	var ranks := {}
	for rank_index in range(order.size()):
		ranks[order[rank_index]] = rank_index + 1
	return ranks


static func _probability_bucket(probability: float) -> String:
	if probability < PROB_LOW_THRESHOLD:
		return REGRET_BUCKETS[0]
	if probability < PROB_HIGH_THRESHOLD:
		return REGRET_BUCKETS[1]
	return REGRET_BUCKETS[2]


static func _empty_tricks_taken() -> Array:
	var tricks: Array = []
	for _i in range(HeartsRules.PLAYER_COUNT):
		tricks.append([])
	return tricks
