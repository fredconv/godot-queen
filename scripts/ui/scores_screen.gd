extends Control
## Écran Scores : statistiques persistées du joueur humain.
## Overlay modal réutilisable depuis le menu principal et la table.

signal closed

const StatsStoreClass = preload("res://scripts/core/stats_store.gd")

@onready var _summary_label: Label = $Panel/Margin/VBox/SummaryLabel
@onready var _empty_label: Label = $Panel/Margin/VBox/EmptyLabel


func _ready() -> void:
	visible = false


func open() -> void:
	_refresh_display()
	show()


func close() -> void:
	hide()
	closed.emit()


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
		"Parties terminées : %d\nVictoires : %d\nDéfaites : %d\nTaux de victoire : %d %%"
		% [played, won, lost, win_rate]
	)


func _on_btn_back_pressed() -> void:
	close()
