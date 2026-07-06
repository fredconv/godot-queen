extends Node
## Bootstrap
## Scène d'entrée du jeu (`run/main_scene` dans `project.godot`). Vérifie que
## les autoloads sont bien chargés puis enchaîne immédiatement sur le menu
## principal (`scenes/menus/main_menu.tscn`) : la table de jeu ne doit jamais
## être affichée directement au lancement (voir docs/ROADMAP.md Étape 7).
## Ne contient aucune logique de jeu (Hearts).

const MAIN_MENU_SCENE_PATH: String = "res://scenes/menus/main_menu.tscn"

@onready var _status_label: Label = $CanvasLayer/StatusLabel


func _ready() -> void:
	DebugService.log_info("Bootstrap prêt — autoloads chargés.")
	LocaleAware.bind(self, _refresh_locale)
	_refresh_locale()
	call_deferred("_go_to_main_menu")


func _refresh_locale() -> void:
	_status_label.text = tr(GameKeys.BOOTSTRAP_OK)


func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
