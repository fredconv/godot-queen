class_name NetworkPlayPayloadTest
extends GdUnitTestSuite


const __source = "res://scripts/network/network_play_payload.gd"


#region payload
func test_play_result_round_trip() -> void:
	var original := MatchManager.PlayResult.new()
	original.success = true
	original.trick_completed = true
	original.trick_winner = 2
	original.trick_points = 5
	original.hand_completed = false
	var data: Dictionary = NetworkPlayPayload.play_result_to_dict(original)
	var restored: MatchManager.PlayResult = NetworkPlayPayload.play_result_from_dict(data)
	assert_bool(restored.success).is_true()
	assert_bool(restored.trick_completed).is_true()
	assert_int(restored.trick_winner).is_equal(2)
	assert_int(restored.trick_points).is_equal(5)
#endregion
