class_name MoonSuspicionEvent
extends RefCounted
## Événement social : un joueur soupçonne un adversaire de tenter la Lune.


var suspector_seat: int = -1
var suspected_seat: int = -1
var hand_number: int = 1
var seen_by_seats: Array[int] = []


func mark_seen_by(seat_index: int) -> void:
	if seat_index < 0 or seat_index in seen_by_seats:
		return
	seen_by_seats.append(seat_index)


func was_seen_by(seat_index: int) -> bool:
	return seat_index in seen_by_seats


func all_humans_seen(human_seats: Array[int]) -> bool:
	for seat_index in human_seats:
		if seat_index not in seen_by_seats:
			return false
	return true


func to_dict() -> Dictionary:
	return {
		"suspector_seat": suspector_seat,
		"suspected_seat": suspected_seat,
		"hand_number": hand_number,
		"seen_by_seats": seen_by_seats.duplicate(),
	}


static func from_dict(data: Dictionary) -> MoonSuspicionEvent:
	var event := MoonSuspicionEvent.new()
	event.suspector_seat = int(data.get("suspector_seat", -1))
	event.suspected_seat = int(data.get("suspected_seat", -1))
	event.hand_number = int(data.get("hand_number", 1))
	var seen: Array = data.get("seen_by_seats", [])
	for seat_value in seen:
		event.seen_by_seats.append(int(seat_value))
	return event
