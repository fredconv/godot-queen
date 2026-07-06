class_name MatchCompletedEvent
extends GameEvent


var winner_index: int = -1
var final_scores: Array[int] = []


func _init(winner_index_value: int, scores: Array) -> void:
	event_type = TYPE_MATCH_COMPLETED
	winner_index = winner_index_value
	final_scores = []
	for score in scores:
		final_scores.append(int(score))


func to_dict() -> Dictionary:
	return {
		"type": event_type,
		"winner_index": winner_index,
		"final_scores": final_scores.duplicate(),
	}


static func from_dict(data: Dictionary) -> MatchCompletedEvent:
	return MatchCompletedEvent.new(
		int(data.get("winner_index", -1)),
		data.get("final_scores", [])
	)
