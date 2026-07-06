class_name PublicGameSnapshot
extends RefCounted
## État public observable par tous les clients (aucune main privée adverse).


var current_player: int = -1
var trick_leader: int = -1
var trick_cards: Array = []  # [{player_index, card_id}, ...]
var lead_suit: int = -1
var hand_card_counts: Array[int] = []
var display_scores: Array[int] = []
var cumulative_scores: Array[int] = []
var phase: int = MatchManager.Phase.DEALING
var hand_number: int = 0
var hearts_broken: bool = false
var trick_number: int = 0


func to_dict() -> Dictionary:
	return {
		"current_player": current_player,
		"trick_leader": trick_leader,
		"trick_cards": trick_cards.duplicate(true),
		"lead_suit": lead_suit,
		"hand_card_counts": hand_card_counts.duplicate(),
		"display_scores": display_scores.duplicate(),
		"cumulative_scores": cumulative_scores.duplicate(),
		"phase": phase,
		"hand_number": hand_number,
		"hearts_broken": hearts_broken,
		"trick_number": trick_number,
	}


static func from_dict(data: Dictionary) -> PublicGameSnapshot:
	var snapshot := PublicGameSnapshot.new()
	snapshot.current_player = int(data.get("current_player", -1))
	snapshot.trick_leader = int(data.get("trick_leader", -1))
	snapshot.trick_cards = (data.get("trick_cards", []) as Array).duplicate(true)
	snapshot.lead_suit = int(data.get("lead_suit", -1))
	for count in data.get("hand_card_counts", []):
		snapshot.hand_card_counts.append(int(count))
	for score in data.get("display_scores", []):
		snapshot.display_scores.append(int(score))
	for score in data.get("cumulative_scores", []):
		snapshot.cumulative_scores.append(int(score))
	snapshot.phase = int(data.get("phase", MatchManager.Phase.DEALING))
	snapshot.hand_number = int(data.get("hand_number", 0))
	snapshot.hearts_broken = bool(data.get("hearts_broken", false))
	snapshot.trick_number = int(data.get("trick_number", 0))
	return snapshot
