class_name TableAiThinking
extends RefCounted
## Indication visuelle courte quand l'IA « réfléchit » (chasse ou casse Lune).


static func play(ctx: TableContext, player_index: int, mode: AiPlayMode.Kind, visible_sec: float) -> void:
	if not ctx.is_active() or mode == AiPlayMode.Kind.MINIMIZE or visible_sec <= 0.0:
		return

	var seat: PlayerSeat = TableSeatDisplayMap.get_seat_node(ctx, player_index)
	var bubble: Control = _create_bubble(ctx, player_index, mode)
	ctx.animation_layer.add_child(bubble)
	bubble.modulate.a = 0.0

	var fade_in: Tween = ctx.host.create_tween()
	fade_in.set_parallel(true)
	fade_in.tween_property(bubble, "modulate:a", 1.0, 0.12)
	var panel: Control = bubble.get_child(0) as Control
	if panel != null:
		UiOffsetAnim.enable_on(panel)
		fade_in.tween_property(panel, "offset_transform_scale", Vector2.ONE, 0.12) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	if not ctx.is_active():
		_discard(bubble)
		return

	seat.play_hand_win_reaction()
	await ctx.host.get_tree().create_timer(visible_sec).timeout
	if not ctx.is_active():
		_discard(bubble)
		return

	var fade_out: Tween = ctx.host.create_tween()
	fade_out.tween_property(bubble, "modulate:a", 0.0, 0.15)
	await fade_out.finished
	_discard(bubble)


static func _create_bubble(ctx: TableContext, player_index: int, mode: AiPlayMode.Kind) -> Control:
	var root := Control.new()
	root.name = "AiThinkingBubble"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var seat: PlayerSeat = TableSeatDisplayMap.get_seat_node(ctx, player_index)
	var seat_center: Vector2 = seat.get_global_transform_with_canvas() * (seat.size / 2.0)

	var panel := PanelContainer.new()
	UiStyleFactory.apply_pixel_panel(
		panel,
		UiStyleFactory.pixel_banner_panel_style(Vector4(12, 8, 12, 8), 2, 0.94)
	)

	var label := Label.new()
	label.text = GameCopy.ai_thinking_label(mode)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", UiPalette.CREAM)
	panel.add_child(label)

	root.add_child(panel)
	UiOffsetAnim.prepare_hidden(panel)
	panel.global_position = seat_center + Vector2(-90.0, -72.0)
	return root


static func _discard(node: Control) -> void:
	if is_instance_valid(node):
		node.queue_free()
