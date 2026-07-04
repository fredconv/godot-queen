extends Control
## MatchEndDialog
## Popup de fin de partie : identifie le vainqueur (avatar, nom), pointe vers
## son siège via une flèche (haut/bas/gauche/droite), affiche les scores de
## tous les joueurs et propose de rejouer. Purement visuel : ne décide rien,
## se contente d'afficher le résultat que `table.gd` lui transmet via
## `show_result()`.

signal replay_requested
signal quit_requested

## Couleur de mise en valeur du score du vainqueur dans `ScoresList`.
const WINNER_SCORE_COLOR: Color = Color(0.831, 0.686, 0.216, 1)
const DEFAULT_SCORE_COLOR: Color = Color(0.961, 0.941, 0.902, 1)

@onready var _winner_avatar: Control = $Panel/Content/WinnerRow/WinnerAvatar
@onready var _winner_name_label: Label = $Panel/Content/WinnerRow/WinnerNameLabel
@onready var _scores_list: VBoxContainer = $Panel/Content/ScoresList

## Flèches indexées par index de joueur (0=bas, 1=gauche, 2=haut, 3=droite),
## même convention de siège que `table.gd::SEAT_FOR_PLAYER`.
@onready var _arrows_by_player: Array = [
	$ArrowBottom,
	$ArrowLeft,
	$ArrowTop,
	$ArrowRight,
]

## Affiche le résultat de la partie. `player_names`/`scores`/`character_ids`
## sont indexés par `player_index` (0-3, voir docs/DECISIONS.md ADR-019).
func show_result(winner_index: int, player_names: Array, scores: Array, character_ids: Array) -> void:
	for arrow in _arrows_by_player:
		(arrow as Control).visible = false
	(_arrows_by_player[winner_index] as Control).visible = true

	_winner_avatar.set("character_index", character_ids[winner_index])
	_winner_name_label.text = "%s remporte la partie !" % player_names[winner_index]

	for child in _scores_list.get_children():
		child.queue_free()
	for player_index in range(player_names.size()):
		var is_winner: bool = player_index == winner_index
		var label := Label.new()
		var prefix: String = "★ " if is_winner else "    "
		label.text = "%s%s — %d points" % [prefix, player_names[player_index], scores[player_index]]
		label.add_theme_color_override("font_color", WINNER_SCORE_COLOR if is_winner else DEFAULT_SCORE_COLOR)
		_scores_list.add_child(label)

	visible = true

func close() -> void:
	visible = false

func _on_btn_replay_pressed() -> void:
	close()
	replay_requested.emit()


func _on_btn_quit_pressed() -> void:
	close()
	quit_requested.emit()
