extends Node
## StatsService (autoload)
## Statistiques de partie persistées localement via `SaveService`.
## Écoute `GameEvents.match_ended` pour enregistrer victoire/défaite du joueur humain.
## Les runs de simulation batch désactivent `MatchManager.emit_game_events` pour
## ne pas polluer ces stats.

const StatsStoreClass = preload("res://scripts/core/stats_store.gd")

var _stats: Dictionary = StatsStoreClass.default_stats()
var _loaded: bool = false


func _ready() -> void:
	_ensure_loaded()
	GameEvents.match_ended.connect(_on_match_ended)


func get_stats() -> Dictionary:
	_ensure_loaded()
	return _stats.duplicate()


func get_win_rate_percent() -> int:
	_ensure_loaded()
	return StatsStoreClass.win_rate_percent(_stats)


func reset_stats() -> void:
	_ensure_loaded()
	_stats = StatsStoreClass.default_stats()
	_save_stats()


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var data: Dictionary = SaveService.load_document()
	_stats = StatsStoreClass.normalize(data.get(GameSaveStore.KEY_STATS, {}))


func _save_stats() -> void:
	var data: Dictionary = SaveService.load_document()
	data[GameSaveStore.KEY_STATS] = _stats.duplicate()
	SaveService.save_document(data)


func _on_match_ended(winner_id: int) -> void:
	_ensure_loaded()
	_stats = StatsStoreClass.record_match_end(_stats, winner_id)
	_save_stats()
