extends GdUnitTestSuite
## IDEA-00010 — helpers lobby sessions / invite code.


func test_format_lan_session_label_contains_host() -> void:
	var label: String = MultiplayerLobbySessions.format_label({
		"source": "lan",
		"host_name": "Alice",
		"players": 2,
		"max_players": 4,
	})
	assert_str(label).contains("Alice")


func test_format_online_session_label_contains_code() -> void:
	var label: String = MultiplayerLobbySessions.format_label({
		"source": "online",
		"host_name": "Bob",
		"players": 1,
		"max_players": 4,
		"invite_code": "ABCD-EFGH",
	})
	assert_str(label).contains("Bob")
	assert_str(label).contains("ABCD-EFGH")


func test_selected_session_empty_when_none() -> void:
	var list := ItemList.new()
	auto_free(list)
	assert_dict(MultiplayerLobbySessions.selected_session(list)).is_empty()


func test_invite_code_live_format_inserts_dash() -> void:
	var edit := LineEdit.new()
	auto_free(edit)
	MultiplayerLobbyInviteCode.apply_live_format(edit, "ABCDEFGH")
	assert_str(edit.text).is_equal("ABCD-EFGH")
