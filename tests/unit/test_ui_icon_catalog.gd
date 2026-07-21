extends GdUnitTestSuite

const UiIcons = preload("res://scripts/core/ui/ui_icon_catalog.gd")


func test_all_common_icons_share_one_valid_atlas() -> void:
	var first: AtlasTexture = UiIcons.texture(UiIcons.Icon.FOCUS_SPADE)
	assert_object(first.atlas).is_not_null()
	assert_int(first.atlas.get_width()).is_equal(UiIcons.ATLAS_SIZE.x)
	assert_int(first.atlas.get_height()).is_equal(UiIcons.ATLAS_SIZE.y)
	for icon_value in range(UiIcons.Icon.size()):
		var icon: AtlasTexture = UiIcons.texture(icon_value)
		assert_object(icon.atlas).is_same(first.atlas)
		assert_float(icon.region.size.x).is_greater(300.0)
		assert_float(icon.region.size.y).is_greater(300.0)


func test_atlas_regions_cover_all_four_corners() -> void:
	var first: AtlasTexture = UiIcons.texture(UiIcons.Icon.FOCUS_SPADE)
	var last: AtlasTexture = UiIcons.texture(UiIcons.Icon.DIVIDER)
	assert_vector(first.region.position).is_equal(Vector2.ZERO)
	assert_vector(last.region.end).is_equal(Vector2(UiIcons.ATLAS_SIZE))
