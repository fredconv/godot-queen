class_name PlayCardActionTest
extends GdUnitTestSuite


const __source = "res://scripts/game_actions/play_card_action.gd"


#region apply
func test_legal_play_via_action() -> void:
	var controller := LocalMatchController.new()
	for seat in range(1, HeartsRules.PLAYER_COUNT):
		controller.match_manager.set_ai_player(seat, AiPlayer.new())
	controller.start_new_match(42)
	var player_index: int = controller.match_manager.current_player
	var legal: Array[CardModel] = controller.match_manager.get_legal_plays(player_index)
	var action := PlayCardAction.new(player_index, legal[0])
	var result := controller.submit_action(action)
	assert_bool(result.success).is_true()
	assert_that(result.play_result).is_not_null()


func test_illegal_play_rejected() -> void:
	var controller := LocalMatchController.new()
	controller.start_new_match(7)
	var player_index: int = controller.match_manager.current_player
	var legal: Array[CardModel] = controller.match_manager.get_legal_plays(player_index)
	var illegal: CardModel = null
	for card in controller.match_manager.hands[player_index].cards():
		if not _card_in_list(card, legal):
			illegal = card
			break
	assert_that(illegal).is_not_null()
	var result := controller.submit_action(PlayCardAction.new(player_index, illegal))
	assert_bool(result.success).is_false()
	assert_str(result.error_code).is_equal(ActionResult.ERROR_RULE_VIOLATION)


static func _card_in_list(card: CardModel, cards: Array[CardModel]) -> bool:
	for entry in cards:
		if entry.equals(card):
			return true
	return false


func test_wrong_turn_rejected() -> void:
	var controller := LocalMatchController.new()
	controller.start_new_match(3)
	var legal := controller.match_manager.get_legal_plays(0)
	var result := controller.submit_action(PlayCardAction.new(1, legal[0]))
	assert_bool(result.success).is_false()
	assert_str(result.error_code).is_equal(ActionResult.ERROR_NOT_YOUR_TURN)
#endregion


#region serialization
func test_play_card_action_round_trip() -> void:
	var card := CardModel.new(Suit.SPADES, Rank.QUEEN)
	var action := PlayCardAction.new(2, card)
	var restored: PlayCardAction = PlayCardAction.from_dict(action.to_dict())
	assert_int(restored.player_index).is_equal(2)
	assert_bool(restored.card.equals(card)).is_true()
#endregion
