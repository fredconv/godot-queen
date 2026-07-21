class_name MatchEndDialog
extends Control
## Popup de fin de partie : vainqueur, classement et actions rejouer / quitter.


signal replay_requested
signal quit_requested

const ENTRANCE_DURATION_SEC: float = 0.38
const ARROW_PULSE_SEC: float = 0.62

@onready var _panel: PanelContainer = $Panel
@onready var _title_label: Label = $Panel/Content/DecorRow/TitleLabel
@onready var _ranking_header: Label = $Panel/Content/RankingHeader
@onready var _winner_avatar: Control = $Panel/Content/WinnerRow/WinnerAvatar
@onready var _winner_name_label: Label = $Panel/Content/WinnerRow/WinnerNameLabel
@onready var _winner_detail_label: Label = $Panel/Content/WinnerDetailLabel
@onready var _scores_list: VBoxContainer = $Panel/Content/ScoresBox/ScoresList
@onready var _btn_replay: NinePatchButton = $Panel/Content/ButtonsRow/BtnReplay
@onready var _btn_quit: NinePatchButton = $Panel/Content/ButtonsRow/BtnQuit

@onready var _arrows_by_player: Array = [
	$ArrowBottom,
	$ArrowLeft,
	$ArrowTop,
	$ArrowRight,
]

var _last_result: Dictionary = {}
var _arrow_tween: Tween = null


func _ready() -> void:
	_panel.pivot_offset = _panel.size * 0.5
	LocaleAware.bind(self, _refresh_locale)
	UiFocusNav.chain_horizontal([_btn_replay, _btn_quit])
	UiStyleFactory.apply_pixel_panel(_panel, UiStyleFactory.pixel_overlay_panel_style(Vector4(20, 16, 20, 16)))
	_refresh_locale()


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
	_play_entrance_animation()
	_start_arrow_pulse(winner_index)
	UiFocusNav.grab_first([_btn_replay, _btn_quit])


func close() -> void:
	_stop_arrow_pulse()
	visible = false
	_panel.scale = Vector2.ONE
	_panel.modulate = Color.WHITE


func _refresh_locale() -> void:
	_title_label.text = tr(DialogKeys.MATCH_END_TITLE)
	_ranking_header.text = tr(DialogKeys.MATCH_RANKING_HEADER)
	_btn_replay.set_button_text(tr(DialogKeys.MATCH_REPLAY))
	_btn_quit.set_button_text(tr(DialogKeys.MATCH_QUIT))
	NinePatchButton.uniform_fit_group([_btn_replay, _btn_quit])
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
	_winner_detail_label.text = DialogCopy.match_winner_detail(
		hand_scores[winner_index],
		cumulative_scores[winner_index]
	)
	ScoreResultsList.populate_match_rows(
		_scores_list,
		player_names,
		hand_scores,
		cumulative_scores,
		winner_index
	)
	for child in _scores_list.get_children():
		var row: Label = child as Label
		if row == null:
			continue
		row.add_theme_font_size_override("font_size", LocaleFonts.MENU_SCORE_FONT_SIZE)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _play_entrance_animation() -> void:
	UiOffsetAnim.play_dialog_entrance(self, _panel, ENTRANCE_DURATION_SEC)


func _start_arrow_pulse(winner_index: int) -> void:
	_stop_arrow_pulse()
	var arrow: Control = _arrows_by_player[winner_index] as Control
	if arrow == null:
		return
	arrow.modulate.a = 1.0
	_arrow_tween = create_tween().set_loops()
	_arrow_tween.tween_property(arrow, "modulate:a", 0.35, ARROW_PULSE_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_arrow_tween.tween_property(arrow, "modulate:a", 1.0, ARROW_PULSE_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_arrow_pulse() -> void:
	if _arrow_tween != null and _arrow_tween.is_valid():
		_arrow_tween.kill()
	_arrow_tween = null
	for arrow in _arrows_by_player:
		(arrow as Control).modulate.a = 1.0


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
