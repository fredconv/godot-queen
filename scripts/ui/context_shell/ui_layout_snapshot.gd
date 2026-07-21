class_name UiLayoutSnapshot
extends RefCounted
## Snapshot temporaire UI chrome (Focus Mode / restore). Pas de secrets gameplay.


var sidebar_open: bool = false
var shell_focus: bool = false
var user_hide_bottom_bar: bool = false
var bottom_bar_slot_active: bool = false


func duplicate_snapshot() -> UiLayoutSnapshot:
	var copy := UiLayoutSnapshot.new()
	copy.sidebar_open = sidebar_open
	copy.shell_focus = shell_focus
	copy.user_hide_bottom_bar = user_hide_bottom_bar
	copy.bottom_bar_slot_active = bottom_bar_slot_active
	return copy


func to_dict() -> Dictionary:
	return {
		"sidebar_open": sidebar_open,
		"shell_focus": shell_focus,
		"user_hide_bottom_bar": user_hide_bottom_bar,
		"bottom_bar_slot_active": bottom_bar_slot_active,
	}


static func from_dict(data: Dictionary) -> UiLayoutSnapshot:
	var snap := UiLayoutSnapshot.new()
	snap.sidebar_open = bool(data.get("sidebar_open", false))
	snap.shell_focus = bool(data.get("shell_focus", false))
	snap.user_hide_bottom_bar = bool(data.get("user_hide_bottom_bar", false))
	snap.bottom_bar_slot_active = bool(data.get("bottom_bar_slot_active", false))
	return snap
