class_name LanGameDiscoveryTest
extends GdUnitTestSuite


const __source = "res://scripts/network/lan_game_discovery.gd"
const _LanGameDiscovery = preload("res://scripts/network/lan_game_discovery.gd")


#region build_beacon_payload
func test_build_beacon_payload_contains_magic_and_fields() -> void:
	var payload: String = _LanGameDiscovery.build_beacon_payload("Alice", 7777, 2, 4)
	var parsed: Variant = JSON.parse_string(payload)
	assert_bool(parsed is Dictionary).is_true()
	var data: Dictionary = parsed as Dictionary
	assert_str(str(data.get("magic", ""))).is_equal(_LanGameDiscovery.MAGIC)
	assert_str(str(data.get("host_name", ""))).is_equal("Alice")
	assert_int(int(data.get("port", 0))).is_equal(7777)
	assert_int(int(data.get("players", 0))).is_equal(2)
	assert_int(int(data.get("max", 0))).is_equal(4)
#endregion


#region parse_beacon_payload
func test_parse_beacon_payload_returns_session_entry() -> void:
	var payload: String = _LanGameDiscovery.build_beacon_payload("Bob", 7777, 1, 4)
	var entry: Dictionary = _LanGameDiscovery.parse_beacon_payload(payload, "192.168.1.10")
	assert_str(str(entry.get("id", ""))).is_equal("192.168.1.10:7777")
	assert_str(str(entry.get("address", ""))).is_equal("192.168.1.10")
	assert_int(int(entry.get("port", 0))).is_equal(7777)
	assert_str(str(entry.get("host_name", ""))).is_equal("Bob")
	assert_int(int(entry.get("players", 0))).is_equal(1)
	assert_int(int(entry.get("max_players", 0))).is_equal(4)


func test_parse_beacon_payload_rejects_invalid_magic() -> void:
	var payload: String = JSON.stringify({"magic": "other", "port": 7777})
	assert_dict(_LanGameDiscovery.parse_beacon_payload(payload, "192.168.1.5")).is_empty()


func test_parse_beacon_payload_uses_sender_ip_when_host_name_missing() -> void:
	var payload: String = JSON.stringify({
		"magic": _LanGameDiscovery.MAGIC,
		"port": 7777,
		"players": 1,
		"max": 4,
	})
	var entry: Dictionary = _LanGameDiscovery.parse_beacon_payload(payload, "10.0.0.2")
	assert_str(str(entry.get("host_name", ""))).is_equal("10.0.0.2")
#endregion
