class_name TestCardModel
extends GdUnitTestSuite
## Tests unitaires de CardModel (modèle pur, sans scène).

func test_get_id_is_unique_and_reversible() -> void:
	var card := CardModel.new(Suit.HEARTS, Rank.QUEEN)
	var id := card.get_id()
	assert_int(id).is_between(0, 51)

	var rebuilt := CardModel.from_id(id)
	assert_bool(rebuilt.equals(card)).is_true()


func test_from_id_covers_full_range() -> void:
	for id in range(52):
		var card := CardModel.from_id(id)
		assert_int(card.get_id()).is_equal(id)


func test_equals() -> void:
	var a := CardModel.new(Suit.CLUBS, Rank.TWO)
	var b := CardModel.new(Suit.CLUBS, Rank.TWO)
	var c := CardModel.new(Suit.CLUBS, Rank.THREE)

	assert_bool(a.equals(b)).is_true()
	assert_bool(a.equals(c)).is_false()
	assert_bool(a.equals(null)).is_false()


func test_is_heart() -> void:
	assert_bool(CardModel.new(Suit.HEARTS, Rank.TWO).is_heart()).is_true()
	assert_bool(CardModel.new(Suit.SPADES, Rank.TWO).is_heart()).is_false()


func test_is_spade() -> void:
	assert_bool(CardModel.new(Suit.SPADES, Rank.TWO).is_spade()).is_true()
	assert_bool(CardModel.new(Suit.HEARTS, Rank.TWO).is_spade()).is_false()


func test_is_queen_of_spades() -> void:
	assert_bool(CardModel.new(Suit.SPADES, Rank.QUEEN).is_queen_of_spades()).is_true()
	assert_bool(CardModel.new(Suit.SPADES, Rank.KING).is_queen_of_spades()).is_false()
	assert_bool(CardModel.new(Suit.HEARTS, Rank.QUEEN).is_queen_of_spades()).is_false()


func test_compare_rank_same_suit() -> void:
	var low := CardModel.new(Suit.DIAMONDS, Rank.FOUR)
	var high := CardModel.new(Suit.DIAMONDS, Rank.ACE)

	assert_bool(low.compare_rank(high) < 0).is_true()
	assert_bool(high.compare_rank(low) > 0).is_true()
	assert_int(low.compare_rank(low)).is_equal(0)


func test_to_string_is_readable() -> void:
	var card := CardModel.new(Suit.SPADES, Rank.QUEEN)
	assert_str(str(card)).is_equal("Dame de Pique")


func test_all_cards_returns_52_unique_cards() -> void:
	var cards := CardModel.all_cards()
	assert_array(cards).has_size(52)

	var seen_ids := {}
	for card in cards:
		seen_ids[card.get_id()] = true
	assert_int(seen_ids.size()).is_equal(52)
