class_name TrickResolvedEvent
extends GameEvent


var winner_index: int = -1
var trick_points: int = 0
var trick_index: int = 0


func _init(winner_index_value: int, points: int, trick_index_value: int) -> void:
	event_type = TYPE_TRICK_RESOLVED
	winner_index = winner_index_value
	trick_points = points
	trick_index = trick_index_value


func to_dict() -> Dictionary:
	return {
		"type": event_type,
		"winner_index": winner_index,
		"trick_points": trick_points,
		"trick_index": trick_index,
	}


static func from_dict(data: Dictionary) -> TrickResolvedEvent:
	return TrickResolvedEvent.new(
		int(data.get("winner_index", -1)),
		int(data.get("trick_points", 0)),
		int(data.get("trick_index", 0))
	)
