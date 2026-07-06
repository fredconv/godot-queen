class_name ScoresUpdatedEvent
extends GameEvent


var cumulative_scores: Array[int] = []


func _init(scores: Array) -> void:
	event_type = TYPE_SCORES_UPDATED
	cumulative_scores = []
	for score in scores:
		cumulative_scores.append(int(score))


func to_dict() -> Dictionary:
	return {
		"type": event_type,
		"cumulative_scores": cumulative_scores.duplicate(),
	}


static func from_dict(data: Dictionary) -> ScoresUpdatedEvent:
	return ScoresUpdatedEvent.new(data.get("cumulative_scores", []))
