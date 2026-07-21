class_name TableAiAnnouncement
extends RefCounted
## Bandeau court quand une IA ajuste son style (rare) ou formule une lecture adverse.


static func play(ctx: TableContext, announcement: Dictionary) -> void:
	if not ctx.is_active():
		return

	var player_index: int = announcement.get("player_index", -1)
	if player_index < 0:
		return

	var player_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, player_index)
	var target_index: int = announcement.get("target_player_index", -1)
	var target_name: String = ""
	if target_index >= 0:
		target_name = TableSeatDisplayMap.get_logical_display_name(ctx, target_index)

	var message := GameCopy.ai_strategy_message(
		player_name,
		announcement.get("reason_key", ""),
		target_name
	)
	var banner: Control = _create_banner(message)
	ctx.animation_layer.add_child(banner)
	banner.modulate.a = 0.0

	var fade_in: Tween = ctx.host.create_tween()
	fade_in.set_parallel(true)
	fade_in.tween_property(banner, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var panel: Control = banner.get_child(0) as Control
	if panel != null:
		UiOffsetAnim.enable_on(panel)
		fade_in.tween_property(panel, "offset_transform_scale", Vector2.ONE, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	if not ctx.is_active():
		_discard_banner(banner)
		return

	await ctx.host.get_tree().create_timer(TableAnimations.AI_STRATEGY_BANNER_VISIBLE_SEC).timeout
	if not ctx.is_active():
		_discard_banner(banner)
		return

	var exit_tween: Tween = ctx.host.create_tween()
	exit_tween.set_parallel(true)
	exit_tween.set_trans(Tween.TRANS_CUBIC)
	exit_tween.set_ease(Tween.EASE_IN)
	exit_tween.tween_property(
		banner,
		"position:y",
		banner.position.y + TableAnimations.AI_STRATEGY_BANNER_EXIT_OFFSET_Y,
		TableAnimations.AI_STRATEGY_BANNER_EXIT_SEC
	)
	exit_tween.tween_property(banner, "modulate:a", 0.0, TableAnimations.AI_STRATEGY_BANNER_EXIT_SEC)
	await exit_tween.finished
	_discard_banner(banner)


static func _create_banner(message: String) -> Control:
	var root := Control.new()
	root.name = "AiStrategyBanner"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280.0
	panel.offset_top = -40.0
	panel.offset_right = 280.0
	panel.offset_bottom = 40.0
	UiStyleFactory.apply_pixel_panel(
		panel,
		UiStyleFactory.pixel_banner_panel_style(Vector4(24, 14, 24, 14), 3, 0.94)
	)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(480.0, 0.0)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", UiPalette.CREAM)
	label.text = message

	panel.add_child(label)
	root.add_child(panel)
	UiOffsetAnim.prepare_hidden(panel)
	return root


static func _discard_banner(banner: Variant) -> void:
	if banner is Control and is_instance_valid(banner):
		(banner as Control).queue_free()
