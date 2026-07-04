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

## Libellés du bouton musique selon l'état (voir `set_music_enabled_display()`).
const MUSIC_LABEL_ON: String = "MUSIQUE : ON"
const MUSIC_LABEL_OFF: String = "MUSIQUE : OFF"

@onready var _turn_label: Label = $Margin/Bar/CenterInfo/TurnLabel
@onready var _score_label: Label = $Margin/Bar/CenterInfo/ScoreLabel
@onready var _btn_toggle_music: Button = $Margin/Bar/RightButtons/BtnToggleMusic

func set_turn_text(text: String) -> void:
	_turn_label.text = text

func set_score_text(text: String) -> void:
	_score_label.text = text

## Met à jour le libellé du bouton musique pour refléter l'état courant
## (ON/OFF). N'émet aucun signal : c'est à l'appelant (ex. `table.gd`) de
## synchroniser l'affichage avec `ConfigService.get_music_enabled()`.
func set_music_enabled_display(enabled: bool) -> void:
	_btn_toggle_music.text = MUSIC_LABEL_ON if enabled else MUSIC_LABEL_OFF

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
