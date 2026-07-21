extends GdUnitTestSuite
## Tests unitaires NetworkLobbyBook (IDEA-00009 — découpe NetworkService).


func test_reset_creates_four_empty_seats() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	assert_int(book.lobby.seats.size()).is_equal(HeartsRules.PLAYER_COUNT)
	assert_int(book.local_seat_index).is_equal(-1)
	assert_dict(book.peer_to_seat).is_empty()


func test_register_host_occupies_seat_zero() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "local-host")
	assert_int(book.local_seat_index).is_equal(0)
	assert_int(book.get_seat_for_peer(1)).is_equal(0)
	assert_int(book.get_connected_human_count()).is_equal(1)
	assert_that(book.get_profile(0)).is_not_null()


func test_assign_connecting_peer_fills_next_seats() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "local-host")
	assert_int(book.assign_connecting_peer(2)).is_equal(1)
	assert_int(book.assign_connecting_peer(3)).is_equal(2)
	assert_int(book.get_connected_human_count()).is_equal(3)


func test_assign_rejects_when_full() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "h")
	assert_int(book.assign_connecting_peer(2)).is_equal(1)
	assert_int(book.assign_connecting_peer(3)).is_equal(2)
	assert_int(book.assign_connecting_peer(4)).is_equal(3)
	assert_int(book.assign_connecting_peer(5)).is_equal(-1)


func test_erase_peer_and_clear_seat() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "h")
	book.assign_connecting_peer(2)
	var seat: int = book.erase_peer(2)
	assert_int(seat).is_equal(1)
	book.clear_seat(seat)
	assert_that(book.get_profile(1)).is_null()
	assert_int(book.get_seat_for_peer(2)).is_equal(-1)
