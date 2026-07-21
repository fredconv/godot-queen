class_name TableContextShell
extends RefCounted
## Phase b — coordination table ↔ ContextShell (toggle, dock scoreboard, Escape).
## Pas d’anim TogglePanel ici (phase c) ; pas de bottom bar peuplée (phase d).


const TOGGLE_NAME: StringName = &"ContextShellToggle"
const SIDEBAR_CHROME_NAME: StringName = &"RoyalSidebar"
const BOTTOM_CHROME_NAME: StringName = &"RoyalBottomBar"
const SCOREBOARD_MARGIN: float = 12.0
const RECENT_TRICKS_LIMIT: int = 4
const TRICK_CARD_SIZE: Vector2 = Vector2(40.0, 57.0)
const _META_BRIDGE: StringName = &"ddp_table_shell_bridge"
const _META_TRICK_REFRESH: StringName = &"ddp_table_shell_trick_refresh"
const _META_CARD_COUNTS_EXPANDED: StringName = &"ddp_card_counts_expanded"
const _META_LAYOUT_HAND_SYNC: StringName = &"ddp_layout_hand_sync"


static func setup(ctx: TableContext, shell: ContextShellHost) -> void:
	if ctx == null or shell == null or ctx.host == null:
		return
	ctx.context_shell = shell
	if not shell.has_meta(_META_BRIDGE):
		shell.sidebar_open_changed.connect(_on_sidebar_signal.bind(ctx))
		shell.set_meta(_META_BRIDGE, true)
	if not shell.has_meta(_META_LAYOUT_HAND_SYNC):
		shell.layout_applied.connect(_on_shell_layout_applied.bind(ctx))
		shell.set_meta(_META_LAYOUT_HAND_SYNC, true)
	if not ctx.host.has_meta(_META_TRICK_REFRESH):
		GameEvents.trick_resolved.connect(_on_trick_resolved.bind(ctx))
		GameEvents.card_played.connect(_on_card_played.bind(ctx))
		GameEvents.score_updated.connect(_on_score_updated.bind(ctx))
		GameEvents.match_started.connect(_on_match_started.bind(ctx))
		GameEvents.match_ended.connect(_on_match_ended.bind(ctx))
		ctx.host.set_meta(_META_TRICK_REFRESH, true)
	_ensure_toggle_button(ctx, shell)
	_ensure_sidebar_chrome(ctx, shell)
	_ensure_bottom_bar(ctx, shell)
	_capture_scoreboard_home(ctx)
	_sync_scoreboard_dock(ctx, shell.sidebar_open)
	_refresh_toggle_visual(ctx, shell.sidebar_open)
	_position_moon_button(ctx, shell.sidebar_open)
	refresh_bottom_state(ctx)


static func toggle_sidebar(ctx: TableContext) -> void:
	if ctx == null or ctx.context_shell == null:
		return
	ctx.context_shell.toggle_sidebar()


static func open_tab(ctx: TableContext, tab_name: String) -> void:
	if ctx == null or ctx.context_shell == null:
		return
	ctx.context_shell.set_sidebar_open(true)
	var chrome: Control = ctx.context_shell.get_sidebar_content_root().get_node_or_null(String(SIDEBAR_CHROME_NAME)) as Control
	if chrome == null:
		return
	var title: Label = chrome.get_node_or_null("Margin/Layout/Title") as Label
	var help: Label = chrome.get_node_or_null("Margin/Layout/Scroll/ScrollBody/HelpText") as Label
	var tricks_list: VBoxContainer = chrome.get_node_or_null("Margin/Layout/Scroll/ScrollBody/TricksList") as VBoxContainer
	var cards_dashboard: VBoxContainer = chrome.get_node_or_null("Margin/Layout/Scroll/ScrollBody/CardsDashboard") as VBoxContainer
	var help_dashboard: VBoxContainer = chrome.get_node_or_null("Margin/Layout/Scroll/ScrollBody/HelpDashboard") as VBoxContainer
	var scroll: ScrollContainer = chrome.get_node_or_null("Margin/Layout/Scroll") as ScrollContainer
	var previous_tab: String = String(chrome.get_meta("active_tab", ""))
	chrome.set_meta("active_tab", tab_name)
	if scroll != null and previous_tab != tab_name:
		scroll.scroll_vertical = 0
	var board: Control = chrome.get_node_or_null("Margin/Layout/Content/MatchScoreboard") as Control
	var content: Control = chrome.get_node_or_null("Margin/Layout/Content") as Control
	if title != null:
		title.text = tab_name
	if board != null:
		board.visible = tab_name == "POINTS"
	if content != null:
		content.visible = tab_name == "POINTS"
	if tricks_list != null:
		tricks_list.visible = tab_name == "PLIS"
	if cards_dashboard != null:
		cards_dashboard.visible = tab_name == "CARTES"
	if help_dashboard != null:
		help_dashboard.visible = tab_name == "AIDE"
	if help != null:
		help.visible = false
		match tab_name:
			"PLIS":
				_populate_recent_tricks(ctx, tricks_list, help)
			"CARTES": _populate_cards_dashboard(ctx, cards_dashboard)
			"AIDE": _populate_help_dashboard(ctx, help_dashboard)
			_: help.text = "INFORMATIONS DE LA PARTIE"
	var tabs: Node = chrome.get_node_or_null("Margin/Layout/Tabs")
	if tabs != null:
		for child: Node in tabs.get_children():
			if child is Button:
				(child as Button).button_pressed = (child as Button).text == tab_name
	refresh_bottom_state(ctx)


static func _on_trick_resolved(_winner_id: int, _points: int, ctx: TableContext) -> void:
	refresh_bottom_state(ctx)
	_refresh_active_tab(ctx)


static func _on_card_played(_player_id: int, _card: CardModel, ctx: TableContext) -> void:
	refresh_bottom_state(ctx)
	_refresh_active_tab(ctx)


static func _on_score_updated(_player_id: int, _score: int, ctx: TableContext) -> void:
	refresh_bottom_state(ctx)
	_refresh_active_tab(ctx)


static func _on_match_started(ctx: TableContext) -> void:
	refresh_bottom_state(ctx)
	_refresh_active_tab(ctx)


static func _on_match_ended(_winner_id: int, ctx: TableContext) -> void:
	refresh_bottom_state(ctx)
	_refresh_active_tab(ctx)


static func _refresh_active_tab(ctx: TableContext) -> void:
	if ctx == null or ctx.host == null or not ctx.is_active() or ctx.context_shell == null:
		return
	if not ctx.context_shell.sidebar_open:
		return
	var chrome: Control = ctx.context_shell.get_sidebar_content_root().get_node_or_null(String(SIDEBAR_CHROME_NAME)) as Control
	if chrome == null:
		return
	var active_tab: String = String(chrome.get_meta("active_tab", "POINTS"))
	open_tab(ctx, active_tab)


static func refresh_bottom_state(ctx: TableContext) -> void:
	if ctx == null or ctx.context_shell == null or ctx.match_manager == null:
		return
	var bar: Control = ctx.context_shell.get_bottom_bar_content_root().get_node_or_null(String(BOTTOM_CHROME_NAME)) as Control
	if bar == null:
		return
	var state: HBoxContainer = bar.get_node_or_null("Margin/Row/State") as HBoxContainer
	if state == null:
		return
	var lead: int = ctx.match_manager.trick_manager.lead_suit
	var lead_text := "Libre choix" if lead < 0 else "%s demandé" % Suit.to_display_name(lead)
	var hearts_text := "Cœurs brisés" if ctx.match_manager.rule_engine.hearts_broken else "Cœurs non brisés"
	var local_seat: int = ctx.get_local_human_seat()
	var points: int = ctx.match_manager.get_current_hand_raw_scores()[local_seat]
	var lead_icon: TextureRect = state.get_node("LeadIcon") as TextureRect
	lead_icon.visible = lead >= 0
	lead_icon.texture = SuitIconCatalog.texture(lead) if lead >= 0 else null
	(state.get_node("LeadLabel") as Label).text = lead_text
	(state.get_node("HeartsLabel") as Label).text = hearts_text
	(state.get_node("PointsLabel") as Label).text = "%d point%s" % [points, "s" if points != 1 else ""]


static func _make_named_bottom_label(node_name: String, text: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", UiPalette.CREAM)
	label.add_theme_font_size_override("font_size", 8)
	return label


static func _format_recent_tricks(ctx: TableContext) -> String:
	if ctx.match_manager == null:
		return "HISTORIQUE INDISPONIBLE"
	var tricks: Array[Dictionary] = ctx.match_manager.get_recent_tricks(8)
	if tricks.is_empty():
		return "AUCUN PLI TERMINÉ\n\nLe dernier pli et son vainqueur apparaîtront ici."
	var lines := PackedStringArray()
	for trick: Dictionary in tricks:
		var winner: int = trick.get("winner_index", -1)
		var winner_name := TableSeatDisplayMap.get_logical_display_name(ctx, winner) if winner >= 0 else "?"
		lines.append("PLI %d  ·  %d pts  ·  %s" % [int(trick.get("trick_number", 0)), int(trick.get("points", 0)), winner_name])
		var cards := PackedStringArray()
		for play: Dictionary in trick.get("plays", []):
			var card: CardModel = play.get("card")
			if card != null:
				cards.append(card._to_string())
		lines.append("  " + "   ".join(cards))
		lines.append("")
	return "\n".join(lines)


static func _populate_recent_tricks(
	ctx: TableContext,
	list: VBoxContainer,
	empty_label: Label
) -> void:
	if list == null or empty_label == null:
		return
	for child: Node in list.get_children():
		child.queue_free()
	var tricks: Array[Dictionary] = []
	if ctx.match_manager != null:
		tricks = ctx.match_manager.get_recent_tricks(RECENT_TRICKS_LIMIT)
	tricks.reverse()
	empty_label.visible = tricks.is_empty()
	empty_label.text = "AUCUN PLI TERMINÉ\n\nLes quatre cartes du dernier pli apparaîtront ici."
	if tricks.is_empty():
		return
	for display_index: int in tricks.size():
		list.add_child(_build_trick_history_row(ctx, tricks[display_index], display_index + 1))


static func _build_trick_history_row(ctx: TableContext, trick: Dictionary, display_rank: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 110.0)
	panel.theme_type_variation = &"ScorePanel"
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var order_label := Label.new()
	order_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order_label.text = "%d · %s" % [display_rank, "PLUS RÉCENT" if display_rank == 1 else "PLI %d" % int(trick.get("trick_number", 0))]
	order_label.add_theme_font_size_override("font_size", 7)
	order_label.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
	header.add_child(order_label)
	var points := Label.new()
	points.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	points.text = "+%d pt%s" % [int(trick.get("points", 0)), "s" if int(trick.get("points", 0)) != 1 else ""]
	points.add_theme_font_size_override("font_size", 7)
	points.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
	header.add_child(points)
	var cards_row := HBoxContainer.new()
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.add_theme_constant_override("separation", 5)
	column.add_child(cards_row)
	var winner_index: int = int(trick.get("winner_index", -1))
	var plays: Array = (trick.get("plays", []) as Array).duplicate()
	plays.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("player_index", 0)) < int(b.get("player_index", 0))
	)
	for play: Dictionary in plays:
		var card: CardModel = play.get("card") as CardModel
		if card == null:
			continue
		cards_row.add_child(_build_history_card(card, int(play.get("player_index", -1)) == winner_index))
	var winner := Label.new()
	winner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner.text = "Gagné par %s" % TableSeatDisplayMap.get_logical_display_name(ctx, winner_index)
	winner.add_theme_font_size_override("font_size", 7)
	winner.add_theme_color_override("font_color", UiPalette.CREAM)
	column.add_child(winner)
	return panel


static func _build_history_card(card: CardModel, is_winner: bool) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = TRICK_CARD_SIZE
	var texture := TextureRect.new()
	texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture.texture = CardTexturePaths.get_front_texture(card)
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(texture)
	if is_winner:
		var rim := Panel.new()
		rim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.draw_center = false
		style.border_color = UiPalette.GOLD_BRIGHT
		style.set_border_width_all(2)
		rim.add_theme_stylebox_override("panel", style)
		holder.add_child(rim)
	return holder


static func _format_card_state(ctx: TableContext) -> String:
	if ctx.match_manager == null:
		return "CARTES INDISPONIBLES"
	var played := {Suit.CLUBS: 0, Suit.DIAMONDS: 0, Suit.SPADES: 0, Suit.HEARTS: 0}
	var queen_played := false
	for trick: Dictionary in ctx.match_manager.get_recent_tricks(13):
		for play: Dictionary in trick.get("plays", []):
			var card: CardModel = play.get("card")
			if card == null:
				continue
			played[card.suit] += 1
			queen_played = queen_played or (card.suit == Suit.SPADES and card.rank == Rank.QUEEN)
	var lines := PackedStringArray(["CARTES DÉJÀ SORTIES", ""])
	for suit: int in Suit.ALL:
		lines.append("%s %-10s  %2d / 13" % [Suit.to_symbol(suit), Suit.to_display_name(suit), int(played[suit])])
	lines.append("")
	lines.append("Dame de Pique : %s" % ("jouée" if queen_played else "encore en jeu"))
	lines.append("Cœurs : %s" % ("brisés" if ctx.match_manager.rule_engine.hearts_broken else "non brisés"))
	return "\n".join(lines)


static func _populate_cards_dashboard(ctx: TableContext, dashboard: VBoxContainer) -> void:
	if dashboard == null:
		return
	for child: Node in dashboard.get_children():
		child.queue_free()
	if ctx.match_manager == null:
		return
	var raw_plays: Array[Dictionary] = []
	for trick: Dictionary in ctx.match_manager.get_recent_tricks(13):
		for play: Dictionary in trick.get("plays", []):
			raw_plays.append(play)
	for play: Dictionary in ctx.match_manager.trick_manager.get_plays():
		raw_plays.append(play)
	var all_plays: Array[Dictionary] = _unique_card_plays(raw_plays)
	var counts: Array[int] = [0, 0, 0, 0]
	for play: Dictionary in all_plays:
		var played_card: CardModel = play.get("card") as CardModel
		if played_card != null:
			counts[played_card.suit] = mini(13, counts[played_card.suit] + 1)
	dashboard.add_child(_build_cards_played_section(ctx, counts))
	dashboard.add_child(_build_key_cards_section(ctx, all_plays))
	dashboard.add_child(_build_hearts_state_section(ctx.match_manager.rule_engine.hearts_broken))
	dashboard.add_child(_build_latest_cards_section(all_plays))


static func _make_dashboard_section(title_text: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"ScorePanel"
	var margin := MarginContainer.new()
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
	column.add_child(title)
	return {"panel": panel, "column": column}


static func _unique_card_plays(plays: Array[Dictionary]) -> Array[Dictionary]:
	var unique: Array[Dictionary] = []
	var seen: Dictionary = {}
	for play: Dictionary in plays:
		var card: CardModel = play.get("card") as CardModel
		if card == null:
			continue
		var key := "%d:%d" % [card.suit, card.rank]
		if seen.has(key):
			continue
		seen[key] = true
		unique.append(play)
	return unique


static func _build_cards_played_section(ctx: TableContext, counts: Array[int]) -> Control:
	var section := _make_dashboard_section("CARTES JOUÉES")
	var column: VBoxContainer = section["column"]
	var expanded: bool = bool(ctx.host.get_meta(_META_CARD_COUNTS_EXPANDED, false))
	var toggle := Button.new()
	toggle.text = "MASQUER LE DÉCOMPTE" if expanded else "AFFICHER LE DÉCOMPTE"
	toggle.theme_type_variation = &"HudNavButton"
	toggle.add_theme_font_size_override("font_size", 6)
	toggle.tooltip_text = "Aide stratégique optionnelle"
	column.add_child(toggle)
	var details := VBoxContainer.new()
	details.add_theme_constant_override("separation", 3)
	details.visible = expanded
	column.add_child(details)
	toggle.pressed.connect(_toggle_card_counts.bind(ctx, details, toggle))
	for suit: int in [Suit.CLUBS, Suit.DIAMONDS, Suit.SPADES, Suit.HEARTS]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		details.add_child(row)
		row.add_child(SuitIconCatalog.make_rect(suit, Vector2(22, 22)))
		var name := Label.new()
		name.custom_minimum_size = Vector2(48, 0)
		name.text = Suit.to_display_name(suit)
		name.add_theme_font_size_override("font_size", 7)
		row.add_child(name)
		var count := Label.new()
		count.custom_minimum_size = Vector2(28, 0)
		count.text = "%d/13" % counts[suit]
		count.add_theme_font_size_override("font_size", 7)
		row.add_child(count)
		var gauge := HBoxContainer.new()
		gauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gauge.add_theme_constant_override("separation", 1)
		row.add_child(gauge)
		for segment_index: int in 13:
			var segment := ColorRect.new()
			segment.custom_minimum_size = Vector2(5, 7)
			segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			segment.color = _suit_ui_color(suit) if segment_index < counts[suit] else Color(0.3, 0.31, 0.32, 0.72)
			gauge.add_child(segment)
	return section["panel"]


static func _toggle_card_counts(ctx: TableContext, details: VBoxContainer, toggle: Button) -> void:
	var expanded := not details.visible
	details.visible = expanded
	toggle.text = "MASQUER LE DÉCOMPTE" if expanded else "AFFICHER LE DÉCOMPTE"
	ctx.host.set_meta(_META_CARD_COUNTS_EXPANDED, expanded)


static func _build_key_cards_section(ctx: TableContext, all_plays: Array[Dictionary]) -> Control:
	var section := _make_dashboard_section("CARTES CLÉS")
	var column: VBoxContainer = section["column"]
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	var queen := CardModel.new(Suit.SPADES, Rank.QUEEN)
	row.add_child(_build_history_card(queen, false))
	var played_by: int = -1
	for play: Dictionary in all_plays:
		var card: CardModel = play.get("card") as CardModel
		if card != null and card.suit == Suit.SPADES and card.rank == Rank.QUEEN:
			played_by = int(play.get("player_index", -1))
			break
	var state := Label.new()
	state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state.text = "DAME DE PIQUE\nEN JEU" if played_by < 0 else "DAME DE PIQUE\nJOUÉE PAR %s" % TableSeatDisplayMap.get_logical_display_name(ctx, played_by)
	state.add_theme_font_size_override("font_size", 7)
	state.add_theme_color_override("font_color", UiPalette.CREAM if played_by < 0 else UiPalette.GOLD_BRIGHT)
	row.add_child(state)
	return section["panel"]


static func _build_hearts_state_section(hearts_broken: bool) -> Control:
	var section := _make_dashboard_section("ÉTAT DE LA MANCHE")
	var column: VBoxContainer = section["column"]
	var state := Label.new()
	state.text = "%s  ♥  %s" % ["OUVERT" if hearts_broken else "FERMÉ", "CŒURS BRISÉS" if hearts_broken else "CŒURS NON BRISÉS"]
	state.add_theme_font_size_override("font_size", 8)
	state.add_theme_color_override("font_color", Color(1.0, 0.32, 0.38, 1.0) if hearts_broken else Color(0.72, 0.72, 0.68, 1.0))
	column.add_child(state)
	return section["panel"]


static func _build_latest_cards_section(all_plays: Array[Dictionary]) -> Control:
	var section := _make_dashboard_section("DERNIÈRES CARTES")
	var column: VBoxContainer = section["column"]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 7)
	column.add_child(row)
	var start: int = maxi(0, all_plays.size() - 4)
	for index: int in range(start, all_plays.size()):
		var card: CardModel = all_plays[index].get("card") as CardModel
		if card != null:
			row.add_child(_build_history_card(card, false))
	if row.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "Aucune carte jouée"
		empty.add_theme_font_size_override("font_size", 7)
		row.add_child(empty)
	return section["panel"]


static func _suit_ui_color(suit: int) -> Color:
	return Color(0.98, 0.3, 0.34, 1.0) if suit in [Suit.HEARTS, Suit.DIAMONDS] else Color(0.78, 0.88, 0.9, 1.0)


static func _format_context_help(ctx: TableContext) -> String:
	if ctx.match_manager == null:
		return "AIDE CONTEXTUELLE\n\nLa partie se prépare."
	if not ctx.is_local_human_turn():
		return "AIDE CONTEXTUELLE\n\nObservez le pli : un adversaire réfléchit."
	var lead: int = ctx.match_manager.trick_manager.lead_suit
	if lead >= 0:
		return "AIDE CONTEXTUELLE\n\nVous devez suivre %s si vous possédez cette couleur. Sinon, vous pouvez défausser une autre carte." % Suit.to_display_name(lead)
	if ctx.match_manager.rule_engine.trick_number == 1:
		return "AIDE CONTEXTUELLE\n\nLe 2 de Trèfle commence obligatoirement la partie."
	return "AIDE CONTEXTUELLE\n\nVous ouvrez le pli. Choisissez une couleur autorisée."


static func _populate_help_dashboard(ctx: TableContext, dashboard: VBoxContainer) -> void:
	if dashboard == null:
		return
	for child: Node in dashboard.get_children():
		child.queue_free()
	var state: Dictionary = TableContextHelpState.build(ctx)
	var action_section := _make_dashboard_section(String(state.get("title", "AIDE CONTEXTUELLE")))
	var action_column: VBoxContainer = action_section["column"]
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	action_column.add_child(action_row)
	var lead: int = int(state.get("lead_suit", -1))
	if lead >= 0:
		action_row.add_child(SuitIconCatalog.make_rect(lead, Vector2(42, 42)))
	else:
		var hint_icon := Label.new()
		hint_icon.custom_minimum_size = Vector2(42, 42)
		hint_icon.text = "?"
		hint_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_icon.add_theme_font_size_override("font_size", 20)
		hint_icon.add_theme_color_override("font_color", UiPalette.GOLD_BRIGHT)
		action_row.add_child(hint_icon)
	var instruction := Label.new()
	instruction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction.text = String(state.get("instruction", ""))
	instruction.add_theme_font_size_override("font_size", 7)
	instruction.add_theme_color_override("font_color", UiPalette.CREAM)
	action_row.add_child(instruction)
	dashboard.add_child(action_section["panel"])

	var example_section := _make_dashboard_section("EXEMPLE")
	var example_column: VBoxContainer = example_section["column"]
	var example_row := HBoxContainer.new()
	example_row.add_theme_constant_override("separation", 10)
	example_column.add_child(example_row)
	var legal_group := VBoxContainer.new()
	legal_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var legal_title := Label.new()
	legal_title.text = "À JOUER"
	legal_title.add_theme_font_size_override("font_size", 7)
	legal_title.add_theme_color_override("font_color", Color(0.45, 0.92, 0.48, 1.0))
	legal_group.add_child(legal_title)
	var legal_row := HBoxContainer.new()
	legal_row.add_theme_constant_override("separation", 4)
	legal_group.add_child(legal_row)
	for card: CardModel in state.get("legal_cards", []):
		legal_row.add_child(_build_example_card(card, true))
	if legal_row.get_child_count() == 0:
		var no_card := Label.new()
		no_card.text = "En attente"
		no_card.add_theme_font_size_override("font_size", 7)
		legal_row.add_child(no_card)
	example_row.add_child(legal_group)
	var illegal_group := VBoxContainer.new()
	var illegal_title := Label.new()
	illegal_title.text = "IMPOSSIBLE"
	illegal_title.add_theme_font_size_override("font_size", 7)
	illegal_title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.32, 1.0))
	illegal_group.add_child(illegal_title)
	var illegal: CardModel = state.get("illegal_card") as CardModel
	if illegal != null:
		illegal_group.add_child(_build_example_card(illegal, false))
	else:
		var all_legal := Label.new()
		all_legal.text = "TOUTES\nJOUABLES"
		all_legal.add_theme_font_size_override("font_size", 6)
		illegal_group.add_child(all_legal)
	example_row.add_child(illegal_group)
	dashboard.add_child(example_section["panel"])

	var rules_section := _make_dashboard_section("RÈGLES ACTIVES")
	var rules_column: VBoxContainer = rules_section["column"]
	for rule_text: String in state.get("rules", []):
		var rule := Label.new()
		rule.text = "•  " + rule_text
		rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rule.add_theme_font_size_override("font_size", 7)
		rules_column.add_child(rule)
	dashboard.add_child(rules_section["panel"])

	var quick_section := _make_dashboard_section("RAPPEL RAPIDE")
	var quick_column: VBoxContainer = quick_section["column"]
	var detail := Label.new()
	detail.visible = false
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 7)
	for entry: Dictionary in [
		{"label": "Suivre la couleur  ›", "detail": "Si vous possédez la couleur demandée, vous devez la jouer."},
		{"label": "Éviter les points  ›", "detail": "Chaque Cœur vaut 1 point. La Dame de Pique vaut 13 points."},
	]:
		var button := Button.new()
		button.text = entry["label"]
		button.theme_type_variation = &"HudNavButton"
		button.add_theme_font_size_override("font_size", 7)
		button.pressed.connect(func() -> void:
			detail.text = entry["detail"]
			detail.visible = true
		)
		quick_column.add_child(button)
	var full_rules := Button.new()
	full_rules.text = "Voir les règles  ›"
	full_rules.theme_type_variation = &"HudNavButton"
	full_rules.add_theme_font_size_override("font_size", 7)
	full_rules.pressed.connect(func() -> void: ctx.top_menu_bar.help_pressed.emit())
	quick_column.add_child(full_rules)
	quick_column.add_child(detail)
	dashboard.add_child(quick_section["panel"])


static func _build_example_card(card: CardModel, allowed: bool) -> Control:
	var holder := _build_history_card(card, false)
	var rim := Panel.new()
	rim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = Color(0.4, 0.92, 0.48, 1.0) if allowed else Color(1.0, 0.25, 0.28, 1.0)
	style.set_border_width_all(2)
	rim.add_theme_stylebox_override("panel", style)
	holder.add_child(rim)
	if not allowed:
		holder.modulate = Color(0.62, 0.62, 0.62, 1.0)
		var cross := Label.new()
		cross.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cross.text = "×"
		cross.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cross.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		cross.add_theme_font_size_override("font_size", 18)
		cross.add_theme_color_override("font_color", Color(1.0, 0.16, 0.2, 1.0))
		holder.add_child(cross)
	return holder


static func handle_unhandled_key(ctx: TableContext, event: InputEvent) -> bool:
	if ctx == null or ctx.context_shell == null:
		return false
	if not ctx.context_shell.sidebar_open:
		return false
	if _any_modal_blocking(ctx):
		return false
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			ctx.context_shell.set_sidebar_open(false)
			return true
	return false


static func _on_sidebar_signal(is_open: bool, ctx: TableContext) -> void:
	_sync_scoreboard_dock(ctx, is_open)
	_refresh_toggle_visual(ctx, is_open)
	_position_moon_button(ctx, is_open)
	if ctx.host != null and ctx.match_manager != null:
		TableHumanHand.rebuild(ctx, true)


static func _on_shell_layout_applied(_insets: Vector4, ctx: TableContext) -> void:
	if ctx.host == null or ctx.match_manager == null or not ctx.is_active():
		return
	if ctx.match_manager.hands.is_empty():
		return
	TableHumanHand.rebuild(ctx)


static func _ensure_toggle_button(ctx: TableContext, shell: ContextShellHost) -> void:
	# L'accès canonique est le bouton INFOS de la barre inférieure.
	ctx.shell_toggle_button = null


static func _position_toggle_for_shell(btn: Control, sidebar_open: bool) -> void:
	# La languette vit à l'extérieur du tiroir/panneau : elle ne masque ni les
	# scores ni la pile de cartes de l'adversaire droit.
	var inset: float = ContextShellLayout.SIDEBAR_WIDTH_OPEN if sidebar_open else 6.0
	btn.offset_left = -40.0 - inset
	btn.offset_right = 0.0 - inset


static func _refresh_toggle_visual(ctx: TableContext, sidebar_open: bool) -> void:
	var btn: BaseButton = ctx.shell_toggle_button
	if btn == null or not is_instance_valid(btn):
		return
	_position_toggle_for_shell(btn, sidebar_open)
	btn.text = "FERMER" if sidebar_open else "INFOS"
	btn.add_theme_font_size_override("font_size", 7)
	btn.tooltip_text = "Fermer le panneau" if sidebar_open else "Ouvrir les informations de partie"


static func _position_moon_button(ctx: TableContext, sidebar_open: bool) -> void:
	var button: Control = ctx.moon_suspicion_button
	if button == null or button.get_parent() is HBoxContainer:
		return
	var sidebar_inset: float = ContextShellLayout.SIDEBAR_WIDTH_OPEN if sidebar_open else 0.0
	button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	button.offset_right = -78.0 - sidebar_inset
	button.offset_left = button.offset_right - 214.0
	button.offset_bottom = -72.0
	button.offset_top = -140.0


static func _ensure_sidebar_chrome(ctx: TableContext, shell: ContextShellHost) -> void:
	var root: Control = shell.get_sidebar_content_root()
	if root.get_node_or_null(String(SIDEBAR_CHROME_NAME)) != null:
		return
	var panel := PanelContainer.new()
	panel.name = String(SIDEBAR_CHROME_NAME)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.theme_type_variation = &"ScorePanel"
	var margin := MarginContainer.new()
	margin.name = "Margin"
	for side: String in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	margin.add_theme_constant_override("margin_top", 72)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)
	var tabs := HBoxContainer.new()
	tabs.name = "Tabs"
	tabs.add_theme_constant_override("separation", 3)
	layout.add_child(tabs)
	for tab_name: String in ["PLIS", "CARTES", "POINTS", "AIDE"]:
		var button := Button.new()
		button.text = tab_name
		button.toggle_mode = true
		button.theme_type_variation = &"HudNavButton"
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 6)
		button.pressed.connect(open_tab.bind(ctx, tab_name))
		tabs.add_child(button)
	var title := Label.new()
	title.name = "Title"
	title.text = "POINTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = UiThemeCatalog.V_SECTION_TITLE
	layout.add_child(title)
	var content := Control.new()
	content.name = "Content"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size = Vector2(0, 220)
	layout.add_child(content)
	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.custom_minimum_size = Vector2(0, 180)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var scroll_body := VBoxContainer.new()
	scroll_body.name = "ScrollBody"
	scroll_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_body.add_theme_constant_override("separation", 8)
	scroll.add_child(scroll_body)
	var help := Label.new()
	help.name = "HelpText"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	help.add_theme_color_override("font_color", UiPalette.CREAM)
	help.add_theme_font_size_override("font_size", 8)
	help.visible = false
	scroll_body.add_child(help)
	var tricks_list := VBoxContainer.new()
	tricks_list.name = "TricksList"
	tricks_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tricks_list.add_theme_constant_override("separation", 8)
	tricks_list.visible = false
	scroll_body.add_child(tricks_list)
	var cards_dashboard := VBoxContainer.new()
	cards_dashboard.name = "CardsDashboard"
	cards_dashboard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_dashboard.add_theme_constant_override("separation", 8)
	cards_dashboard.visible = false
	scroll_body.add_child(cards_dashboard)
	var help_dashboard := VBoxContainer.new()
	help_dashboard.name = "HelpDashboard"
	help_dashboard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	help_dashboard.add_theme_constant_override("separation", 8)
	help_dashboard.visible = false
	scroll_body.add_child(help_dashboard)
	root.add_child(panel)


static func _ensure_bottom_bar(ctx: TableContext, shell: ContextShellHost) -> void:
	var root: Control = shell.get_bottom_bar_content_root()
	if root.get_node_or_null(String(BOTTOM_CHROME_NAME)) != null:
		return
	var panel := PanelContainer.new()
	panel.name = String(BOTTOM_CHROME_NAME)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.theme_type_variation = &"HudBarPanel"
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	var sort := Button.new()
	sort.text = "TRIER"
	sort.icon = UiIconCatalog.texture(UiIconCatalog.Icon.PLAYING_CARDS)
	sort.expand_icon = true
	sort.add_theme_constant_override("icon_max_width", 18)
	sort.custom_minimum_size = Vector2(92, 38)
	sort.theme_type_variation = &"HudNavButton"
	sort.tooltip_text = "Trier la main par couleur"
	row.add_child(sort)
	var help := Button.new()
	help.text = "AIDE DE JEU"
	help.icon = UiIconCatalog.texture(UiIconCatalog.Icon.RULES)
	help.expand_icon = true
	help.add_theme_constant_override("icon_max_width", 18)
	help.custom_minimum_size = Vector2(122, 38)
	help.theme_type_variation = &"HudNavButton"
	help.pressed.connect(open_tab.bind(ctx, "AIDE"))
	row.add_child(help)
	var state := HBoxContainer.new()
	state.name = "State"
	state.alignment = BoxContainer.ALIGNMENT_CENTER
	state.add_theme_constant_override("separation", 6)
	state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lead_icon := SuitIconCatalog.make_rect(Suit.CLUBS, Vector2(22, 22))
	lead_icon.name = "LeadIcon"
	state.add_child(lead_icon)
	state.add_child(_make_named_bottom_label("LeadLabel", "Libre choix"))
	state.add_child(_make_named_bottom_label("SeparatorOne", "|"))
	var heart_icon := SuitIconCatalog.make_rect(Suit.HEARTS, Vector2(22, 22))
	heart_icon.name = "HeartIcon"
	state.add_child(heart_icon)
	state.add_child(_make_named_bottom_label("HeartsLabel", "Cœurs non brisés"))
	state.add_child(_make_named_bottom_label("SeparatorTwo", "|"))
	state.add_child(_make_named_bottom_label("PointsLabel", "0 point"))
	row.add_child(state)
	var moon: Control = ctx.moon_suspicion_button
	if moon != null:
		if moon.get_parent() != null:
			moon.get_parent().remove_child(moon)
		row.add_child(moon)
		moon.set_anchors_preset(Control.PRESET_TOP_LEFT)
		moon.custom_minimum_size = Vector2(190, 50)
		moon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var info := Button.new()
	info.text = "INFOS"
	info.icon = UiIconCatalog.texture(UiIconCatalog.Icon.TROPHY)
	info.expand_icon = true
	info.add_theme_constant_override("icon_max_width", 18)
	info.custom_minimum_size = Vector2(92, 38)
	info.theme_type_variation = &"HudNavButton"
	info.pressed.connect(toggle_sidebar.bind(ctx))
	row.add_child(info)
	root.add_child(panel)
	refresh_bottom_state(ctx)


static func _capture_scoreboard_home(ctx: TableContext) -> void:
	var board: Control = ctx.match_scoreboard
	if board == null or not ctx.shell_scoreboard_home.is_empty():
		return
	ctx.shell_scoreboard_home = {
		"parent": board.get_parent(),
		"index": board.get_index(),
		"anchor_left": board.anchor_left,
		"anchor_top": board.anchor_top,
		"anchor_right": board.anchor_right,
		"anchor_bottom": board.anchor_bottom,
		"offset_left": board.offset_left,
		"offset_top": board.offset_top,
		"offset_right": board.offset_right,
		"offset_bottom": board.offset_bottom,
		"visible": board.visible,
	}


static func _sync_scoreboard_dock(ctx: TableContext, sidebar_open: bool) -> void:
	var board: Control = ctx.match_scoreboard
	var shell: ContextShellHost = ctx.context_shell
	if board == null or shell == null:
		return
	_capture_scoreboard_home(ctx)
	if sidebar_open:
		var chrome: Control = shell.get_sidebar_content_root().get_node_or_null(String(SIDEBAR_CHROME_NAME)) as Control
		var content: Control = chrome.get_node_or_null("Margin/Layout/Content") as Control if chrome != null else null
		if content != null and board.get_parent() != content:
			if board.get_parent() != null:
				board.get_parent().remove_child(board)
			content.add_child(board)
		board.visible = true
		board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		board.offset_left = 0.0
		board.offset_top = 0.0
		board.offset_right = 0.0
		board.offset_bottom = 0.0
	else:
		_restore_scoreboard_home(ctx)
		board.visible = false


static func _restore_scoreboard_home(ctx: TableContext) -> void:
	var board: Control = ctx.match_scoreboard
	var home: Dictionary = ctx.shell_scoreboard_home
	if board == null or home.is_empty():
		return
	var parent: Node = home.get("parent") as Node
	if parent == null or not is_instance_valid(parent):
		return
	if board.get_parent() != parent:
		var prev: Node = board.get_parent()
		if prev != null:
			prev.remove_child(board)
		parent.add_child(board)
		var idx: int = int(home.get("index", -1))
		if idx >= 0 and idx < parent.get_child_count():
			parent.move_child(board, mini(idx, parent.get_child_count() - 1))
	board.anchor_left = float(home.get("anchor_left", 1.0))
	board.anchor_top = float(home.get("anchor_top", 0.0))
	board.anchor_right = float(home.get("anchor_right", 1.0))
	board.anchor_bottom = float(home.get("anchor_bottom", 0.0))
	board.offset_left = float(home.get("offset_left", -260.0))
	board.offset_top = float(home.get("offset_top", 72.0))
	board.offset_right = float(home.get("offset_right", -12.0))
	board.offset_bottom = float(home.get("offset_bottom", 220.0))
	board.visible = bool(home.get("visible", true))


static func _any_modal_blocking(ctx: TableContext) -> bool:
	for node: Control in [
		ctx.confirm_dialog,
		ctx.match_end_dialog,
		ctx.hand_end_dialog,
	]:
		if node != null and node.visible:
			return true
	if ctx.host == null:
		return false
	var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return false
	for child_name: String in ["ScoresScreen", "SettingsScreen", "HelpScreen"]:
		var overlay: Control = ui_layer.get_node_or_null(child_name) as Control
		if overlay != null and overlay.visible:
			return true
	return false
