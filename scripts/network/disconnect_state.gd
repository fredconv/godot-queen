class_name DisconnectState
extends RefCounted
## Décompte de reconnexion par siège (30 s indépendants, phase D).


const GRACE_PERIOD_SEC: float = 30.0

enum Status { CONNECTED, DISCONNECTED_PENDING, REPLACED_BY_AI }


class SeatEntry:
	var seat_index: int = -1
	var display_name: String = ""
	var local_player_id: String = ""
	var remaining_sec: float = GRACE_PERIOD_SEC
	var status: Status = Status.DISCONNECTED_PENDING


var _entries: Dictionary = {}


func begin_disconnect(seat_index: int, display_name: String, local_player_id: String) -> void:
	var entry := SeatEntry.new()
	entry.seat_index = seat_index
	entry.display_name = display_name
	entry.local_player_id = local_player_id
	entry.remaining_sec = GRACE_PERIOD_SEC
	entry.status = Status.DISCONNECTED_PENDING
	_entries[seat_index] = entry


func cancel_reconnect(seat_index: int) -> bool:
	if not is_pending(seat_index):
		return false
	_entries.erase(seat_index)
	return true


func mark_replaced_by_ai(seat_index: int) -> void:
	if not _entries.has(seat_index):
		return
	var entry: SeatEntry = _entries[seat_index]
	entry.status = Status.REPLACED_BY_AI
	_entries.erase(seat_index)


func is_pending(seat_index: int) -> bool:
	if not _entries.has(seat_index):
		return false
	return (_entries[seat_index] as SeatEntry).status == Status.DISCONNECTED_PENDING


func get_remaining_sec(seat_index: int) -> float:
	if not _entries.has(seat_index):
		return 0.0
	return (_entries[seat_index] as SeatEntry).remaining_sec


func get_display_name(seat_index: int) -> String:
	if not _entries.has(seat_index):
		return ""
	return (_entries[seat_index] as SeatEntry).display_name


func find_pending_seat_by_player_id(local_player_id: String) -> int:
	if local_player_id.is_empty():
		return -1
	for seat_index in _entries.keys():
		var entry: SeatEntry = _entries[seat_index]
		if entry.status == Status.DISCONNECTED_PENDING and entry.local_player_id == local_player_id:
			return int(seat_index)
	return -1


func tick(delta_sec: float) -> Array[int]:
	var expired: Array[int] = []
	for seat_index in _entries.keys():
		var entry: SeatEntry = _entries[seat_index]
		if entry.status != Status.DISCONNECTED_PENDING:
			continue
		entry.remaining_sec = maxf(entry.remaining_sec - delta_sec, 0.0)
		if entry.remaining_sec <= 0.0:
			expired.append(int(seat_index))
	return expired


func get_pending_seat_indices() -> Array[int]:
	var indices: Array[int] = []
	for seat_index in _entries.keys():
		if is_pending(int(seat_index)):
			indices.append(int(seat_index))
	return indices
