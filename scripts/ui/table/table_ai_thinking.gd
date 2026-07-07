class_name TableAiThinking
extends RefCounted
## Indication visuelle courte quand l'IA « réfléchit » (chasse ou casse Lune).


static func play(ctx: TableContext, player_index: int, mode: AiPlayMode.Kind, visible_sec: float) -> void:
	if not ctx.is_active() or mode == AiPlayMode.Kind.MINIMIZE or visible_sec <= 0.0:
		return

	var seat: PlayerSeat = ctx.seats[player_index]
	var bubble: Control = _create_bubble(ctx, player_index, mode)
	ctx.animation_layer.add_child(bubble)
	bubble.modulate.a = 0.0

	var fade_in: Tween = ctx.host.create_tween()
	fade_in.tween_property(bubble, "modulate:a", 1.0, 0.12)
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

	var seat: PlayerSeat = ctx.seats[player_index]
	var seat_center: Vector2 = seat.get_global_transform_with_canvas() * (seat.size / 2.0)

	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.129, 0.129, 0.157, 0.94)
	panel_style.border_color = Color(0.831, 0.686, 0.216, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", panel_style)

	var label := Label.new()
	label.text = GameCopy.ai_thinking_label(mode)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.961, 0.941, 0.902, 1.0))
	panel.add_child(label)

	root.add_child(panel)
	panel.global_position = seat_center + Vector2(-90.0, -72.0)
	return root


static func _discard(node: Control) -> void:
	if is_instance_valid(node):
		node.queue_free()
