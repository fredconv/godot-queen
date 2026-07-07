extends Control
## HandEndDialog
## Popup de fin de manche : vainqueur de la manche (score le plus bas) et
## scores de la manche pour tous les joueurs. Bloque jusqu'au clic
## « Manche suivante ».

signal continue_requested

const WINNER_SCORE_COLOR: Color = Color(0.831, 0.686, 0.216, 1)
const DEFAULT_SCORE_COLOR: Color = Color(0.961, 0.941, 0.902, 1)

@onready var _title_label: Label = $Panel/Content/TitleLabel
@onready var _winner_avatar: Control = $Panel/Content/WinnerRow/WinnerAvatar
@onready var _winner_name_label: Label = $Panel/Content/WinnerRow/WinnerNameLabel
@onready var _winner_detail_label: Label = $Panel/Content/WinnerDetailLabel
@onready var _scores_list: VBoxContainer = $Panel/Content/ScoresList
@onready var _btn_continue: Button = $Panel/Content/BtnContinue

var _last_result: Dictionary = {}


func _ready() -> void:
	LocaleAware.bind(self, _refresh_locale)
	UiFocusNav.chain_vertical([_btn_continue])


func show_result(
	hand_winner_index: int,
	player_names: Array,
	hand_scores: Array,
	cumulative_scores: Array,
	character_ids: Array
) -> void:
	_last_result = {
		"hand_winner_index": hand_winner_index,
		"player_names": player_names.duplicate(),
		"hand_scores": hand_scores.duplicate(),
		"cumulative_scores": cumulative_scores.duplicate(),
		"character_ids": character_ids.duplicate(),
	}
	_render_result()
	visible = true
	UiFocusNav.grab_first([_btn_continue])


func close() -> void:
	visible = false


func _refresh_locale() -> void:
	_title_label.text = tr(DialogKeys.HAND_END_TITLE)
	_btn_continue.text = tr(DialogKeys.HAND_CONTINUE)
	if not _last_result.is_empty():
		_render_result()


func _render_result() -> void:
	if _last_result.is_empty():
		return
	var hand_winner_index: int = _last_result["hand_winner_index"]
	var player_names: Array = _last_result["player_names"]
	var hand_scores: Array = _last_result["hand_scores"]
	var cumulative_scores: Array = _last_result["cumulative_scores"]
	var character_ids: Array = _last_result["character_ids"]

	_winner_avatar.set("character_index", character_ids[hand_winner_index])
	_winner_name_label.text = DialogCopy.hand_winner_line(player_names[hand_winner_index])
	_winner_detail_label.text = DialogCopy.hand_winner_detail(
		hand_scores[hand_winner_index],
		cumulative_scores[hand_winner_index]
	)

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
		label.text = DialogCopy.hand_score_row(
			DialogCopy.winner_prefix(is_winner),
			player_names[player_index],
			entry["hand"],
			entry["cumulative"]
		)
		label.add_theme_color_override("font_color", WINNER_SCORE_COLOR if is_winner else DEFAULT_SCORE_COLOR)
		_scores_list.add_child(label)


func _on_btn_continue_pressed() -> void:
	close()
	continue_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_btn_continue_pressed()
		get_viewport().set_input_as_handled()
