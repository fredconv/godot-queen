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
	UiThemeCatalog.ensure_project_theme_enriched()
	var panel: PanelContainer = get_node_or_null("Panel") as PanelContainer
	if panel != null:
		UiStyleFactory.apply_pixel_panel(panel, UiStyleFactory.pixel_banner_panel_style(Vector4(12, 10, 12, 10), 2, 0.94))
		UiThemeCatalog.apply_variation(panel, UiThemeCatalog.V_SCORE_PANEL)
	if _title_label != null:
		UiThemeCatalog.apply_variation(_title_label, UiThemeCatalog.V_SECTION_TITLE)


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
		if _entries.get_child_count() > 0:
			var sep := ColorRect.new()
			sep.custom_minimum_size = Vector2(0, 1)
			sep.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.25)
			sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_entries.add_child(sep)
		var row := ScoreBarRow.new()
		row.configure(
			_last_player_names[player_index],
			entry["score"],
			MATCH_GOAL_POINTS,
			player_index == 0
		)
		_entries.add_child(row)
