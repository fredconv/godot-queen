class_name TableThemePathsTest
extends GdUnitTestSuite


const __source = "res://scripts/core/table_theme_paths.gd"


#region normalize_theme_id
func test_normalize_theme_id_defaults_to_classic() -> void:
	assert_that(TableThemePaths.normalize_theme_id("unknown")).is_equal(TableThemePaths.THEME_CLASSIC)


func test_normalize_theme_id_accepts_tapis() -> void:
	assert_that(TableThemePaths.normalize_theme_id("tapis")).is_equal(TableThemePaths.THEME_TAPIS)
#endregion
