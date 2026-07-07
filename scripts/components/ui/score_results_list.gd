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
	for entry: Dictionary in ranked:
		var player_index: int = entry["index"]
		var is_winner: bool = player_index == winner_index
		var label := Label.new()
		label.text = DialogCopy.match_score_row(
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
