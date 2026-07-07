class_name AiPersonalityCatalog
extends RefCounted
## Personnalités des adversaires IA. Un seul flag pour tout remettre en équilibré.


## false → les 3 adversaires (et la simu) utilisent HeuristicStrategy uniquement.
const USE_MIXED_PERSONALITIES: bool = true

## Sièges adverses en table (1 = gauche, 2 = haut, 3 = droite).
const MIXED_OPPONENT_PERSONALITIES: Array[AiPersonalityKind.Kind] = [
	AiPersonalityKind.Kind.MOON_HUNTER,
	AiPersonalityKind.Kind.PASSIVE,
	AiPersonalityKind.Kind.BALANCED,
]

const _AdaptiveAiStrategyScript := preload("res://scripts/ai/adaptive_ai_strategy.gd")


static func get_mode_label() -> String:
	if not USE_MIXED_PERSONALITIES:
		return "all_balanced"
	return "mixed_moon_s1_passive_s2_balanced_s3"


static func get_seat_personality_label(seat_index: int) -> String:
	if not USE_MIXED_PERSONALITIES:
		return "balanced"
	match seat_index:
		1:
			return "moon_hunter"
		2:
			return "passive"
		3:
			return "balanced"
		_:
			return "balanced"


static func create_for_simulation_seat(seat_index: int) -> AiStrategy:
	if not USE_MIXED_PERSONALITIES:
		return HeuristicStrategy.new()
	match seat_index:
		0:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.BALANCED,
				HeuristicStrategy.new()
			)
		1:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.MOON_HUNTER,
				MoonShooterStrategy.new()
			)
		2:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.PASSIVE,
				PassiveStrategy.new()
			)
		3:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.BALANCED,
				HeuristicStrategy.new()
			)
		_:
			return HeuristicStrategy.new()


static func create_for_seat(seat_index: int) -> AiStrategy:
	if not USE_MIXED_PERSONALITIES:
		return HeuristicStrategy.new()
	match seat_index:
		0:
			return HeuristicStrategy.new()
		1:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.MOON_HUNTER,
				MoonShooterStrategy.new()
			)
		2:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.PASSIVE,
				PassiveStrategy.new()
			)
		3:
			return _wrap_adaptive_if_needed(
				AiPersonalityKind.Kind.BALANCED,
				HeuristicStrategy.new()
			)
		_:
			return HeuristicStrategy.new()


static func create_for_opponent_seat(opponent_seat_index: int) -> AiStrategy:
	assert(opponent_seat_index >= 1 and opponent_seat_index < HeartsRules.PLAYER_COUNT)
	if not USE_MIXED_PERSONALITIES:
		return HeuristicStrategy.new()
	var personality: AiPersonalityKind.Kind = MIXED_OPPONENT_PERSONALITIES[opponent_seat_index - 1]
	return _wrap_adaptive_if_needed(personality, create_strategy(personality))


static func create_strategy(personality: AiPersonalityKind.Kind) -> AiStrategy:
	match personality:
		AiPersonalityKind.Kind.PASSIVE:
			return PassiveStrategy.new()
		AiPersonalityKind.Kind.MOON_HUNTER:
			return MoonShooterStrategy.new()
		_:
			return HeuristicStrategy.new()


static func _wrap_adaptive_if_needed(personality: AiPersonalityKind.Kind, inner: AiStrategy) -> AiStrategy:
	if not USE_MIXED_PERSONALITIES:
		return inner
	return _AdaptiveAiStrategyScript.new(personality, inner)


static func format_table_line() -> String:
	if not USE_MIXED_PERSONALITIES:
		return "IA adversaires : toutes équilibrées (HeuristicStrategy)"
	return (
		"IA adversaires : S1 chasseur de lune | S2 passive | S3 équilibrée"
	)
