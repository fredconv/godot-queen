class_name ScoreResultsList
extends RefCounted
## Rendu partagé des listes de scores classés (fin de manche / fin de partie).

const WINNER_SCORE_COLOR: Color = Color(0.831, 0.686, 0.216, 1)
const DEFAULT_SCORE_COLOR: Color = Color(0.961, 0.941, 0.902, 1)


static func clear(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


static func populate_hand_rows(
	container: VBoxContainer,
	player_names: Array,
	hand_scores: Array,
	cumulative_scores: Array,
	winner_index: int
) -> void:
	clear(container)
	var ranked := _rank_by_hand(player_names.size(), hand_scores, cumulative_scores)
	for entry: Dictionary in ranked:
		var player_index: int = entry["index"]
		var is_winner: bool = player_index == winner_index
		var label := Label.new()
		label.text = DialogCopy.hand_score_row(
			DialogCopy.winner_prefix(is_winner),
			player_names[player_index],
			entry["hand"],
			entry["cumulative"]
		)
		label.add_theme_color_override(
			"font_color",
			WINNER_SCORE_COLOR if is_winner else DEFAULT_SCORE_COLOR
		)
		container.add_child(label)


static func populate_match_rows(
	container: VBoxContainer,
	player_names: Array,
	hand_scores: Array,
	cumulative_scores: Array,
	winner_index: int
) -> void:
	clear(container)
	var ranked := _rank_by_cumulative(player_names.size(), hand_scores, cumulative_scores)
	container.add_child(_build_match_header())
	for rank_index in range(ranked.size()):
		var entry: Dictionary = ranked[rank_index]
		var player_index: int = entry["index"]
		var is_winner: bool = player_index == winner_index
		container.add_child(_build_match_row(
			rank_index + 1,
			str(player_names[player_index]),
			int(entry["hand"]),
			int(entry["cumulative"]),
			is_winner
		))


static func _build_match_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(_column_label("RANG", 70, HORIZONTAL_ALIGNMENT_CENTER, true))
	row.add_child(_column_label("JOUEUR", 0, HORIZONTAL_ALIGNMENT_LEFT, true, true))
	row.add_child(_column_label("MANCHE", 92, HORIZONTAL_ALIGNMENT_CENTER, true))
	row.add_child(_column_label("TOTAL", 76, HORIZONTAL_ALIGNMENT_CENTER, true))
	return row


static func _build_match_row(rank: int, player_name: String, hand: int, total: int, winner: bool) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.08, 0.28, 0.72) if winner else Color(0.015, 0.085, 0.06, 0.58)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.92, 0.68, 0.16, 0.9) if winner else Color(0.45, 0.33, 0.12, 0.55)
	style.content_margin_left = 10.0
	style.content_margin_top = 7.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 7.0
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var rank_text := "1er" if winner else str(rank)
	row.add_child(_column_label(rank_text, 60, HORIZONTAL_ALIGNMENT_CENTER, false, false, winner))
	row.add_child(_column_label(player_name, 0, HORIZONTAL_ALIGNMENT_LEFT, false, true, winner))
	row.add_child(_column_label(str(hand), 92, HORIZONTAL_ALIGNMENT_CENTER, false, false, winner))
	row.add_child(_column_label(str(total), 76, HORIZONTAL_ALIGNMENT_CENTER, false, false, winner))
	panel.add_child(row)
	return panel


static func _column_label(
	text_value: String,
	min_width: int,
	alignment: HorizontalAlignment,
	muted: bool,
	expand: bool = false,
	winner: bool = false
) -> Label:
	var label := Label.new()
	label.text = text_value
	label.custom_minimum_size.x = float(min_width)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if expand:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 8 if muted else 9)
	var color := Color(0.72, 0.57, 0.25, 1) if muted else DEFAULT_SCORE_COLOR
	if winner:
		color = Color(1, 0.79, 0.25, 1)
	label.add_theme_color_override("font_color", color)
	return label


static func _rank_by_hand(
	player_count: int,
	hand_scores: Array,
	cumulative_scores: Array
) -> Array[Dictionary]:
	var ranked: Array[Dictionary] = []
	for player_index in range(player_count):
		ranked.append({
			"index": player_index,
			"hand": hand_scores[player_index],
			"cumulative": cumulative_scores[player_index],
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["hand"] < b["hand"]
	)
	return ranked


static func _rank_by_cumulative(
	player_count: int,
	hand_scores: Array,
	cumulative_scores: Array
) -> Array[Dictionary]:
	var ranked: Array[Dictionary] = []
	for player_index in range(player_count):
		ranked.append({
			"index": player_index,
			"hand": hand_scores[player_index],
			"cumulative": cumulative_scores[player_index],
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["cumulative"] < b["cumulative"]
	)
	return ranked
