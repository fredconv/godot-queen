extends Control
## HandEndDialog
## Popup de fin de manche : vainqueur de la manche (score le plus bas) et
## scores de la manche pour tous les joueurs. Bloque jusqu'au clic
## « Manche suivante ».

signal continue_requested

const WINNER_SCORE_COLOR: Color = Color(0.831, 0.686, 0.216, 1)
const DEFAULT_SCORE_COLOR: Color = Color(0.961, 0.941, 0.902, 1)

@onready var _winner_avatar: Control = $Panel/Content/WinnerRow/WinnerAvatar
@onready var _winner_name_label: Label = $Panel/Content/WinnerRow/WinnerNameLabel
@onready var _winner_detail_label: Label = $Panel/Content/WinnerDetailLabel
@onready var _scores_list: VBoxContainer = $Panel/Content/ScoresList

func show_result(
	hand_winner_index: int,
	player_names: Array,
	hand_scores: Array,
	cumulative_scores: Array,
	character_ids: Array
) -> void:
	_winner_avatar.set("character_index", character_ids[hand_winner_index])
	_winner_name_label.text = "%s remporte la manche !" % player_names[hand_winner_index]
	_winner_detail_label.text = "Manche : %d pts  |  Total partie : %d pts" % [
		hand_scores[hand_winner_index],
		cumulative_scores[hand_winner_index],
	]

	for child in _scores_list.get_children():
		child.queue_free()

	var ranked: Array = []
	for player_index in range(player_names.size()):
		ranked.append({
			"index": player_index,
			"hand": hand_scores[player_index],
			"cumulative": cumulative_scores[player_index],
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["hand"] < b["hand"]
	)

	for entry in ranked:
		var player_index: int = entry["index"]
		var is_winner: bool = player_index == hand_winner_index
		var label := Label.new()
		var prefix: String = "★ " if is_winner else "   "
		label.text = "%s%s — manche : %d | total : %d" % [
			prefix,
			player_names[player_index],
			entry["hand"],
			entry["cumulative"],
		]
		label.add_theme_color_override("font_color", WINNER_SCORE_COLOR if is_winner else DEFAULT_SCORE_COLOR)
		_scores_list.add_child(label)

	visible = true

func close() -> void:
	visible = false

func _on_btn_continue_pressed() -> void:
	close()
	continue_requested.emit()
