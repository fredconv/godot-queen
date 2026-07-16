class_name InviteCodeGeneratorTest
extends GdUnitTestSuite


const __source = "res://scripts/network/invite_code_generator.gd"
const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")


#region generate
func test_generate_returns_formatted_code() -> void:
	var code: String = _InviteCodeGenerator.generate()
	assert_bool(_InviteCodeGenerator.is_valid(code)).is_true()
	assert_str(code).contains("-")
	assert_int(code.length()).is_equal(9)
#endregion


#region normalize_input
func test_normalize_input_accepts_code_without_dash() -> void:
	assert_str(_InviteCodeGenerator.normalize_input("ABCD2345")).is_equal("ABCD-2345")


func test_normalize_input_rejects_short_code() -> void:
	assert_str(_InviteCodeGenerator.normalize_input("AB12")).is_empty()
#endregion
