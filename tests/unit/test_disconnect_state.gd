class_name DisconnectStateTest
extends GdUnitTestSuite


const __source = "res://scripts/network/disconnect_state.gd"


#region disconnect
func test_begin_disconnect_marks_seat_pending() -> void:
	var state := DisconnectState.new()
	state.begin_disconnect(2, "Alice", "pid_alice")
	assert_bool(state.is_pending(2)).is_true()
	assert_float(state.get_remaining_sec(2)).is_equal_approx(DisconnectState.GRACE_PERIOD_SEC, 0.01)


func test_cancel_reconnect_clears_pending() -> void:
	var state := DisconnectState.new()
	state.begin_disconnect(1, "Bob", "pid_bob")
	assert_bool(state.cancel_reconnect(1)).is_true()
	assert_bool(state.is_pending(1)).is_false()


func test_tick_expires_after_grace_period() -> void:
	var state := DisconnectState.new()
	state.begin_disconnect(0, "Carol", "pid_carol")
	var expired: Array[int] = state.tick(DisconnectState.GRACE_PERIOD_SEC)
	assert_array(expired).contains_exactly(0)


func test_find_pending_seat_by_player_id() -> void:
	var state := DisconnectState.new()
	state.begin_disconnect(3, "Dan", "pid_dan")
	assert_int(state.find_pending_seat_by_player_id("pid_dan")).is_equal(3)
	assert_int(state.find_pending_seat_by_player_id("other")).is_equal(-1)
#endregion
