extends Node
## GameSession (autoload)
## État minimal de session de jeu : sait si une manche/partie est en cours,
## pour piloter la confirmation de sortie affichée par la table (voir
## `scripts/ui/table.gd`). Écoute aussi `GameEvents.match_started`/
## `match_ended` : un futur `MatchManager` (étape 4 de docs/ROADMAP.md) n'aura
## donc rien de spécial à faire pour tenir ce flag à jour, il suffira
## d'émettre ces signaux (déjà prévus dans `GameEvents`).

var match_in_progress: bool = false
var _pending_launch_config: MatchLaunchConfig = null


func set_launch_config(config: MatchLaunchConfig) -> void:
	_pending_launch_config = config


func take_launch_config() -> MatchLaunchConfig:
	if _pending_launch_config != null:
		var config: MatchLaunchConfig = _pending_launch_config
		_pending_launch_config = null
		return config
	return SeatSetup.create_solo(
		PlayerProfileService.get_display_name(),
		PlayerProfileService.get_player_id()
	)


func has_pending_launch_config() -> bool:
	return _pending_launch_config != null

func _ready() -> void:
	GameEvents.match_started.connect(start_match)
	GameEvents.match_ended.connect(func(_winner_id: int) -> void: end_match())

func start_match() -> void:
	match_in_progress = true

func end_match() -> void:
	match_in_progress = false
