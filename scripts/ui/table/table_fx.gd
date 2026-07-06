class_name TableFx
extends RefCounted
## Effets visuels de la table : thème, indicateur de couleur, pétales, bullet
## time et super attaque Dame de Pique.


static func apply_table_theme(ctx: TableContext) -> void:
	TableThemePaths.apply_to_nodes(
		ctx.background_color,
		ctx.background_texture,
		ConfigService.get_table_theme()
	)


static func setup(ctx: TableContext) -> void:
	_setup_lead_suit_indicator(ctx)
	_setup_victory_petals(ctx)
	_setup_bullet_time(ctx)
	_setup_queen_burst(ctx)


static func on_exit(ctx: TableContext) -> void:
	if ctx.bullet_time_camera:
		ctx.bullet_time_camera.enabled = false
	if ctx.bullet_time_dim:
		ctx.bullet_time_dim.visible = false


static func refresh_lead_suit_indicator(ctx: TableContext) -> void:
	if ctx.lead_suit_indicator == null or ctx.match_manager == null:
		return
	var panel: Control = ctx.lead_suit_indicator.get_parent()
	_sync_lead_suit_indicator_position(ctx, panel)
	var trick_manager: TrickManager = ctx.match_manager.trick_manager
	if trick_manager.played_count() == 0 or trick_manager.lead_suit < 0:
		panel.visible = false
		return
	if trick_manager.played_count() >= 2:
		return
	panel.visible = true
	panel.modulate.a = 1.0
	ctx.lead_suit_indicator.text = Suit.to_lead_indicator_text(trick_manager.lead_suit)
	match trick_manager.lead_suit:
		Suit.HEARTS:
			ctx.lead_suit_indicator.add_theme_color_override("font_color", Color(0.95, 0.35, 0.4))
		Suit.DIAMONDS:
			ctx.lead_suit_indicator.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		Suit.CLUBS:
			ctx.lead_suit_indicator.add_theme_color_override("font_color", Color(0.85, 0.95, 0.85))
		Suit.SPADES:
			ctx.lead_suit_indicator.add_theme_color_override("font_color", Color(0.88, 0.9, 1.0))
		_:
			ctx.lead_suit_indicator.add_theme_color_override("font_color", Color.WHITE)


static func _setup_lead_suit_indicator(ctx: TableContext) -> void:
	var panel := PanelContainer.new()
	panel.name = "LeadSuitIndicator"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 50
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.08, 0.82)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 6.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 6.0
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	ctx.lead_suit_indicator = Label.new()
	ctx.lead_suit_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctx.lead_suit_indicator.add_theme_font_size_override("font_size", LocaleFonts.LEAD_SUIT_FONT_SIZE)
	panel.add_child(ctx.lead_suit_indicator)
	ctx.animation_layer.add_child(panel)
	_sync_lead_suit_indicator_position(ctx, panel)


static func fade_lead_suit_indicator(ctx: TableContext, duration_sec: float) -> void:
	if ctx.lead_suit_indicator == null:
		return
	var panel: Control = ctx.lead_suit_indicator.get_parent()
	if panel == null or not panel.visible:
		return
	var tween: Tween = ctx.host.create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, duration_sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(
		func() -> void:
			if is_instance_valid(panel):
				panel.visible = false
				panel.modulate.a = 1.0,
		CONNECT_ONE_SHOT
	)


static func _sync_lead_suit_indicator_position(ctx: TableContext, panel: Control) -> void:
	if ctx.trick_area == null or ctx.animation_layer == null or panel == null:
		return
	var trick_center_global: Vector2 = ctx.trick_area.get_global_rect().get_center()
	var panel_size: Vector2 = panel.size
	if panel_size == Vector2.ZERO:
		panel_size = Vector2(260.0, 36.0)
	panel.global_position = trick_center_global - panel_size / 2.0


static func _setup_victory_petals(ctx: TableContext) -> void:
	ctx.victory_petals = VictoryPetals.new()
	ctx.victory_petals.name = "VictoryPetals"
	ctx.victory_petals.set_anchors_preset(Control.PRESET_FULL_RECT)
	ctx.victory_petals.z_index = 5
	ctx.host.add_child(ctx.victory_petals)


static func _setup_bullet_time(ctx: TableContext) -> void:
	ctx.bullet_time_camera = Camera2D.new()
	ctx.bullet_time_camera.name = "BulletTimeCamera"
	ctx.bullet_time_camera.enabled = false
	ctx.host.add_child(ctx.bullet_time_camera)

	var dim_layer := CanvasLayer.new()
	dim_layer.name = "BulletTimeDimLayer"
	dim_layer.layer = 5
	ctx.bullet_time_dim = ColorRect.new()
	ctx.bullet_time_dim.name = "BulletTimeDim"
	ctx.bullet_time_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	ctx.bullet_time_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctx.bullet_time_dim.color = Color(0.02, 0.03, 0.08, 1.0)
	ctx.bullet_time_dim.modulate.a = 0.0
	ctx.bullet_time_dim.visible = false
	dim_layer.add_child(ctx.bullet_time_dim)
	ctx.host.add_child(dim_layer)


static func _setup_queen_burst(ctx: TableContext) -> void:
	var burst_layer := CanvasLayer.new()
	burst_layer.name = "QueenBurstLayer"
	burst_layer.layer = 100
	ctx.queen_avatar_burst = QueenOfSpadesAvatarBurst.new()
	ctx.queen_avatar_burst.name = "QueenOfSpadesAvatarBurst"
	burst_layer.add_child(ctx.queen_avatar_burst)
	ctx.host.add_child(burst_layer)
