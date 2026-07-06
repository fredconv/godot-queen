class_name LocaleFlagIconsTest
extends GdUnitTestSuite


const __source = "res://scripts/core/i18n/locale_flag_icons.gd"


#region get_icon
func test_get_icon_returns_texture_for_each_supported_locale() -> void:
	for locale in LocaleCatalog.LOCALES:
		var icon: Texture2D = LocaleFlagIcons.get_icon(locale)
		assert_object(icon).is_not_null()
		assert_int(icon.get_width()).is_equal(LocaleFlagIcons.FLAG_SIZE.x)
		assert_int(icon.get_height()).is_equal(LocaleFlagIcons.FLAG_SIZE.y)


func test_get_icon_unknown_locale_falls_back_to_french_flag() -> void:
	var icon: Texture2D = LocaleFlagIcons.get_icon("xx")
	assert_object(icon).is_not_null()
	assert_that(icon).is_equal(LocaleFlagIcons.get_icon("fr"))
#endregion
