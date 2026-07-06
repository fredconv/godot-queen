class_name PlayerAction
extends RefCounted
## Intention de jeu sérialisable (solo ou réseau). Aucune référence à un Node.

const TYPE_PLAY_CARD: StringName = &"play_card"
const TYPE_READY: StringName = &"ready"


var action_type: StringName = &""


func to_dict() -> Dictionary:
	return {"type": action_type}


static func from_dict(data: Dictionary) -> PlayerAction:
	var type_name: StringName = data.get("type", &"")
	match type_name:
		PlayerAction.TYPE_PLAY_CARD:
			return PlayCardAction.from_dict(data)
		PlayerAction.TYPE_READY:
			return ReadyAction.from_dict(data)
		_:
			return null
