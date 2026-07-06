class_name LobbyServiceTest
extends GdUnitTestSuite


const __source = "res://scripts/network/lobby_service.gd"
const SoloSeatSetupClass = preload("res://scripts/network/solo_seat_setup.gd")
const LobbyServiceClass = preload("res://scripts/network/lobby_service.gd")
const LobbyStateClass = preload("res://scripts/network/lobby_state.gd")


#region solo_seats
func test_solo_seat_setup_assigns_human_to_seat_zero() -> void:
	var assignments: Array = SoloSeatSetupClass.create_assignments("Fred", "local_1", "default")
	assert_int(assignments[0].profile.seat_index).is_equal(0)
	assert_bool(assignments[0].profile.is_human).is_true()
	assert_bool(assignments[1].profile.is_ai).is_true()
#endregion


#region lobby
func test_join_lobby_rejects_occupied_seat() -> void:
	var lobby: LobbyService = LobbyServiceClass.new()
	lobby.create_lobby("Host", "id_host")
	var error_code: StringName = lobby.join_lobby_fake(0, "Intruder")
	assert_str(error_code).is_equal(LobbyStateClass.ERROR_SEAT_OCCUPIED)


func test_start_match_requires_ready_humans() -> void:
	var lobby: LobbyService = LobbyServiceClass.new()
	lobby.create_lobby("Host", "id_host")
	assert_str(lobby.can_start_match()).is_equal(LobbyStateClass.ERROR_NOT_READY)
	lobby.set_ready(0, true)
	assert_str(lobby.start_match()).is_equal(LobbyStateClass.ERROR_NONE)
#endregion
