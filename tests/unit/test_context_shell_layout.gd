extends GdUnitTestSuite
## Context Shell — calcul d’insets (phase a).


func test_bottom_bar_compact_on_narrow_viewport() -> void:
	var mode := ContextShellLayout.resolve_bottom_bar_mode(800.0, false, false)
	assert_int(mode).is_equal(ContextShellLayout.BottomBarMode.COMPACT)
	assert_float(ContextShellLayout.bottom_bar_height(mode)).is_equal(
		ContextShellLayout.BOTTOM_BAR_HEIGHT_COMPACT
	)


func test_bottom_bar_full_on_wide_viewport() -> void:
	var mode := ContextShellLayout.resolve_bottom_bar_mode(1280.0, false, false)
	assert_int(mode).is_equal(ContextShellLayout.BottomBarMode.FULL)


func test_bottom_bar_hidden_in_focus_or_preference() -> void:
	assert_int(
		ContextShellLayout.resolve_bottom_bar_mode(1280.0, true, false)
	).is_equal(ContextShellLayout.BottomBarMode.HIDDEN)
	assert_int(
		ContextShellLayout.resolve_bottom_bar_mode(1280.0, false, true)
	).is_equal(ContextShellLayout.BottomBarMode.HIDDEN)


func test_play_insets_default_no_bottom_slot() -> void:
	## Phase a : slot bottom inactif → pas d’inset bas (préserve la main).
	var insets: Vector4 = ContextShellLayout.play_insets(
		Vector2(1280, 720), true, false, false, false
	)
	assert_float(insets.z).is_equal(ContextShellLayout.SIDEBAR_WIDTH_OPEN)
	assert_float(insets.w).is_equal(0.0)


func test_play_insets_sidebar_and_bottom_when_slot_active() -> void:
	var insets: Vector4 = ContextShellLayout.play_insets(
		Vector2(1280, 720), true, false, false, true
	)
	assert_float(insets.z).is_equal(ContextShellLayout.SIDEBAR_WIDTH_OPEN)
	assert_float(insets.w).is_equal(ContextShellLayout.BOTTOM_BAR_HEIGHT_FULL)


func test_play_insets_focus_keeps_no_bottom_by_layout_helper() -> void:
	## Focus : caller ContextShellHost met sidebar à 0 ; layout helper masque bottom.
	var insets: Vector4 = ContextShellLayout.play_insets(
		Vector2(1280, 720), true, true, false, true
	)
	assert_float(insets.w).is_equal(0.0)


func test_apply_insets_preserves_centered_trick_area_size() -> void:
	## TrickArea : anchors 0.5/0.5, offsets ±165 / ±150 — ne pas écraser à 50 px.
	var base := Vector4(-165.0, -150.0, 165.0, 150.0)
	var insets := Vector4(0.0, 0.0, 280.0, 0.0)
	var next: Vector4 = ContextShellLayout.apply_insets_to_offsets(
		0.5, 0.5, 0.5, 0.5, base, insets
	)
	assert_float(next.z - next.x).is_equal(330.0)
	assert_float(next.w - next.y).is_equal(300.0)
	assert_float(next.x).is_equal(-305.0)
	assert_float(next.z).is_equal(25.0)


func test_apply_insets_full_rect_shrinks_right() -> void:
	var base := Vector4(0.0, 0.0, 0.0, 0.0)
	var insets := Vector4(0.0, 0.0, 280.0, 0.0)
	var next: Vector4 = ContextShellLayout.apply_insets_to_offsets(
		0.0, 0.0, 1.0, 1.0, base, insets
	)
	assert_float(next.x).is_equal(0.0)
	assert_float(next.z).is_equal(-280.0)


func test_apply_insets_bottom_anchored_hand_lifts_with_bottom_bar() -> void:
	var base := Vector4(0.0, -230.0, 0.0, 0.0)
	var insets := Vector4(0.0, 0.0, 0.0, 56.0)
	var next: Vector4 = ContextShellLayout.apply_insets_to_offsets(
		0.0, 1.0, 1.0, 1.0, base, insets
	)
	assert_float(next.y).is_equal(-286.0)
	assert_float(next.w).is_equal(-56.0)
	assert_float(next.z).is_equal(0.0)


func test_ui_layout_snapshot_roundtrip() -> void:
	var snap := UiLayoutSnapshot.new()
	snap.sidebar_open = true
	snap.shell_focus = false
	snap.user_hide_bottom_bar = true
	snap.bottom_bar_slot_active = false
	var restored := UiLayoutSnapshot.from_dict(snap.to_dict())
	assert_bool(restored.sidebar_open).is_true()
	assert_bool(restored.shell_focus).is_false()
	assert_bool(restored.user_hide_bottom_bar).is_true()
	assert_bool(restored.bottom_bar_slot_active).is_false()
