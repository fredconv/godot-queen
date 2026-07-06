class_name GameCopyTest
extends GdUnitTestSuite


const __source = "res://scripts/core/i18n/copy/game_copy.gd"


#region card_description
func test_card_description_french() -> void:
	TranslationServer.set_locale("fr")
	assert_str(GameCopy.card_description(Rank.QUEEN, Suit.SPADES)).is_equal("Dame de Pique")


func test_card_description_english() -> void:
	TranslationServer.set_locale("en")
	assert_str(GameCopy.card_description(Rank.QUEEN, Suit.SPADES)).is_equal("Queen of Spades")


func test_card_description_chinese_suit_first() -> void:
	TranslationServer.set_locale("zh")
	assert_str(GameCopy.card_description(Rank.QUEEN, Suit.SPADES)).is_equal("黑桃Q")
#endregion


#region lead_indicator
func test_lead_indicator_french() -> void:
	TranslationServer.set_locale("fr")
	assert_str(GameCopy.lead_indicator(Suit.HEARTS)).contains("Cœur")
#endregion
