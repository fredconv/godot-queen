class_name ActionResult
extends RefCounted
## Résultat d'application d'une action côté moteur autoritaire.

const ERROR_NONE: StringName = &""
const ERROR_WRONG_PHASE: StringName = &"wrong_phase"
const ERROR_NOT_YOUR_TURN: StringName = &"not_your_turn"
const ERROR_RULE_VIOLATION: StringName = &"rule_violation"
const ERROR_INVALID_ACTION: StringName = &"invalid_action"
const ERROR_PENDING: StringName = &"pending"
const ERROR_PLAYER_DISCONNECTED: StringName = &"player_disconnected"

var success: bool = false
var error_code: StringName = ERROR_NONE
var message: String = ""
var play_result: MatchManager.PlayResult = null
var public_events: Array[GameEvent] = []


static func from_play_result(
	source_play_result: MatchManager.PlayResult,
	events: Array[GameEvent] = []
) -> ActionResult:
	var result := ActionResult.new()
	result.play_result = source_play_result
	result.public_events = events
	result.success = source_play_result.success
	if not source_play_result.success:
		match source_play_result.play_error:
			MatchManager.PlayError.WRONG_PHASE:
				result.error_code = ERROR_WRONG_PHASE
			MatchManager.PlayError.NOT_YOUR_TURN:
				result.error_code = ERROR_NOT_YOUR_TURN
			MatchManager.PlayError.RULE_VIOLATION:
				result.error_code = ERROR_RULE_VIOLATION
			_:
				result.error_code = ERROR_INVALID_ACTION
	return result
