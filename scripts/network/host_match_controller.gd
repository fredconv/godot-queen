class_name HostMatchController
extends MatchControllerBase
## Contrôleur autoritaire côté host : applique localement et diffuse aux clients.


var match_controller: LocalMatchController


func _init(local_controller: LocalMatchController = null) -> void:
	match_controller = local_controller if local_controller != null else LocalMatchController.new()


func start_new_match(seed_value: int = -1) -> void:
	match_controller.start_new_match(seed_value)


func submit_action(action: PlayerAction) -> ActionResult:
	var result: ActionResult = match_controller.submit_action(action)
	if result.success and NetworkService.is_online() and action is PlayCardAction:
		NetworkMatchRelay.broadcast_play_from_host(action as PlayCardAction, result)
	return result


func get_public_snapshot() -> PublicGameSnapshot:
	return match_controller.get_public_snapshot()


func get_private_snapshot(player_index: int) -> PrivatePlayerSnapshot:
	return match_controller.get_private_snapshot(player_index)


func get_match_manager() -> MatchManager:
	return match_controller.match_manager
