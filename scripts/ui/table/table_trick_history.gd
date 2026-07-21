class_name TableTrickHistory
extends RefCounted
## Overlay consultatif des derniers plis (mémoire de table autorisée en solo).


const MAX_TRICKS_SHOWN: int = 10


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


static func open(ctx: TableContext) -> void:
	if not ctx.is_active() or ctx.match_manager == null:
		return
	var ui_layer: Node = ctx.host.get_node_or_null("UILayer")
	if ui_layer == null:
		return
	if ui_layer.get_node_or_null("TrickHistoryOverlay") != null:
		return

	var overlay := _create_overlay(ctx)
	ui_layer.add_child(overlay)


static func _create_overlay(ctx: TableContext) -> Control:
	var root := Control.new()
	root.name = "TrickHistoryOverlay"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -320.0
	panel.offset_top = -260.0
	panel.offset_right = 320.0
	panel.offset_bottom = 260.0
	UiStyleFactory.apply_pixel_panel(
		panel,
		UiStyleFactory.pixel_banner_panel_style(Vector4(20, 16, 20, 16), 3, 0.98)
	)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = _t(TableKeys.TRICK_HISTORY_TITLE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560.0, 380.0)
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.custom_minimum_size = Vector2(540.0, 0.0)
	body.text = _format_tricks(ctx)
	scroll.add_child(body)
	vbox.add_child(scroll)

	var close_btn := Button.new()
	close_btn.text = _t(CommonKeys.BACK)
	close_btn.pressed.connect(func() -> void: root.queue_free())
	vbox.add_child(close_btn)

	panel.add_child(vbox)
	root.add_child(panel)
	dim.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			root.queue_free()
	)
	return root


static func _format_tricks(ctx: TableContext) -> String:
	var tricks: Array[Dictionary] = ctx.match_manager.get_recent_tricks(MAX_TRICKS_SHOWN)
	if tricks.is_empty():
		return _t(TableKeys.TRICK_HISTORY_EMPTY)

	var lines: PackedStringArray = PackedStringArray()
	for trick: Dictionary in tricks:
		var trick_number: int = trick.get("trick_number", 0)
		var winner_index: int = trick.get("winner_index", -1)
		var winner_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, winner_index) if winner_index >= 0 else "?"
		var points: int = trick.get("points", 0)
		lines.append(
			_t(TableKeys.TRICK_HISTORY_LINE) % [trick_number, winner_name, points]
		)
		var plays: Array = trick.get("plays", [])
		for play: Dictionary in plays:
			var card: CardModel = play.get("card")
			if card == null:
				continue
			var player_index: int = play.get("player_index", -1)
			var player_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, player_index) if player_index >= 0 else "?"
			lines.append("  • %s : %s" % [player_name, card._to_string()])
		lines.append("")
	return "\n".join(lines)
