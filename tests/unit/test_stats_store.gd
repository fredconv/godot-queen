class_name StatsStoreTest
extends GdUnitTestSuite


const __source = "res://scripts/core/stats_store.gd"
const StatsStoreClass = preload("res://scripts/core/stats_store.gd")


#region normalize
func test_normalize_defaults_for_invalid_input() -> void:
	assert_dict(StatsStoreClass.normalize(null)).is_equal(StatsStoreClass.default_stats())


func test_normalize_clamps_negative_values() -> void:
	var stats := StatsStoreClass.normalize({
		StatsStoreClass.KEY_MATCHES_PLAYED: -3,
		StatsStoreClass.KEY_MATCHES_WON: -1,
		StatsStoreClass.KEY_MATCHES_LOST: -2,
	})
	assert_dict(stats).is_equal(StatsStoreClass.default_stats())
#endregion


#region record_match_end
func test_record_match_end_increments_win() -> void:
	var stats := StatsStoreClass.record_match_end(StatsStoreClass.default_stats(), 0)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_PLAYED, 1)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_WON, 1)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_LOST, 0)


func test_record_match_end_increments_loss() -> void:
	var stats := StatsStoreClass.record_match_end(StatsStoreClass.default_stats(), 2)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_PLAYED, 1)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_WON, 0)
	assert_dict(stats).contains_key_value(StatsStoreClass.KEY_MATCHES_LOST, 1)
#endregion


#region win_rate_percent
func test_win_rate_percent_is_zero_when_no_matches() -> void:
	assert_int(StatsStoreClass.win_rate_percent(StatsStoreClass.default_stats())).is_equal(0)


func test_win_rate_percent_rounds_to_nearest_integer() -> void:
	var stats := {
		StatsStoreClass.KEY_MATCHES_PLAYED: 3,
		StatsStoreClass.KEY_MATCHES_WON: 1,
		StatsStoreClass.KEY_MATCHES_LOST: 2,
	}
	assert_int(StatsStoreClass.win_rate_percent(stats)).is_equal(33)
#endregion
