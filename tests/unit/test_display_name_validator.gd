class_name DisplayNameValidatorTest
extends GdUnitTestSuite


const __source = "res://scripts/core/player/display_name_validator.gd"


#region is_valid
func test_is_valid_accepts_reasonable_name() -> void:
	assert_bool(DisplayNameValidator.is_valid("Alice")).is_true()


func test_is_valid_rejects_empty_or_too_short() -> void:
	assert_bool(DisplayNameValidator.is_valid("")).is_false()
	assert_bool(DisplayNameValidator.is_valid("  a  ")).is_false()


func test_is_valid_rejects_forbidden_characters() -> void:
	assert_bool(DisplayNameValidator.is_valid("bad<name")).is_false()
#endregion


#region validate_or_fallback
func test_validate_or_fallback_uses_fallback_when_invalid() -> void:
	assert_str(DisplayNameValidator.validate_or_fallback("x")).is_equal(DisplayNameValidator.FALLBACK_NAME)
#endregion
