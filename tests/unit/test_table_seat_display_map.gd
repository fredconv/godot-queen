class_name TableSeatDisplayMapTest
extends GdUnitTestSuite


const __source = "res://scripts/ui/table/table_seat_display_map.gd"


#region mapping
func test_visual_slot_rotates_with_pivot() -> void:
	assert_int(TableSeatDisplayMap.visual_slot_for_logical_seat(0, 0)).is_equal(0)
	assert_int(TableSeatDisplayMap.visual_slot_for_logical_seat(1, 0)).is_equal(1)
	assert_int(TableSeatDisplayMap.visual_slot_for_logical_seat(2, 1)).is_equal(1)
	assert_int(TableSeatDisplayMap.visual_slot_for_logical_seat(1, 1)).is_equal(0)


func test_logical_seat_round_trip() -> void:
	for pivot in range(HeartsRules.PLAYER_COUNT):
		for visual_slot in range(HeartsRules.PLAYER_COUNT):
			var logical: int = TableSeatDisplayMap.logical_seat_for_visual_slot(visual_slot, pivot)
			assert_int(TableSeatDisplayMap.visual_slot_for_logical_seat(logical, pivot)).is_equal(visual_slot)
#endregion
