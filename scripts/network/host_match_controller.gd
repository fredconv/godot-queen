class_name HostMatchController
extends MatchControllerBase
## Contrôleur autoritaire côté host : applique localement et diffuse aux clients.


var match_controller: LocalMatchController


func _init(local_controller: LocalMatchController = null) -> void:
	match_controller = local_controller if local_controller != null else LocalMatchController.new()


func start_new_match(seed_value: int = -1) -> void:
	match_controller.start_new_match(seed_value)


func submit_action(action: PlayerAction) -> ActionResult:
	if action is PlayCardAction:
		var play_action: PlayCardAction = action as PlayCardAction
		if _is_seat_blocked(play_action.player_index):
			return _disconnected_action_result()
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


static func _is_seat_blocked(seat_index: int) -> bool:
	if not NetworkService.is_online():
		return false
	return NetworkService.is_player_disconnected(seat_index) \
		or NetworkService.is_seat_pending_reconnect(seat_index)


static func _disconnected_action_result() -> ActionResult:
	var result := ActionResult.new()
	result.success = false
	result.error_code = ActionResult.ERROR_PLAYER_DISCONNECTED
	return result
