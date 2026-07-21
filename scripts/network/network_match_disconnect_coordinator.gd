class_name NetworkMatchDisconnectCoordinator
extends RefCounted
## Phase D : déconnexion en match, reconnexion, remplacement IA (état + ticks).
## Les broadcasts RPC restent dans NetworkService / NetworkMatchRelay.


const COUNTDOWN_BROADCAST_INTERVAL_SEC: float = 1.0

var state: DisconnectState = DisconnectState.new()
var _countdown_broadcast_accum: float = 0.0


func reset() -> void:
	state = DisconnectState.new()
	_countdown_broadcast_accum = 0.0


func is_pending(seat_index: int) -> bool:
	return state.is_pending(seat_index)


func find_pending_seat_by_player_id(local_player_id: String) -> int:
	return state.find_pending_seat_by_player_id(local_player_id)


func begin_match_disconnect(seat_index: int, profile: PlayerProfile) -> void:
	profile.peer_connected = false
	state.begin_disconnect(seat_index, profile.display_name, profile.local_player_id)
	_countdown_broadcast_accum = 0.0


func complete_reconnection(
	book: NetworkLobbyBook,
	peer_id: int,
	seat_index: int,
	display_name: String,
	local_player_id: String
) -> bool:
	if seat_index < 0 or seat_index >= book.lobby.seats.size():
		return false
	var assignment: SeatAssignment = book.lobby.seats[seat_index]
	if assignment.profile == null:
		return false
	state.cancel_reconnect(seat_index)
	assignment.profile.display_name = display_name
	assignment.profile.local_player_id = local_player_id
	assignment.profile.peer_id = peer_id
	assignment.profile.peer_connected = true
	assignment.profile.is_ready = true
	book.peer_to_seat[peer_id] = seat_index
	return true


## Retourne { "expired": Array, "broadcast_countdown": bool, "pending_indices": Array }.
func tick(delta: float, match_in_progress: bool) -> Dictionary:
	var result: Dictionary = {
		"expired": [],
		"broadcast_countdown": false,
		"pending_indices": [],
	}
	if not match_in_progress:
		return result
	result["expired"] = state.tick(delta)
	_countdown_broadcast_accum += delta
	if _countdown_broadcast_accum < COUNTDOWN_BROADCAST_INTERVAL_SEC:
		return result
	_countdown_broadcast_accum = 0.0
	result["broadcast_countdown"] = true
	result["pending_indices"] = state.get_pending_seat_indices()
	return result


func apply_ai_replacement(book: NetworkLobbyBook, seat_index: int) -> String:
	if seat_index < 0 or seat_index >= book.lobby.seats.size():
		return ""
	var assignment: SeatAssignment = book.lobby.seats[seat_index]
	if assignment.profile == null:
		return ""
	var display_name: String = assignment.profile.display_name
	state.mark_replaced_by_ai(seat_index)
	assignment.profile.is_human = false
	assignment.profile.is_ai = true
	assignment.profile.peer_connected = false
	assignment.profile.peer_id = -1
	return display_name


func get_display_name(seat_index: int) -> String:
	return state.get_display_name(seat_index)


func get_remaining_sec(seat_index: int) -> float:
	return state.get_remaining_sec(seat_index)
