class_name ReadyAction
extends PlayerAction
## Intention : signaler qu'un joueur est prêt (lobby / futur multijoueur).


var player_index: int = -1
var is_ready: bool = true


func _init(player_index_value: int = -1, ready: bool = true) -> void:
	action_type = TYPE_READY
	player_index = player_index_value
	is_ready = ready


func to_dict() -> Dictionary:
	return {
		"type": action_type,
		"player_index": player_index,
		"is_ready": is_ready,
	}


static func from_dict(data: Dictionary) -> ReadyAction:
	return ReadyAction.new(int(data.get("player_index", -1)), bool(data.get("is_ready", true)))
