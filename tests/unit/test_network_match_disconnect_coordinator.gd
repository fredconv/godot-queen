extends GdUnitTestSuite
## Tests NetworkMatchDisconnectCoordinator (IDEA-00009).


func test_begin_and_pending() -> void:
	var coord := NetworkMatchDisconnectCoordinator.new()
	var profile := PlayerProfile.new()
	profile.display_name = "Alice"
	profile.local_player_id = "alice-id"
	profile.peer_connected = true
	coord.begin_match_disconnect(2, profile)
	assert_bool(profile.peer_connected).is_false()
	assert_bool(coord.is_pending(2)).is_true()
	assert_int(coord.find_pending_seat_by_player_id("alice-id")).is_equal(2)


func test_complete_reconnection() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "h")
	book.assign_connecting_peer(2)
	var coord := NetworkMatchDisconnectCoordinator.new()
	var profile: PlayerProfile = book.get_profile(1)
	coord.begin_match_disconnect(1, profile)
	var ok: bool = coord.complete_reconnection(book, 99, 1, "Bob", "bob-id")
	assert_bool(ok).is_true()
	assert_bool(coord.is_pending(1)).is_false()
	assert_int(book.get_seat_for_peer(99)).is_equal(1)
	assert_bool(book.get_profile(1).peer_connected).is_true()


func test_apply_ai_replacement() -> void:
	var book := NetworkLobbyBook.new()
	book.reset()
	book.register_host_player(1, "Host", "h")
	book.assign_connecting_peer(2)
	var coord := NetworkMatchDisconnectCoordinator.new()
	var profile: PlayerProfile = book.get_profile(1)
	coord.begin_match_disconnect(1, profile)
	var name_out: String = coord.apply_ai_replacement(book, 1)
	assert_str(name_out).is_equal("Player 2")
	assert_bool(book.get_profile(1).is_ai).is_true()
	assert_bool(book.get_profile(1).is_human).is_false()
