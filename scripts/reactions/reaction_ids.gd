class_name ReactionIds
extends RefCounted
## Identifiants des réactions rapides (pas de texte libre).


enum Id {
	SMILE = 0,
	TAUNT = 1,
	SCREAM = 2,
	SUSPICIOUS = 3,
}

const COUNT: int = 4
const COOLDOWN_SEC: float = 2.5
const DISPLAY_SEC: float = 1.75
const RISE_PX: float = 14.0


static func is_valid(reaction_id: int) -> bool:
	return reaction_id >= 0 and reaction_id < COUNT


static func all_ids() -> Array[int]:
	return [Id.SMILE, Id.TAUNT, Id.SCREAM, Id.SUSPICIOUS]
