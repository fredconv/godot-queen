class_name AiPlayMode
extends RefCounted
## Modes stratégiques hiérarchiques de l'IA (minimiser / chasser / casser).


enum Kind {
	MINIMIZE,
	CHASE_MOON,
	BREAK_MOON,
}


const THINKING_DELAY_MINIMIZE_SEC: float = 0.0
const THINKING_DELAY_CHASE_SEC: float = 1.0
const THINKING_DELAY_BREAK_SEC: float = 1.4


static func thinking_delay_sec(mode: Kind) -> float:
	match mode:
		Kind.CHASE_MOON:
			return THINKING_DELAY_CHASE_SEC
		Kind.BREAK_MOON:
			return THINKING_DELAY_BREAK_SEC
		_:
			return THINKING_DELAY_MINIMIZE_SEC


static func mode_label(mode: Kind) -> String:
	match mode:
		Kind.CHASE_MOON:
			return "chase_moon"
		Kind.BREAK_MOON:
			return "break_moon"
		_:
			return "minimize"
