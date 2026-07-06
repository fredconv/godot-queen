class_name MenuCopyTest
extends GdUnitTestSuite


const __source = "res://scripts/core/i18n/copy/menu_copy.gd"


#region credits_sfx_attribution_bbcode
func test_credits_sfx_attribution_contains_pixabay_links() -> void:
	TranslationServer.set_locale("en")
	var bbcode: String = MenuCopy.credits_sfx_attribution_bbcode()
	assert_str(bbcode).contains("ALEXIS_GAMING_CAM")
	assert_str(bbcode).contains("[url=")
	assert_str(bbcode).contains("pixabay.com")
	assert_str(bbcode).contains("Sound Effect by")
#endregion
