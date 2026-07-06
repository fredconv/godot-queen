class_name GameEvent
extends RefCounted
## Événement de jeu sérialisable, sans référence Node.

const TYPE_CARD_PLAYED: StringName = &"card_played"
const TYPE_TRICK_RESOLVED: StringName = &"trick_resolved"
const TYPE_SCORES_UPDATED: StringName = &"scores_updated"
const TYPE_HAND_COMPLETED: StringName = &"hand_completed"
const TYPE_MATCH_COMPLETED: StringName = &"match_completed"
const TYPE_ERROR: StringName = &"error"

var event_type: StringName = &""


func to_dict() -> Dictionary:
	return {"type": event_type}


static func from_dict(data: Dictionary) -> GameEvent:
	var type_name: StringName = data.get("type", &"")
	match type_name:
		GameEvent.TYPE_CARD_PLAYED:
			return CardPlayedEvent.from_dict(data)
		GameEvent.TYPE_TRICK_RESOLVED:
			return TrickResolvedEvent.from_dict(data)
		GameEvent.TYPE_SCORES_UPDATED:
			return ScoresUpdatedEvent.from_dict(data)
		GameEvent.TYPE_HAND_COMPLETED:
			return HandCompletedEvent.from_dict(data)
		GameEvent.TYPE_MATCH_COMPLETED:
			return MatchCompletedEvent.from_dict(data)
		_:
			return null
