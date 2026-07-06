class_name HandCompletedEvent
extends GameEvent


var hand_scores: Array[int] = []
var hand_number: int = 0


func _init(scores: Array, hand_number_value: int) -> void:
	event_type = TYPE_HAND_COMPLETED
	hand_scores = []
	for score in scores:
		hand_scores.append(int(score))
	hand_number = hand_number_value


func to_dict() -> Dictionary:
	return {
		"type": event_type,
		"hand_scores": hand_scores.duplicate(),
		"hand_number": hand_number,
	}


static func from_dict(data: Dictionary) -> HandCompletedEvent:
	return HandCompletedEvent.new(data.get("hand_scores", []), int(data.get("hand_number", 0)))
