class_name CardPlayedEvent
extends GameEvent


var player_index: int = -1
var card_id: int = -1
var trick_index: int = 0
var next_player_index: int = -1


func _init(
	player_index_value: int,
	card: CardModel,
	trick_index_value: int,
	next_player_index_value: int
) -> void:
	event_type = TYPE_CARD_PLAYED
	player_index = player_index_value
	card_id = card.get_id() if card != null else -1
	trick_index = trick_index_value
	next_player_index = next_player_index_value


func to_dict() -> Dictionary:
	return {
		"type": event_type,
		"player_index": player_index,
		"card_id": card_id,
		"trick_index": trick_index,
		"next_player_index": next_player_index,
	}


static func from_dict(data: Dictionary) -> CardPlayedEvent:
	var event := CardPlayedEvent.new(
		int(data.get("player_index", -1)),
		CardModel.from_id(int(data.get("card_id", 0))),
		int(data.get("trick_index", 0)),
		int(data.get("next_player_index", -1))
	)
	return event
