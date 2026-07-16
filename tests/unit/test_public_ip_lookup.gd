class_name PublicIpLookupTest
extends GdUnitTestSuite


const __source = "res://scripts/network/public_ip_lookup.gd"
const _PublicIpLookup = preload("res://scripts/network/public_ip_lookup.gd")


#region parse_response
func test_parse_response_accepts_plain_ipv4() -> void:
	assert_str(_PublicIpLookup.parse_response("203.0.113.42\n")).is_equal("203.0.113.42")


func test_parse_response_rejects_invalid_value() -> void:
	assert_str(_PublicIpLookup.parse_response("not-an-ip")).is_empty()
	assert_str(_PublicIpLookup.parse_response("999.1.1.1")).is_empty()
#endregion


#region format_share_address
func test_format_share_address_includes_port() -> void:
	assert_str(_PublicIpLookup.format_share_address("203.0.113.42", 7777)).is_equal("203.0.113.42:7777")
#endregion
