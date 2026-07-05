extends Control
## MatchScoreboard
## Panneau des scores cumulés de partie (objectif 100 pts), distinct des
## scores de manche affichés sous chaque avatar. Purement visuel.

const ENTRY_COLOR: Color = Color(0.961, 0.941, 0.902, 1)
const HUMAN_COLOR: Color = Color(0.831, 0.686, 0.216, 1)

@onready var _title_label: Label = $Panel/Margin/TitleLabel
@onready var _entries: VBoxContainer = $Panel/Margin/Entries

## Met à jour l'affichage. `player_names` et `cumulative_scores` sont indexés
## par `player_index` (0-3). Les joueurs sont triés par score croissant (le plus
## bas est en tête, voir règles Hearts).
func update_display(hand_number: int, player_names: Array, cumulative_scores: Array) -> void:
	_title_label.text = "Partie — manche %d / 100 pts" % hand_number

	for child in _entries.get_children():
		child.queue_free()

	var ranked: Array = []
	for player_index in range(player_names.size()):
		ranked.append({"index": player_index, "score": cumulative_scores[player_index]})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["score"] < b["score"]
	)

	for entry in ranked:
		var player_index: int = entry["index"]
		var label := Label.new()
		var prefix: String = "★ " if player_index == 0 else "   "
		label.text = "%s%s — %d" % [prefix, player_names[player_index], entry["score"]]
		var color: Color = HUMAN_COLOR if player_index == 0 else ENTRY_COLOR
		label.add_theme_color_override("font_color", color)
		_entries.add_child(label)
