class_name UiFocusNavTest
extends GdUnitTestSuite


const UiFocusNav = preload("res://scripts/core/ui/ui_focus_nav.gd")


#region collect_focusable
func test_collect_focusable_skips_non_focusable_and_disabled() -> void:
	var enabled: Button = auto_free(Button.new()) as Button
	var disabled: Button = auto_free(Button.new()) as Button
	disabled.disabled = true
	var label: Label = auto_free(Label.new()) as Label
	label.focus_mode = Control.FOCUS_NONE
	var focusable := UiFocusNav.collect_focusable([enabled, disabled, label])
	assert_array(focusable).has_size(1)
	assert_that(focusable[0]).is_equal(enabled)
#endregion


#region is_cancel_pressed
func test_is_cancel_pressed_detects_ui_cancel() -> void:
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	assert_bool(UiFocusNav.is_cancel_pressed(event)).is_true()
#endregion
