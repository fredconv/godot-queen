class_name ClientMatchController
extends MatchControllerBase
## Contrôleur client : envoie les intentions au host, état synchronisé par RPC.


var match_controller: LocalMatchController


func _init(local_controller: LocalMatchController = null) -> void:
	match_controller = local_controller if local_controller != null else LocalMatchController.new()


func start_new_match(seed_value: int = -1) -> void:
	match_controller.start_new_match(seed_value)


func submit_action(action: PlayerAction) -> ActionResult:
	if action is PlayCardAction:
		NetworkMatchRelay.rpc_request_play_card.rpc(action.to_dict())
		var pending := ActionResult.new()
		pending.success = false
		pending.error_code = ActionResult.ERROR_PENDING
		return pending
	return match_controller.submit_action(action)


func get_public_snapshot() -> PublicGameSnapshot:
	return match_controller.get_public_snapshot()


func get_private_snapshot(player_index: int) -> PrivatePlayerSnapshot:
	return match_controller.get_private_snapshot(player_index)


func get_match_manager() -> MatchManager:
	return match_controller.match_manager
