extends GdUnitTestSuite
## Réactions rapides — ids, cooldown, icône procédurale.


func test_reaction_ids_valid_range() -> void:
	assert_bool(ReactionIds.is_valid(ReactionIds.Id.SMILE)).is_true()
	assert_bool(ReactionIds.is_valid(ReactionIds.Id.SUSPICIOUS)).is_true()
	assert_bool(ReactionIds.is_valid(-1)).is_false()
	assert_bool(ReactionIds.is_valid(99)).is_false()
	assert_int(ReactionIds.all_ids().size()).is_equal(4)


func test_reaction_icon_draws_without_error() -> void:
	var icon := ReactionIcon.new()
	auto_free(icon)
	add_child(icon)
	await get_tree().process_frame
	icon.reaction_id = ReactionIds.Id.TAUNT
	icon.queue_redraw()
	await get_tree().process_frame
	assert_int(icon.reaction_id).is_equal(ReactionIds.Id.TAUNT)


func test_config_emotes_default_enabled() -> void:
	assert_bool(ConfigService.get_emotes_enabled()).is_true()


func test_reaction_picker_icons_fit_inside_cells() -> void:
	var picker := ReactionPicker.new()
	auto_free(picker)
	add_child(picker)
	await get_tree().process_frame
	picker.set_open(true)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_bool(picker.assert_icons_fit_cells()).is_true()
	var palette: Control = picker.get_node("Palette") as Control
	assert_that(palette).is_not_null()
	var palette_rect: Rect2 = palette.get_global_rect()
	for cell: Button in picker._cells:
		var icon: ReactionIcon = cell.find_child("Icon", true, false) as ReactionIcon
		assert_that(icon).is_not_null()
		assert_bool(palette_rect.encloses(icon.get_global_rect())).is_true()
	## Alignement droite local : ne doit pas dépasser le toggle (évite clip viewport en jeu).
	assert_float(palette.position.x + palette.size.x).is_equal_approx(picker.size.x, 2.0)
