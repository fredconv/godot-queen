extends Control
## TopMenuBar
## Barre de menu supérieure (style bois) : affiche les infos de tour/scores
## et expose des signaux pour les actions des boutons. Ne contient aucune
## règle de jeu ; le câblage réel se fera plus tard via `GameEvents` ou par
## connexion directe depuis la scène qui possède cette barre.

signal hamburger_pressed
signal help_pressed
signal scores_pressed
signal new_game_pressed
signal menu_pressed
signal settings_pressed
signal music_toggle_pressed
signal music_next_pressed

@onready var _btn_hamburger: Button = $Margin/Bar/LeftButtons/BtnHamburger
@onready var _btn_help: Button = $Margin/Bar/LeftButtons/BtnHelp
@onready var _btn_scores: Button = $Margin/Bar/LeftButtons/BtnScores
@onready var _turn_label: Label = $Margin/Bar/CenterInfo/TurnLabel
@onready var _score_label: Label = $Margin/Bar/CenterInfo/ScoreLabel
@onready var _btn_new: Button = $Margin/Bar/RightButtons/BtnNew
@onready var _btn_toggle_music: Button = $Margin/Bar/RightButtons/BtnToggleMusic
@onready var _btn_next_music: Button = $Margin/Bar/RightButtons/BtnNextMusic
@onready var _btn_menu: Button = $Margin/Bar/RightButtons/BtnMenu
@onready var _btn_settings: Button = $Margin/Bar/RightButtons/BtnSettings

var _music_enabled: bool = true


func _ready() -> void:
	LocaleAware.bind(self, refresh_locale)
	refresh_locale()


func set_turn_text(text: String) -> void:
	_turn_label.text = text


func set_score_text(text: String) -> void:
	_score_label.text = text


func set_music_enabled_display(enabled: bool) -> void:
	_music_enabled = enabled
	_btn_toggle_music.text = TableCopy.music_toggle_label(enabled)


func refresh_locale() -> void:
	_btn_help.text = tr(TableKeys.TOP_HELP)
	_btn_scores.text = tr(TableKeys.TOP_SCORES)
	_btn_new.text = tr(TableKeys.TOP_NEW)
	_btn_menu.text = tr(TableKeys.TOP_MENU)
	_btn_next_music.text = tr(TableKeys.TOP_MUSIC_NEXT)
	_btn_hamburger.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MENU)
	_btn_toggle_music.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MUSIC)
	_btn_next_music.tooltip_text = tr(TableKeys.TOP_TOOLTIP_MUSIC_NEXT)
	_btn_settings.tooltip_text = tr(TableKeys.TOP_TOOLTIP_SETTINGS)
	set_music_enabled_display(_music_enabled)


func _on_btn_hamburger_pressed() -> void:
	hamburger_pressed.emit()


func _on_btn_help_pressed() -> void:
	help_pressed.emit()


func _on_btn_scores_pressed() -> void:
	scores_pressed.emit()


func _on_btn_new_pressed() -> void:
	new_game_pressed.emit()


func _on_btn_menu_pressed() -> void:
	menu_pressed.emit()


func _on_btn_settings_pressed() -> void:
	settings_pressed.emit()


func _on_btn_toggle_music_pressed() -> void:
	music_toggle_pressed.emit()


func _on_btn_next_music_pressed() -> void:
	music_next_pressed.emit()
