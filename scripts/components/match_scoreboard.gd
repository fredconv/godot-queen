extends Control
## MatchScoreboard
## Panneau des scores cumulés de partie (objectif 100 pts), distinct des
## scores de manche affichés sous chaque avatar. Purement visuel.

const MATCH_GOAL_POINTS: int = 100

@onready var _title_label: Label = $Panel/Margin/TitleLabel
@onready var _entries: VBoxContainer = $Panel/Margin/Entries

var _last_hand_number: int = 1
var _last_player_names: Array = []
var _last_cumulative_scores: Array = []


func _ready() -> void:
	LocaleAware.bind(self, _refresh_locale)


func update_display(hand_number: int, player_names: Array, cumulative_scores: Array) -> void:
	_last_hand_number = hand_number
	_last_player_names = player_names.duplicate()
	_last_cumulative_scores = cumulative_scores.duplicate()
	_render_display()


func _refresh_locale() -> void:
	_render_display()


func _render_display() -> void:
	_title_label.text = TableCopy.scoreboard_title(_last_hand_number, MATCH_GOAL_POINTS)

	for child in _entries.get_children():
		child.queue_free()

	if _last_player_names.is_empty():
		return

	var ranked: Array = []
	for player_index in range(_last_player_names.size()):
		ranked.append({"index": player_index, "score": _last_cumulative_scores[player_index]})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["score"] < b["score"]
	)

	for entry in ranked:
		var player_index: int = entry["index"]
		var row := ScoreBarRow.new()
		row.configure(
			_last_player_names[player_index],
			entry["score"],
			MATCH_GOAL_POINTS,
			player_index == 0
		)
		_entries.add_child(row)
