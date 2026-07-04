class_name TestDeck
extends GdUnitTestSuite
## Tests unitaires de Deck (modèle pur, sans scène).

func test_create_standard_52_has_52_unique_cards() -> void:
	var deck := Deck.create_standard_52()
	assert_int(deck.size()).is_equal(52)

	var seen_ids := {}
	while not deck.is_empty():
		var card: CardModel = deck.draw()
		seen_ids[card.get_id()] = true
	assert_int(seen_ids.size()).is_equal(52)


func test_draw_reduces_size_and_returns_top_card() -> void:
	var deck := Deck.create_standard_52()
	var expected_top := deck.peek()
	var starting_size := deck.size()

	var drawn := deck.draw()

	assert_bool(drawn.equals(expected_top)).is_true()
	assert_int(deck.size()).is_equal(starting_size - 1)


func test_draw_on_empty_deck_returns_null() -> void:
	var deck := Deck.create_standard_52()
	deck.deal(52)

	assert_bool(deck.is_empty()).is_true()
	assert_object(deck.draw()).is_null()


func test_peek_does_not_remove_card() -> void:
	var deck := Deck.create_standard_52()
	var size_before := deck.size()

	var peeked := deck.peek()

	assert_bool(peeked.equals(deck.peek())).is_true()
	assert_int(deck.size()).is_equal(size_before)


func test_deal_returns_requested_count() -> void:
	var deck := Deck.create_standard_52()

	var hand_cards := deck.deal(13)

	assert_array(hand_cards).has_size(13)
	assert_int(deck.size()).is_equal(39)


func test_deal_more_than_remaining_stops_at_deck_size() -> void:
	var deck := Deck.create_standard_52()
	deck.deal(50)

	var remaining := deck.deal(10)

	assert_array(remaining).has_size(2)
	assert_bool(deck.is_empty()).is_true()


func test_reset_restores_52_cards() -> void:
	var deck := Deck.create_standard_52()
	deck.deal(20)

	deck.reset()

	assert_int(deck.size()).is_equal(52)


func test_shuffle_with_same_seed_is_deterministic() -> void:
	var deck_a := Deck.create_standard_52()
	var deck_b := Deck.create_standard_52()

	deck_a.shuffle(42)
	deck_b.shuffle(42)

	var ids_a: Array[int] = []
	var ids_b: Array[int] = []
	for card in deck_a.deal(52):
		ids_a.append(card.get_id())
	for card in deck_b.deal(52):
		ids_b.append(card.get_id())

	assert_array(ids_a).is_equal(ids_b)


func test_shuffle_changes_card_order() -> void:
	var ordered := Deck.create_standard_52()
	var shuffled := Deck.create_standard_52()
	shuffled.shuffle(7)

	var ordered_ids: Array[int] = []
	var shuffled_ids: Array[int] = []
	for card in ordered.deal(52):
		ordered_ids.append(card.get_id())
	for card in shuffled.deal(52):
		shuffled_ids.append(card.get_id())

	assert_array(shuffled_ids).is_not_equal(ordered_ids)
