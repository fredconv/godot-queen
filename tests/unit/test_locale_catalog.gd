class_name LocaleCatalogTest
extends GdUnitTestSuite


const __source = "res://scripts/core/i18n/locale_catalog.gd"


#region locales
func test_locales_include_planned_languages() -> void:
	assert_array(LocaleCatalog.LOCALES).contains_exactly("fr", "en", "de", "es", "pt", "zh")


func test_normalize_unknown_falls_back_to_french() -> void:
	assert_str(LocaleCatalog.normalize("it")).is_equal(LocaleCatalog.FALLBACK_LOCALE)
#endregion
