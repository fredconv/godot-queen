class_name AiPersonalityCatalog
extends RefCounted
## Personnalités des adversaires IA. Un seul flag pour tout remettre en équilibré.


enum Personality {
	BALANCED,
	PASSIVE,
	MOON_HUNTER,
}

## false → les 3 adversaires (et la simu) utilisent HeuristicStrategy uniquement.
const USE_MIXED_PERSONALITIES: bool = true

## Sièges adverses en table (1 = gauche, 2 = haut, 3 = droite).
const MIXED_OPPONENT_PERSONALITIES: Array[Personality] = [
	Personality.MOON_HUNTER,
	Personality.PASSIVE,
	Personality.BALANCED,
]


static func get_mode_label() -> String:
	if not USE_MIXED_PERSONALITIES:
		return "all_balanced"
	return "mixed_moon_s1_passive_s2_balanced_s3"


static func get_seat_personality_label(seat_index: int) -> String:
	var strategy: AiStrategy = create_for_seat(seat_index)
	if strategy is MoonShooterStrategy:
		return "moon_hunter"
	if strategy is PassiveStrategy:
		return "passive"
	return "balanced"


static func create_for_seat(seat_index: int) -> AiStrategy:
	if not USE_MIXED_PERSONALITIES:
		return HeuristicStrategy.new()
	match seat_index:
		0:
			return HeuristicStrategy.new()
		1:
			return MoonShooterStrategy.new()
		2:
			return PassiveStrategy.new()
		3:
			return HeuristicStrategy.new()
		_:
			return HeuristicStrategy.new()


static func create_for_opponent_seat(opponent_seat_index: int) -> AiStrategy:
	assert(opponent_seat_index >= 1 and opponent_seat_index < HeartsRules.PLAYER_COUNT)
	if not USE_MIXED_PERSONALITIES:
		return HeuristicStrategy.new()
	return create_strategy(MIXED_OPPONENT_PERSONALITIES[opponent_seat_index - 1])


static func create_strategy(personality: Personality) -> AiStrategy:
	match personality:
		Personality.PASSIVE:
			return PassiveStrategy.new()
		Personality.MOON_HUNTER:
			return MoonShooterStrategy.new()
		_:
			return HeuristicStrategy.new()


static func format_table_line() -> String:
	if not USE_MIXED_PERSONALITIES:
		return "IA adversaires : toutes équilibrées (HeuristicStrategy)"
	return (
		"IA adversaires : S1 chasseur de lune | S2 passive | S3 équilibrée"
	)
