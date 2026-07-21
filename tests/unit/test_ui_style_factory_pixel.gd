extends GdUnitTestSuite
## Pack C — StyleBoxFlat pixel (coins 0, bordure or).


func test_pixel_banner_panel_has_zero_corners() -> void:
	var style: StyleBoxFlat = UiStyleFactory.pixel_banner_panel_style()
	assert_int(style.corner_radius_top_left).is_equal(0)
	assert_int(style.corner_radius_top_right).is_equal(0)
	assert_int(style.border_width_left).is_equal(3)
	assert_that(style.border_color).is_equal(UiPalette.PANEL_BORDER)


func test_pixel_overlay_panel_style() -> void:
	var style: StyleBoxFlat = UiStyleFactory.pixel_overlay_panel_style()
	assert_int(style.corner_radius_bottom_left).is_equal(0)
	assert_int(style.border_width_top).is_equal(3)
	assert_int(style.shadow_size).is_greater(4)


func test_pixel_compact_panel_style() -> void:
	var style: StyleBoxFlat = UiStyleFactory.pixel_compact_panel_style()
	assert_int(style.corner_radius_top_left).is_equal(0)
	assert_int(style.border_width_right).is_equal(2)


func test_apply_pixel_panel_overrides_theme() -> void:
	var panel := PanelContainer.new()
	auto_free(panel)
	UiStyleFactory.apply_pixel_panel(panel)
	var style: StyleBox = panel.get_theme_stylebox("panel")
	assert_that(style).is_instanceof(StyleBoxFlat)
	assert_int((style as StyleBoxFlat).corner_radius_top_left).is_equal(0)


func test_menu_button_stack_panel_is_stronger() -> void:
	var style: StyleBoxFlat = UiStyleFactory.menu_button_stack_panel_style()
	assert_int(style.border_width_left).is_equal(3)
	assert_int(style.shadow_size).is_greater(5)
	assert_float(style.bg_color.a).is_greater(0.8)
