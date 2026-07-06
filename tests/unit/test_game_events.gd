class_name GameEventsTest
extends GdUnitTestSuite


const __source = "res://scripts/game_events/game_event.gd"


#region round_trip
func test_card_played_event_round_trip() -> void:
	var event := CardPlayedEvent.new(1, CardModel.new(Suit.CLUBS, Rank.FIVE), 2, 2)
	var restored: CardPlayedEvent = CardPlayedEvent.from_dict(event.to_dict())
	assert_int(restored.player_index).is_equal(event.player_index)
	assert_int(restored.card_id).is_equal(event.card_id)
	assert_int(restored.trick_index).is_equal(event.trick_index)
	assert_int(restored.next_player_index).is_equal(event.next_player_index)


func test_public_event_contains_no_private_hand_data() -> void:
	var event := CardPlayedEvent.new(0, CardModel.new(Suit.CLUBS, Rank.TWO), 0, 1)
	var data := event.to_dict()
	assert_bool(data.has("hand_card_ids")).is_false()
#endregion
