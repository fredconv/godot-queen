class_name PrivatePlayerSnapshot
extends RefCounted
## État privé d'un seul joueur (sa main et ses coups légaux).


var player_index: int = -1
var hand_card_ids: Array[int] = []
var legal_card_ids: Array[int] = []


func to_dict() -> Dictionary:
	return {
		"player_index": player_index,
		"hand_card_ids": hand_card_ids.duplicate(),
		"legal_card_ids": legal_card_ids.duplicate(),
	}


static func from_dict(data: Dictionary) -> PrivatePlayerSnapshot:
	var snapshot := PrivatePlayerSnapshot.new()
	snapshot.player_index = int(data.get("player_index", -1))
	for card_id in data.get("hand_card_ids", []):
		snapshot.hand_card_ids.append(int(card_id))
	for card_id in data.get("legal_card_ids", []):
		snapshot.legal_card_ids.append(int(card_id))
	return snapshot
