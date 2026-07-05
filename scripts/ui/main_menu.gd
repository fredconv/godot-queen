extends Control
## MainMenu
## Écran de menu principal (étape 7 de docs/ROADMAP.md). Contrôleur minimal :
## lance une partie de démonstration sur `table.tscn`, quitte le jeu, ou
## affiche les écrans Scores / Configuration.
## Aucune règle de jeu ici, uniquement de la navigation entre scènes.
##
## Musique : `AudioService` (autoload) démarre déjà la playlist d'ambiance
## dans son propre `_ready()` si activée (voir `ConfigService.get_music_enabled()`),
## avant même que cette scène ne soit prête, et elle continue sans interruption
## lors des changements de scène. `ensure_music_playing()` est rappelée ici en
## filet de sécurité : si l'auto-démarrage à l'initialisation du moteur a
## échoué ou n'a pas encore pris effet, la musique démarre au plus tard à
## l'arrivée sur ce menu (voir docs/DECISIONS.md ADR-013).

@onready var _settings_screen: Control = $SettingsScreen
@onready var _scores_screen: Control = $ScoresScreen


func _ready() -> void:
	AudioService.ensure_music_playing()


func _on_btn_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")


func _on_btn_scores_pressed() -> void:
	_scores_screen.open()


func _on_btn_settings_pressed() -> void:
	_settings_screen.open()


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
