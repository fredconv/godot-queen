class_name MultiplayerMatchController
extends MatchControllerBase
## Contrôleur autoritaire côté host (stub phase 7+). Délègue au local pour l'instant.


var _local_controller: LocalMatchController


func _init(local_controller: LocalMatchController = null) -> void:
	_local_controller = local_controller if local_controller != null else LocalMatchController.new()


func submit_action(action: PlayerAction) -> ActionResult:
	return _local_controller.submit_action(action)


func get_public_snapshot() -> PublicGameSnapshot:
	return _local_controller.get_public_snapshot()


func get_private_snapshot(player_index: int) -> PrivatePlayerSnapshot:
	return _local_controller.get_private_snapshot(player_index)


func get_match_manager() -> MatchManager:
	return _local_controller.get_match_manager()
