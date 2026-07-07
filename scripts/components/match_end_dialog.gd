extends Control
## MatchEndDialog
## Popup de fin de partie : identifie le vainqueur (avatar, nom), pointe vers
## son siège via une flèche (haut/bas/gauche/droite), affiche les scores de
## tous les joueurs et propose de rejouer. Purement visuel : ne décide rien,
## se contente d'afficher le résultat que `table.gd` lui transmet via
## `show_result()`.

signal replay_requested
signal quit_requested

const WINNER_SCORE_COLOR: Color = Color(0.831, 0.686, 0.216, 1)
const DEFAULT_SCORE_COLOR: Color = Color(0.961, 0.941, 0.902, 1)

@onready var _title_label: Label = $Panel/Content/TitleLabel
@onready var _winner_avatar: Control = $Panel/Content/WinnerRow/WinnerAvatar
@onready var _winner_name_label: Label = $Panel/Content/WinnerRow/WinnerNameLabel
@onready var _winner_detail_label: Label = $Panel/Content/WinnerDetailLabel
@onready var _scores_list: VBoxContainer = $Panel/Content/ScoresList
@onready var _btn_replay: Button = $Panel/Content/ButtonsRow/BtnReplay
@onready var _btn_quit: Button = $Panel/Content/ButtonsRow/BtnQuit

@onready var _arrows_by_player: Array = [
	$ArrowBottom,
	$ArrowLeft,
	$ArrowTop,
	$ArrowRight,
]

var _last_result: Dictionary = {}


func _ready() -> void:
	LocaleAware.bind(self, _refresh_locale)
	UiFocusNav.chain_horizontal([_btn_replay, _btn_quit])


func show_result(
	winner_index: int,
	player_names: Array,
	cumulative_scores: Array,
	hand_scores: Array,
	character_ids: Array
) -> void:
	_last_result = {
		"winner_index": winner_index,
		"player_names": player_names.duplicate(),
		"cumulative_scores": cumulative_scores.duplicate(),
		"hand_scores": hand_scores.duplicate(),
		"character_ids": character_ids.duplicate(),
	}
	_render_result()
	visible = true
	UiFocusNav.grab_first([_btn_replay, _btn_quit])


func close() -> void:
	visible = false


func _refresh_locale() -> void:
	_title_label.text = tr(DialogKeys.MATCH_END_TITLE)
	_btn_replay.text = tr(DialogKeys.MATCH_REPLAY)
	_btn_quit.text = tr(DialogKeys.MATCH_QUIT)
	if not _last_result.is_empty():
		_render_result()


func _render_result() -> void:
	if _last_result.is_empty():
		return
	var winner_index: int = _last_result["winner_index"]
	var player_names: Array = _last_result["player_names"]
	var cumulative_scores: Array = _last_result["cumulative_scores"]
	var hand_scores: Array = _last_result["hand_scores"]
	var character_ids: Array = _last_result["character_ids"]

	for arrow in _arrows_by_player:
		(arrow as Control).visible = false
	(_arrows_by_player[winner_index] as Control).visible = true

	_winner_avatar.set("character_index", character_ids[winner_index])
	_winner_name_label.text = DialogCopy.match_winner_line(player_names[winner_index])
	if _winner_detail_label:
		_winner_detail_label.text = DialogCopy.match_winner_detail(
			hand_scores[winner_index],
			cumulative_scores[winner_index]
		)

	for child in _scores_list.get_children():
		child.queue_free()

	var ranked: Array = []
	for player_index in range(player_names.size()):
		ranked.append({
			"index": player_index,
			"cumulative": cumulative_scores[player_index],
			"hand": hand_scores[player_index],
		})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["cumulative"] < b["cumulative"]
	)

	for entry in ranked:
		var player_index: int = entry["index"]
		var is_winner: bool = player_index == winner_index
		var label := Label.new()
		label.text = DialogCopy.match_score_row(
			DialogCopy.winner_prefix(is_winner),
			player_names[player_index],
			entry["hand"],
			entry["cumulative"]
		)
		label.add_theme_color_override("font_color", WINNER_SCORE_COLOR if is_winner else DEFAULT_SCORE_COLOR)
		_scores_list.add_child(label)


func _on_btn_replay_pressed() -> void:
	close()
	replay_requested.emit()


func _on_btn_quit_pressed() -> void:
	close()
	quit_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if UiFocusNav.is_cancel_pressed(event):
		_on_btn_quit_pressed()
		get_viewport().set_input_as_handled()
