class_name MoonSuspicionManager
extends RefCounted
## Soupçon de Lune : déclaration humaine, alerte sociale, contre-jeu IA.


const BANNER_SCENE: PackedScene = preload("res://scenes/table/moon_suspicion_banner.tscn")

var _used_suspector_seats: Dictionary = {}
var _pending_events: Array[MoonSuspicionEvent] = []
var _hand_number: int = 1


static func is_moon_declarable(ctx: TableContext) -> bool:
	if ctx.match_manager == null:
		return false
	if ctx.match_manager.phase != MatchManager.Phase.PLAYING:
		return false
	return not ctx.match_manager.is_moon_busted_in_current_hand()


## Visible seulement après assez de plis (ou Cœurs défoncés) — évite le clutter début de manche.
static func should_show_button(ctx: TableContext) -> bool:
	if not is_moon_declarable(ctx) or ctx.match_manager == null:
		return false
	var rule_engine: RuleEngine = ctx.match_manager.rule_engine
	if rule_engine == null:
		return false
	if rule_engine.hearts_broken:
		return true
	return rule_engine.trick_number >= MoonSuspicion.MIN_TRICK_TO_BREAK


static func is_available(ctx: TableContext) -> bool:
	return should_show_button(ctx)


static func can_trigger(ctx: TableContext) -> bool:
	if not should_show_button(ctx) or ctx.match_manager == null:
		return false
	if ctx.turn_locked or not ctx.is_local_human_turn():
		return false
	if ctx.hot_seat_overlay != null and ctx.hot_seat_overlay.visible:
		return false
	var manager := _manager(ctx)
	if manager == null:
		return false
	return not manager._used_suspector_seats.get(ctx.get_local_human_seat(), false)


static func refresh_button(ctx: TableContext) -> void:
	if ctx.moon_suspicion_button == null:
		return
	var button_visible: bool = should_show_button(ctx)
	var enabled: bool = can_trigger(ctx)
	var animate_dismiss: bool = (
		not button_visible
		and ctx.match_manager != null
		and ctx.match_manager.phase == MatchManager.Phase.PLAYING
	)
	ctx.moon_suspicion_button.set_action_available(button_visible, enabled, animate_dismiss)


static func reset_for_match(ctx: TableContext) -> void:
	ctx.moon_suspicion_manager = MoonSuspicionManager.new()


static func on_new_hand(ctx: TableContext, hand_number: int) -> void:
	var manager := _manager(ctx)
	if manager == null:
		return
	manager._hand_number = hand_number
	manager._used_suspector_seats.clear()
	manager._pending_events.clear()
	if ctx.match_manager != null:
		ctx.match_manager.clear_human_declared_moon_suspect()
	if ctx.moon_suspicion_button != null:
		ctx.moon_suspicion_button.reset_for_new_hand()
	refresh_button(ctx)


static func on_button_pressed(ctx: TableContext) -> void:
	if not can_trigger(ctx):
		return
	var suspected_seat: int = await _show_picker(ctx)
	if suspected_seat < 0 or not ctx.is_active():
		return
	await submit_suspicion(ctx, ctx.get_local_human_seat(), suspected_seat)


static func submit_suspicion(ctx: TableContext, suspector_seat: int, suspected_seat: int) -> void:
	if not _validate_suspicion(ctx, suspector_seat, suspected_seat):
		return
	var manager := _manager(ctx)
	if manager == null:
		return
	manager._used_suspector_seats[suspector_seat] = true
	_apply_gameplay_suspect(ctx, suspected_seat)
	var event := _create_event(ctx, suspector_seat, suspected_seat)
	refresh_button(ctx)

	if ctx.is_online_client():
		NetworkMatchRelay.rpc_request_moon_suspicion.rpc_id(1, suspected_seat)
		return

	if ctx.is_online_host():
		await NetworkMatchRelay.broadcast_moon_suspicion_from_host(ctx, event)
		return

	await _dispatch_hot_seat(ctx, event)


static func apply_network_event(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	var manager := _manager(ctx)
	if manager == null:
		return
	manager._used_suspector_seats[event.suspector_seat] = true
	_apply_gameplay_suspect(ctx, event.suspected_seat)
	refresh_button(ctx)
	await play_alert(ctx, event)


static func flush_pending_alerts(ctx: TableContext) -> void:
	if not ctx.is_hot_seat_multi_human():
		return
	var manager := _manager(ctx)
	if manager == null:
		return
	var viewer_seat: int = ctx.get_local_human_seat()
	var remaining: Array[MoonSuspicionEvent] = []
	for event: MoonSuspicionEvent in manager._pending_events:
		if event.was_seen_by(viewer_seat):
			if not event.all_humans_seen(ctx.launch_config.get_human_seat_indices()):
				remaining.append(event)
			continue
		event.mark_seen_by(viewer_seat)
		await play_alert(ctx, event)
		if not event.all_humans_seen(ctx.launch_config.get_human_seat_indices()):
			remaining.append(event)
	manager._pending_events = remaining


static func play_alert(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	if not ctx.is_active():
		return
	ctx.turn_locked = true
	refresh_button(ctx)
	var banner: MoonSuspicionBanner = BANNER_SCENE.instantiate() as MoonSuspicionBanner
	var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
	if ui_layer != null:
		ui_layer.add_child(banner)
	else:
		ctx.animation_layer.add_child(banner)
	if not banner.is_node_ready():
		await banner.ready
	await banner.play(ctx, event)
	if is_instance_valid(banner):
		banner.queue_free()
	if ctx.is_active():
		ctx.unlock_turn()
		refresh_button(ctx)


static func validate_server(ctx: TableContext, suspector_seat: int, suspected_seat: int) -> bool:
	return _validate_suspicion(ctx, suspector_seat, suspected_seat)


static func _dispatch_hot_seat(ctx: TableContext, event: MoonSuspicionEvent) -> void:
	var manager := _manager(ctx)
	event.mark_seen_by(event.suspector_seat)
	manager._pending_events.append(event)
	if event.suspector_seat == ctx.get_local_human_seat():
		await play_alert(ctx, event)


static func _validate_suspicion(ctx: TableContext, suspector_seat: int, suspected_seat: int) -> bool:
	if not is_moon_declarable(ctx) or ctx.match_manager == null:
		return false
	if suspector_seat < 0 or suspected_seat < 0 or suspector_seat == suspected_seat:
		return false
	if suspector_seat != ctx.match_manager.current_player:
		return false
	if not ctx.is_online() and suspector_seat != ctx.get_local_human_seat():
		return false
	var manager := _manager(ctx)
	if manager == null or manager._used_suspector_seats.get(suspector_seat, false):
		return false
	return suspected_seat < HeartsRules.PLAYER_COUNT


static func _create_event(ctx: TableContext, suspector_seat: int, suspected_seat: int) -> MoonSuspicionEvent:
	var event := MoonSuspicionEvent.new()
	event.suspector_seat = suspector_seat
	event.suspected_seat = suspected_seat
	event.message_variant = randi_range(0, 4)
	var manager := _manager(ctx)
	event.hand_number = manager._hand_number if manager != null else 1
	return event


static func create_event_for_seats(
	ctx: TableContext,
	suspector_seat: int,
	suspected_seat: int
) -> MoonSuspicionEvent:
	return _create_event(ctx, suspector_seat, suspected_seat)


static func _show_picker(ctx: TableContext) -> int:
	var suspector_seat: int = ctx.get_local_human_seat()
	var result: Dictionary = {"seat": -1}
	var overlay := _build_picker_overlay(ctx, suspector_seat, result)
	var ui_layer: Node = ctx.host.get_node_or_null("UILayer")
	if ui_layer == null:
		overlay.queue_free()
		return -1
	ui_layer.add_child(overlay)
	await overlay.tree_exited
	return int(result.get("seat", -1))


static func _build_picker_overlay(ctx: TableContext, suspector_seat: int, result: Dictionary) -> Control:
	var root := Control.new()
	root.name = "MoonSuspicionPicker"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220.0
	panel.offset_top = -160.0
	panel.offset_right = 220.0
	panel.offset_bottom = 160.0
	UiStyleFactory.apply_pixel_panel(
		panel,
		UiStyleFactory.pixel_banner_panel_style(Vector4(16, 14, 16, 14), 3, 0.98)
	)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var title := Label.new()
	title.text = TranslationServer.translate(TableKeys.MOON_SUSPICION_PICKER_TITLE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)

	for seat_index in range(HeartsRules.PLAYER_COUNT):
		if seat_index == suspector_seat:
			continue
		var player_name: String = TableSeatDisplayMap.get_logical_display_name(ctx, seat_index)
		var btn := Button.new()
		btn.text = player_name
		btn.pressed.connect(func() -> void:
			result["seat"] = seat_index
			root.queue_free()
		)
		vbox.add_child(btn)

	var cancel_btn := Button.new()
	cancel_btn.text = TranslationServer.translate(TableKeys.MOON_SUSPICION_PICKER_CANCEL)
	cancel_btn.pressed.connect(root.queue_free)
	vbox.add_child(cancel_btn)

	panel.add_child(vbox)
	root.add_child(panel)

	dim.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			root.queue_free()
	)

	return root


static func _manager(ctx: TableContext) -> MoonSuspicionManager:
	return ctx.moon_suspicion_manager


static func _apply_gameplay_suspect(ctx: TableContext, suspected_seat: int) -> void:
	if ctx.match_manager == null or suspected_seat < 0:
		return
	ctx.match_manager.set_human_declared_moon_suspect(suspected_seat)
