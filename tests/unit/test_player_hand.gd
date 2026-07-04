class_name TestPlayerHand
extends GdUnitTestSuite
## Tests unitaires de PlayerHand (modèle pur, sans scène).

func test_new_hand_is_empty() -> void:
	var hand := PlayerHand.new()

	assert_bool(hand.is_empty()).is_true()
	assert_int(hand.count()).is_equal(0)


func test_add_card_increases_count_and_contains() -> void:
	var hand := PlayerHand.new()
	var card := CardModel.new(Suit.HEARTS, Rank.TEN)

	hand.add_card(card)

	assert_int(hand.count()).is_equal(1)
	assert_bool(hand.contains(card)).is_true()
	assert_bool(hand.contains(CardModel.new(Suit.HEARTS, Rank.TEN))).is_true()
	assert_bool(hand.contains(CardModel.new(Suit.SPADES, Rank.TEN))).is_false()


func test_remove_card_returns_true_and_removes_it() -> void:
	var hand := PlayerHand.new()
	var card := CardModel.new(Suit.CLUBS, Rank.FIVE)
	hand.add_card(card)

	var removed := hand.remove_card(card)

	assert_bool(removed).is_true()
	assert_bool(hand.contains(card)).is_false()
	assert_bool(hand.is_empty()).is_true()


func test_remove_card_not_in_hand_returns_false() -> void:
	var hand := PlayerHand.new()
	hand.add_card(CardModel.new(Suit.CLUBS, Rank.FIVE))

	var removed := hand.remove_card(CardModel.new(Suit.DIAMONDS, Rank.SIX))

	assert_bool(removed).is_false()
	assert_int(hand.count()).is_equal(1)


func test_cards_are_sorted_by_suit_then_rank() -> void:
	var hand := PlayerHand.new()
	hand.add_card(CardModel.new(Suit.HEARTS, Rank.TWO))
	hand.add_card(CardModel.new(Suit.CLUBS, Rank.KING))
	hand.add_card(CardModel.new(Suit.CLUBS, Rank.TWO))
	hand.add_card(CardModel.new(Suit.DIAMONDS, Rank.FIVE))

	var sorted_cards := hand.cards()

	assert_array(sorted_cards).has_size(4)
	assert_int(sorted_cards[0].suit).is_equal(Suit.CLUBS)
	assert_int(sorted_cards[0].rank).is_equal(Rank.TWO)
	assert_int(sorted_cards[1].suit).is_equal(Suit.CLUBS)
	assert_int(sorted_cards[1].rank).is_equal(Rank.KING)
	assert_int(sorted_cards[2].suit).is_equal(Suit.DIAMONDS)
	assert_int(sorted_cards[3].suit).is_equal(Suit.HEARTS)


func test_cards_returns_a_copy_not_internal_reference() -> void:
	var hand := PlayerHand.new()
	hand.add_card(CardModel.new(Suit.SPADES, Rank.ACE))

	var first_snapshot := hand.cards()
	hand.add_card(CardModel.new(Suit.SPADES, Rank.KING))

	assert_array(first_snapshot).has_size(1)
	assert_int(hand.count()).is_equal(2)
