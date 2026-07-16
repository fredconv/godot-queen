class_name AdaptiveAiStrategy
extends AiStrategy
## Agent à objectifs hiérarchiques : casser la Lune adverse, la chasser, ou
## minimiser les points selon le contexte du pli.


const PASSIVE_MATCH_SCORE_THRESHOLD_LOW: int = 55
const PASSIVE_MATCH_SCORE_THRESHOLD_HIGH: int = 78
const PASSIVE_HAND_SCORE_THRESHOLD_LOW: int = 14
const PASSIVE_HAND_SCORE_THRESHOLD_HIGH: int = 22
const PASSIVE_LATE_HAND_TRICK: int = 7
const PASSIVE_LATE_HAND_SCORE_LOW: int = 8
const PASSIVE_LATE_HAND_SCORE_HIGH: int = 14
const BOLD_MOON_CONFIDENCE: float = 0.88
const MOON_HUNTER_MIN_CONFIDENCE: float = 0.48
const MOON_HUNTER_RECOVERY_CONFIDENCE: float = 0.64
const RECOVERY_MOON_CONFIDENCE: float = 0.68
const HAND_PENALTY_MOON_CONFIDENCE_BONUS: float = 0.15
const PASSIVE_EXCELLENT_MOON_CONTROL: int = 52
const PASSIVE_EXCELLENT_MOON_CONFIDENCE: float = 0.72
const PASSIVE_MOON_MAX_OPENING_TRICK: int = 3
const MOON_HUNTER_ABANDON_SCORE_LOW: int = 8
const MOON_HUNTER_ABANDON_SCORE_HIGH: int = 18
const BALANCED_MOON_ABANDON_SCORE_LOW: int = 6
const BALANCED_MOON_ABANDON_SCORE_HIGH: int = 12
const PASSIVE_MOON_ABANDON_SCORE: int = 4
const MOON_ABANDON_LATE_TRICK: int = 4
const ANNOUNCE_MIN_TRICK_INTERVAL: int = 5
const MAX_ANNOUNCEMENTS_PER_HAND: int = 1

var _personality: AiPersonalityKind.Kind
var _personality_strategy: AiStrategy
var _fallback_strategy: HeuristicStrategy = HeuristicStrategy.new()
var _moon_gamble_strategy: MoonShooterStrategy = MoonShooterStrategy.new()
var _moon_breaker_strategy: MoonBreakerStrategy = MoonBreakerStrategy.new()
var _active_strategy: AiStrategy
var _active_label: String = "balanced"
var _last_play_mode: AiPlayMode.Kind = AiPlayMode.Kind.MINIMIZE
var _last_hand_number: int = -1
var _announcements_this_hand: int = 0
var _last_announcement_trick: int = -99
var _was_chasing_moon: bool = false
var _pending_announcement: Dictionary = {}


func _init(personality: AiPersonalityKind.Kind, personality_strategy: AiStrategy) -> void:
	_personality = personality
	_personality_strategy = personality_strategy
	_active_strategy = personality_strategy
	_active_label = _personality_label(personality)


func consume_pending_announcement() -> Dictionary:
	var announcement := _pending_announcement
	_pending_announcement = {}
	return announcement


func get_play_mode_info() -> Dictionary:
	return {
		"mode": _last_play_mode,
		"thinking_sec": 0.0,
	}


func peek_play_mode(context: Dictionary) -> AiPlayMode.Kind:
	_sync_hand(context)
	return _select_play_mode(context)


func choose_card(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	_sync_hand(context)
	_last_play_mode = _select_play_mode(context)

	if _last_play_mode == AiPlayMode.Kind.BREAK_MOON:
		_maybe_announce_suspect(context)
		return _moon_breaker_strategy.choose_card(
			legal_plays,
			_enrich_break_context(context),
			rng
		)

	if _last_play_mode == AiPlayMode.Kind.CHASE_MOON:
		if not _was_chasing_moon:
			_maybe_announce_more_aggressive(context)
		_was_chasing_moon = true
		_apply_chase_strategy(context)
		return _active_strategy.choose_card(
			legal_plays,
			_enrich_chase_context(context),
			rng
		)

	return _play_personality_card(legal_plays, context, rng)


func _play_personality_card(
	legal_plays: Array[CardModel],
	context: Dictionary,
	rng: RandomNumberGenerator
) -> CardModel:
	if _was_chasing_moon:
		_handle_moon_abandon(context)
		_was_chasing_moon = false
	_update_personality_strategy(context)
	return _active_strategy.choose_card(legal_plays, context, rng)


func _sync_hand(context: Dictionary) -> void:
	var hand_number: int = context.get("hand_number", 0)
	if hand_number == _last_hand_number:
		return
	_last_hand_number = hand_number
	_announcements_this_hand = 0
	_last_announcement_trick = -99
	_was_chasing_moon = false
	_set_active_strategy(_personality_strategy, _personality_label(_personality))


func _select_play_mode(context: Dictionary) -> AiPlayMode.Kind:
	if context.get("moon_busted", false):
		return AiPlayMode.Kind.MINIMIZE
	if _was_chasing_moon:
		if _should_abandon_moon_chase(context):
			return AiPlayMode.Kind.MINIMIZE
		return AiPlayMode.Kind.CHASE_MOON
	if _should_break_opponent_moon(context):
		return AiPlayMode.Kind.BREAK_MOON
	if _wants_chase_moon(context):
		return AiPlayMode.Kind.CHASE_MOON
	return AiPlayMode.Kind.MINIMIZE


func _should_break_opponent_moon(context: Dictionary) -> bool:
	if context.get("moon_busted", false):
		return false
	var player_index: int = context.get("player_index", -1)
	var human_suspect: int = context.get("human_declared_moon_suspect", -1)
	if human_suspect >= 0:
		if player_index == human_suspect:
			return false
		return context.get("trick_number", 1) >= MoonSuspicion.MIN_TRICK_TO_BREAK
	if not MoonSuspicion.should_break_moon(context):
		return false
	var suspect: Dictionary = MoonSuspicion.find_top_suspect(context)
	return suspect.get("player_index", -1) != player_index


func _wants_chase_moon(context: Dictionary) -> bool:
	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	var has_hand_penalties := _player_has_hand_penalties(context)
	match _personality:
		AiPersonalityKind.Kind.MOON_HUNTER:
			if not _moon_viable_for_self(context, true):
				return false
			if has_hand_penalties:
				return confidence >= MOON_HUNTER_RECOVERY_CONFIDENCE
			return confidence >= MOON_HUNTER_MIN_CONFIDENCE
		_:
			if not context.get("moon_feasible", false):
				if _personality != AiPersonalityKind.Kind.PASSIVE:
					return false
				if not _passive_has_excellent_moon_hand(context, true):
					return false
			match _personality:
				AiPersonalityKind.Kind.BALANCED:
					var threshold := BOLD_MOON_CONFIDENCE
					if has_hand_penalties:
						threshold += HAND_PENALTY_MOON_CONFIDENCE_BONUS
					return confidence >= threshold
				AiPersonalityKind.Kind.PASSIVE:
					return _passive_has_excellent_moon_hand(context)
				_:
					return false


func _passive_has_excellent_moon_hand(
	context: Dictionary,
	skip_global_feasibility: bool = false
) -> bool:
	if _player_has_hand_penalties(context):
		return false

	var trick_number: int = context.get("trick_number", 1)
	if trick_number > PASSIVE_MOON_MAX_OPENING_TRICK:
		return false

	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	if confidence < PASSIVE_EXCELLENT_MOON_CONFIDENCE:
		return false

	var hand_cards: Array = context.get("hand_cards", [])
	if hand_cards.is_empty():
		return false
	var typed_hand := _typed_hand_cards(hand_cards)
	if MoonFeasibility.compute_control_score(typed_hand) < PASSIVE_EXCELLENT_MOON_CONTROL:
		return false

	if skip_global_feasibility:
		return true

	var player_index: int = context.get("player_index", -1)
	var tricks_taken: Array = context.get("tricks_taken", [])
	return MoonFeasibility.is_viable_for_player(
		player_index,
		typed_hand,
		tricks_taken,
		confidence,
		trick_number
	)


func _should_abandon_moon_chase(context: Dictionary) -> bool:
	var player_index: int = context.get("player_index", -1)
	if player_index < 0:
		return false

	var tricks_taken: Array = context.get("tricks_taken", [])
	if MoonFeasibility.is_moon_busted_globally(tricks_taken):
		return true
	if MoonFeasibility.another_player_has_penalty_points(tricks_taken, player_index):
		return true
	if MoonFeasibility.opponent_captured_queen_of_spades(tricks_taken, player_index):
		return true

	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	var for_hunter := _personality == AiPersonalityKind.Kind.MOON_HUNTER
	var sole_collector := MoonFeasibility.sole_penalty_collector_index(tricks_taken) == player_index
	if not _moon_viable_for_self(context, for_hunter) and not sole_collector:
		var trick_number: int = context.get("trick_number", 1)
		if trick_number >= MOON_ABANDON_LATE_TRICK or _player_has_hand_penalties(context):
			return true

	var hand_scores: Array = context.get("hand_raw_scores", [])
	if hand_scores.size() <= player_index:
		return false

	var our_score: int = hand_scores[player_index]
	match _personality:
		AiPersonalityKind.Kind.MOON_HUNTER:
			var quit_threshold := int(lerpf(
				float(MOON_HUNTER_ABANDON_SCORE_LOW),
				float(MOON_HUNTER_ABANDON_SCORE_HIGH),
				confidence
			))
			return our_score >= quit_threshold
		AiPersonalityKind.Kind.PASSIVE:
			return our_score >= PASSIVE_MOON_ABANDON_SCORE
		_:
			var quit_threshold := int(lerpf(
				float(BALANCED_MOON_ABANDON_SCORE_LOW),
				float(BALANCED_MOON_ABANDON_SCORE_HIGH),
				confidence
			))
			return our_score >= quit_threshold


func _handle_moon_abandon(context: Dictionary) -> void:
	if _personality == AiPersonalityKind.Kind.PASSIVE:
		_maybe_announce_more_aggressive(context)
	_update_personality_strategy(context)


func _player_has_hand_penalties(context: Dictionary) -> bool:
	var player_index: int = context.get("player_index", -1)
	var hand_scores: Array = context.get("hand_raw_scores", [])
	if player_index < 0 or hand_scores.size() <= player_index:
		return false
	return hand_scores[player_index] > 0


func _update_personality_strategy(context: Dictionary) -> void:
	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	match _personality:
		AiPersonalityKind.Kind.MOON_HUNTER:
			_set_active_strategy(_fallback_strategy, "balanced")
		AiPersonalityKind.Kind.PASSIVE:
			if _should_passive_give_up(context, confidence):
				_maybe_announce_more_aggressive(context)
				_set_active_strategy(_fallback_strategy, "balanced")
			else:
				_set_active_strategy(_personality_strategy, "passive")
		_:
			_set_active_strategy(_personality_strategy, "balanced")


func _apply_chase_strategy(_context: Dictionary) -> void:
	if _personality == AiPersonalityKind.Kind.BALANCED \
			or _personality == AiPersonalityKind.Kind.PASSIVE:
		_set_active_strategy(_moon_gamble_strategy, "moon_hunter")
		return
	_set_active_strategy(_personality_strategy, "moon_hunter")


func _enrich_chase_context(context: Dictionary) -> Dictionary:
	var enriched := context.duplicate()
	enriched["moon_feasible"] = true
	return enriched


func _maybe_announce_more_aggressive(context: Dictionary) -> void:
	_queue_announcement_if_allowed(context, "more_aggressive")


func _maybe_announce_suspect(context: Dictionary) -> void:
	var suspect: Dictionary = MoonSuspicion.find_top_suspect(context)
	var suspect_index: int = suspect.get("player_index", -1)
	if suspect_index < 0:
		return
	_queue_announcement_if_allowed(context, "suspect_moon", suspect_index)


func _queue_announcement_if_allowed(
	context: Dictionary,
	reason_key: String,
	target_player_index: int = -1
) -> void:
	if _announcements_this_hand >= MAX_ANNOUNCEMENTS_PER_HAND:
		return
	var trick_number: int = context.get("trick_number", 1)
	if _last_announcement_trick >= 0 \
			and trick_number - _last_announcement_trick < ANNOUNCE_MIN_TRICK_INTERVAL:
		return

	_announcements_this_hand += 1
	_last_announcement_trick = trick_number
	_pending_announcement = {
		"from_label": _active_label,
		"to_label": "balanced",
		"reason_key": reason_key,
		"player_index": context.get("player_index", -1),
		"target_player_index": target_player_index,
	}


func _enrich_break_context(context: Dictionary) -> Dictionary:
	var enriched := context.duplicate()
	var human_suspect: int = context.get("human_declared_moon_suspect", -1)
	if human_suspect >= 0:
		enriched["moon_suspect_index"] = human_suspect
		enriched["moon_suspect_score"] = 100.0
	else:
		var suspect: Dictionary = MoonSuspicion.find_top_suspect(context)
		enriched["moon_suspect_index"] = suspect.get("player_index", -1)
		enriched["moon_suspect_score"] = suspect.get("score", 0.0)
	return enriched


func _should_passive_give_up(context: Dictionary, confidence: float) -> bool:
	var player_index: int = context.get("player_index", -1)
	if player_index < 0:
		return false

	var match_scores: Array = context.get("match_scores", [])
	var hand_scores: Array = context.get("hand_raw_scores", [])
	if match_scores.size() <= player_index or hand_scores.size() <= player_index:
		return false

	var match_threshold := int(lerpf(
		float(PASSIVE_MATCH_SCORE_THRESHOLD_LOW),
		float(PASSIVE_MATCH_SCORE_THRESHOLD_HIGH),
		confidence
	))
	var hand_threshold := int(lerpf(
		float(PASSIVE_HAND_SCORE_THRESHOLD_LOW),
		float(PASSIVE_HAND_SCORE_THRESHOLD_HIGH),
		confidence
	))
	var late_hand_threshold := int(lerpf(
		float(PASSIVE_LATE_HAND_SCORE_LOW),
		float(PASSIVE_LATE_HAND_SCORE_HIGH),
		confidence
	))

	var display_score: int = match_scores[player_index] + hand_scores[player_index]
	if display_score >= match_threshold:
		return true
	if hand_scores[player_index] >= hand_threshold:
		return true

	var trick_number: int = context.get("trick_number", 1)
	if trick_number >= PASSIVE_LATE_HAND_TRICK \
			and hand_scores[player_index] >= late_hand_threshold:
		return true

	return false


func _set_active_strategy(strategy: AiStrategy, label: String) -> void:
	_active_strategy = strategy
	_active_label = label


static func _personality_label(personality: AiPersonalityKind.Kind) -> String:
	match personality:
		AiPersonalityKind.Kind.MOON_HUNTER:
			return "moon_hunter"
		AiPersonalityKind.Kind.PASSIVE:
			return "passive"
		_:
			return "balanced"


func _moon_viable_for_self(context: Dictionary, for_moon_hunter: bool = false) -> bool:
	var player_index: int = context.get("player_index", -1)
	var hand_cards: Array = context.get("hand_cards", [])
	var tricks_taken: Array = context.get("tricks_taken", [])
	var confidence: float = context.get("confidence", AiConfidence.DEFAULT)
	var trick_number: int = context.get("trick_number", 1)
	return MoonFeasibility.is_viable_for_player(
		player_index,
		_typed_hand_cards(hand_cards),
		tricks_taken,
		confidence,
		trick_number,
		for_moon_hunter
	)


static func _typed_hand_cards(hand_cards: Array) -> Array[CardModel]:
	var typed: Array[CardModel] = []
	for card_variant: Variant in hand_cards:
		if card_variant is CardModel:
			typed.append(card_variant)
	return typed
