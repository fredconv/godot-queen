class_name TableHandStart
extends RefCounted
## Bandeau « la partie / la manche commence » après la distribution des cartes.


static func play(ctx: TableContext, is_first_hand_of_match: bool) -> void:
	if not ctx.is_active():
		return

	var banner: Control = _create_banner(ctx, is_first_hand_of_match)
	ctx.animation_layer.add_child(banner)
	banner.modulate.a = 0.0

	var fade_in: Tween = ctx.host.create_tween()
	fade_in.tween_property(banner, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	if not ctx.is_active():
		_discard_banner(banner)
		return

	await ctx.host.get_tree().create_timer(TableAnimations.HAND_START_BANNER_VISIBLE_SEC).timeout
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
		banner.position.y + TableAnimations.HAND_START_BANNER_EXIT_OFFSET_Y,
		TableAnimations.HAND_START_BANNER_EXIT_SEC
	)
	exit_tween.tween_property(banner, "modulate:a", 0.0, TableAnimations.HAND_START_BANNER_EXIT_SEC)
	await exit_tween.finished
	_discard_banner(banner)


static func _create_banner(ctx: TableContext, is_first_hand_of_match: bool) -> Control:
	var root := Control.new()
	root.name = "HandStartBanner"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220.0
	panel.offset_top = -36.0
	panel.offset_right = 220.0
	panel.offset_bottom = 36.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.129, 0.129, 0.157, 0.94)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.831, 0.686, 0.216, 1.0)
	panel_style.content_margin_left = 24.0
	panel_style.content_margin_top = 16.0
	panel_style.content_margin_right = 24.0
	panel_style.content_margin_bottom = 16.0
	panel.add_theme_stylebox_override("panel", panel_style)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.961, 0.941, 0.902, 1.0))
	var message_key: String = (
		TableKeys.MATCH_START_BANNER if is_first_hand_of_match else TableKeys.HAND_START_BANNER
	)
	label.text = TranslationServer.translate(message_key)

	panel.add_child(label)
	root.add_child(panel)
	return root


static func _discard_banner(banner: Variant) -> void:
	if banner is Control and is_instance_valid(banner):
		(banner as Control).queue_free()
