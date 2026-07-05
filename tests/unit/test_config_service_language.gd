class_name ConfigServiceLanguageTest
extends GdUnitTestSuite


const __source = "res://scripts/services/config_service.gd"


#region normalize_language
func test_normalize_language_defaults_to_french() -> void:
	assert_str(ConfigService.normalize_language("de")).is_equal("fr")
	assert_str(ConfigService.normalize_language("")).is_equal("fr")


func test_normalize_language_accepts_english() -> void:
	assert_str(ConfigService.normalize_language("en")).is_equal("en")
#endregion
