class_name GameSnapshotBuilder
extends RefCounted
## Construit des snapshots sérialisables à partir d'un `MatchManager`.


static func build_public(match_manager: MatchManager) -> PublicGameSnapshot:
	var snapshot := PublicGameSnapshot.new()
	if match_manager == null:
		return snapshot
	snapshot.current_player = match_manager.current_player
	snapshot.trick_leader = match_manager.trick_leader
	snapshot.lead_suit = match_manager.trick_manager.lead_suit
	snapshot.phase = match_manager.phase
	snapshot.hand_number = match_manager.hand_number
	snapshot.hearts_broken = match_manager.rule_engine.hearts_broken
	snapshot.trick_number = match_manager.rule_engine.trick_number
	snapshot.cumulative_scores = match_manager.score_manager.get_scores()
	snapshot.display_scores = match_manager.get_display_scores()
	snapshot.trick_cards = _serialize_trick_cards(match_manager)
	snapshot.hand_card_counts = _hand_card_counts(match_manager)
	return snapshot


static func build_private(match_manager: MatchManager, player_index: int) -> PrivatePlayerSnapshot:
	var snapshot := PrivatePlayerSnapshot.new()
	snapshot.player_index = player_index
	if match_manager == null or not _is_valid_player_index(player_index):
		return snapshot
	for card in match_manager.hands[player_index].cards():
		snapshot.hand_card_ids.append(card.get_id())
	if match_manager.phase == MatchManager.Phase.PLAYING and player_index == match_manager.current_player:
		for card in match_manager.get_legal_plays(player_index):
			snapshot.legal_card_ids.append(card.get_id())
	return snapshot


static func _serialize_trick_cards(match_manager: MatchManager) -> Array:
	var entries: Array = []
	for play in match_manager.trick_manager.get_plays():
		var card: CardModel = play["card"]
		entries.append({
			"player_index": play["player_index"],
			"card_id": card.get_id(),
		})
	return entries


static func _hand_card_counts(match_manager: MatchManager) -> Array[int]:
	var counts: Array[int] = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		counts.append(match_manager.hands[player_index].count())
	return counts


static func _is_valid_player_index(player_index: int) -> bool:
	return player_index >= 0 and player_index < HeartsRules.PLAYER_COUNT
