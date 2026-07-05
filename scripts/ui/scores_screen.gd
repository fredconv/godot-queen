extends Control
## Écran Scores : statistiques persistées du joueur humain.
## Overlay modal réutilisable depuis le menu principal et la table.

signal closed

const StatsStoreClass = preload("res://scripts/core/stats_store.gd")

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _summary_label: Label = $Panel/Margin/VBox/SummaryLabel
@onready var _empty_label: Label = $Panel/Margin/VBox/EmptyLabel
@onready var _btn_back: Button = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	visible = false
	LocaleAware.bind(self, _refresh_locale)


func open() -> void:
	_refresh_locale()
	show()
	call_deferred("_btn_back.grab_focus")


func close() -> void:
	hide()
	closed.emit()


func _refresh_locale() -> void:
	_title_label.text = tr(UiKeys.SCORES_TITLE)
	_btn_back.text = tr(UiKeys.COMMON_BACK)
	_empty_label.text = tr(UiKeys.SCORES_EMPTY)
	_refresh_display()


func _refresh_display() -> void:
	var stats: Dictionary = StatsService.get_stats()
	var played: int = stats[StatsStoreClass.KEY_MATCHES_PLAYED]
	var won: int = stats[StatsStoreClass.KEY_MATCHES_WON]
	var lost: int = stats[StatsStoreClass.KEY_MATCHES_LOST]
	var win_rate: int = StatsService.get_win_rate_percent()

	_empty_label.visible = played == 0
	_summary_label.visible = played > 0
	if played == 0:
		return

	_summary_label.text = (
		tr(UiKeys.SCORES_MATCHES) % played
		+ "\n"
		+ tr(UiKeys.SCORES_WINS) % won
		+ "\n"
		+ tr(UiKeys.SCORES_LOSSES) % lost
		+ "\n"
		+ tr(UiKeys.SCORES_WIN_RATE) % win_rate
	)


func _on_btn_back_pressed() -> void:
	close()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
