class_name TableCopyTest
extends GdUnitTestSuite


const __source = "res://scripts/core/i18n/copy/table_copy.gd"


#region default_player_name
func test_default_player_name_french_locale() -> void:
	TranslationServer.set_locale("fr")
	assert_str(TableCopy.default_player_name(0)).is_equal("Vous")
	assert_str(TableCopy.default_player_name(2)).is_equal("Adversaire 2")


func test_default_player_name_english_locale() -> void:
	TranslationServer.set_locale("en")
	assert_str(TableCopy.default_player_name(0)).is_equal("You")
	assert_str(TableCopy.default_player_name(1)).is_equal("Opponent 1")
#endregion


#region human_turn_hint
func test_human_turn_hint_two_of_clubs() -> void:
	TranslationServer.set_locale("fr")
	assert_str(TableCopy.human_turn_hint(true, true, false)).contains("2 de Trèfle")
#endregion
