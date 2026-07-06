class_name MatchControllerBase
extends RefCounted
## Interface commune pour piloter une partie (local ou réseau autoritaire).


func start_new_match(seed_value: int = -1) -> void:
	pass


func submit_action(_action: PlayerAction) -> ActionResult:
	return ActionResult.new()


func get_public_snapshot() -> PublicGameSnapshot:
	return PublicGameSnapshot.new()


func get_private_snapshot(_player_index: int) -> PrivatePlayerSnapshot:
	return PrivatePlayerSnapshot.new()


func get_match_manager() -> MatchManager:
	return null
