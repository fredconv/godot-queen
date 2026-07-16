class_name PlayCardAction
extends PlayerAction
## Intention : jouer une carte pour un siège donné.


var player_index: int = -1
var card: CardModel = null


func _init(player_index_value: int = -1, card_value: CardModel = null) -> void:
	action_type = TYPE_PLAY_CARD
	player_index = player_index_value
	card = card_value


func to_dict() -> Dictionary:
	return {
		"type": action_type,
		"player_index": player_index,
		"card_id": card.get_id() if card != null else -1,
	}


static func from_dict(data: Dictionary) -> PlayCardAction:
	var card_id: int = int(data.get("card_id", -1))
	var parsed_card: CardModel = CardModel.from_id(card_id) if card_id >= 0 else null
	return PlayCardAction.new(int(data.get("player_index", -1)), parsed_card)
