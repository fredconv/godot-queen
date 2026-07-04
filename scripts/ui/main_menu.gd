extends Control
## MainMenu
## Écran de menu principal (étape 7 de docs/ROADMAP.md). Contrôleur minimal :
## lance une partie de démonstration sur `table.tscn`, quitte le jeu, ou
## affiche un recouvrement provisoire pour Scores/Configuration (écrans
## détaillés à construire dans une itération future).
## Aucune règle de jeu ici, uniquement de la navigation entre scènes.
##
## Musique : `AudioService` (autoload) démarre déjà la playlist d'ambiance
## dans son propre `_ready()` si activée (voir `ConfigService.get_music_enabled()`),
## avant même que cette scène ne soit prête, et elle continue sans interruption
## lors des changements de scène. `ensure_music_playing()` est rappelée ici en
## filet de sécurité : si l'auto-démarrage à l'initialisation du moteur a
## échoué ou n'a pas encore pris effet, la musique démarre au plus tard à
## l'arrivée sur ce menu (voir docs/DECISIONS.md ADR-013).

@onready var _stub_overlay: Control = $StubOverlay
@onready var _stub_label: Label = $StubOverlay/Panel/Margin/VBox/StubLabel

func _ready() -> void:
	AudioService.ensure_music_playing()

func _on_btn_new_game_pressed() -> void:
	GameSession.start_match()
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")

func _on_btn_scores_pressed() -> void:
	_show_stub("Scores — à venir")

func _on_btn_settings_pressed() -> void:
	_show_stub("Configuration — à venir")

func _on_btn_stub_close_pressed() -> void:
	_stub_overlay.hide()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()

func _show_stub(text: String) -> void:
	_stub_label.text = text
	_stub_overlay.show()
