extends GdUnitTestSuite
## NinePatchButton — labels longs ne dépassent pas (fit + groupe uniforme).


const _BUTTON_SCENE: PackedScene = preload("res://scenes/menus/button_template.tscn")


func test_fit_to_label_grows_beyond_template_for_long_text() -> void:
	var button: NinePatchButton = auto_free(_BUTTON_SCENE.instantiate()) as NinePatchButton
	add_child(button)
	await get_tree().process_frame
	button.apply_button_size(Vector2i(192, 64))
	button.set_button_text("STATISTIK ZURÜCKSETZEN")
	assert_int(int(button.custom_minimum_size.x)).is_greater(192)
	assert_int(button.measure_required_width()).is_less_equal(int(button.custom_minimum_size.x))


func test_uniform_fit_group_uses_widest_label() -> void:
	var short_btn: NinePatchButton = auto_free(_BUTTON_SCENE.instantiate()) as NinePatchButton
	var long_btn: NinePatchButton = auto_free(_BUTTON_SCENE.instantiate()) as NinePatchButton
	add_child(short_btn)
	add_child(long_btn)
	await get_tree().process_frame
	short_btn.set_button_text("BACK")
	long_btn.set_button_text("REINICIAR ESTADÍSTICAS")
	NinePatchButton.uniform_fit_group([short_btn, long_btn])
	assert_int(int(short_btn.custom_minimum_size.x)).is_equal(int(long_btn.custom_minimum_size.x))
	assert_int(int(short_btn.custom_minimum_size.x)).is_greater_equal(long_btn.measure_required_width())


func test_snap_width_up_on_grid_8() -> void:
	assert_int(NinePatchButton.snap_width_up(193)).is_equal(200)
	assert_int(NinePatchButton.snap_width_up(192)).is_equal(192)
