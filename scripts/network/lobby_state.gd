class_name LobbyState
extends RefCounted
## État d'un lobby avant démarrage de partie (local ou réseau futur).


const ERROR_NONE: StringName = &""
const ERROR_TABLE_FULL: StringName = &"table_full"
const ERROR_SEAT_OCCUPIED: StringName = &"seat_occupied"
const ERROR_NOT_READY: StringName = &"not_ready"
const ERROR_INVALID_SEAT: StringName = &"invalid_seat"

var lobby_id: String = ""
var host_peer_id: int = 1
var seats: Array[SeatAssignment] = []
var max_seats: int = HeartsRules.PLAYER_COUNT
var match_started: bool = false


func to_dict() -> Dictionary:
	var seat_data: Array = []
	for assignment in seats:
		seat_data.append(assignment.to_dict())
	return {
		"lobby_id": lobby_id,
		"host_peer_id": host_peer_id,
		"seats": seat_data,
		"max_seats": max_seats,
		"match_started": match_started,
	}


static func from_dict(data: Dictionary) -> LobbyState:
	var state := LobbyState.new()
	state.lobby_id = str(data.get("lobby_id", ""))
	state.host_peer_id = int(data.get("host_peer_id", 1))
	state.max_seats = int(data.get("max_seats", HeartsRules.PLAYER_COUNT))
	state.match_started = bool(data.get("match_started", false))
	for entry in data.get("seats", []):
		if entry is Dictionary:
			state.seats.append(SeatAssignment.from_dict(entry))
	return state
