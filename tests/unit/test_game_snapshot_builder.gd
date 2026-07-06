class_name GameSnapshotBuilderTest
extends GdUnitTestSuite


const __source = "res://scripts/match/game_snapshot_builder.gd"


#region public_snapshot
func test_public_snapshot_has_no_private_hands() -> void:
	var manager := MatchManager.new()
	manager.start_new_match(99)
	var snapshot := GameSnapshotBuilder.build_public(manager)
	var data := snapshot.to_dict()
	assert_bool(data.has("hand_card_ids")).is_false()
	assert_array(snapshot.hand_card_counts).has_size(4)
#endregion


#region private_snapshot
func test_private_snapshot_contains_only_requested_hand() -> void:
	var manager := MatchManager.new()
	manager.start_new_match(11)
	var private_snapshot := GameSnapshotBuilder.build_private(manager, 0)
	assert_int(private_snapshot.player_index).is_equal(0)
	assert_int(private_snapshot.hand_card_ids.size()).is_equal(13)


func test_private_snapshot_invalid_player_returns_empty_hand() -> void:
	var manager := MatchManager.new()
	manager.start_new_match(5)
	var snapshot := GameSnapshotBuilder.build_private(manager, 99)
	assert_array(snapshot.hand_card_ids).is_empty()
#endregion
