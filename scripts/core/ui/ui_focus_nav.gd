class_name UiFocusNav
extends RefCounted
## Utilitaires de navigation clavier / manette (focus voisin, Échap, focus initial).


static func collect_focusable(controls: Array) -> Array[Control]:
	var result: Array[Control] = []
	for item in controls:
		var control := item as Control
		if control == null:
			continue
		if control.focus_mode == Control.FOCUS_NONE:
			continue
		if control is BaseButton and (control as BaseButton).disabled:
			continue
		result.append(control)
	return result


static func chain_horizontal(controls: Array) -> void:
	_chain_neighbors(controls, true)


static func chain_vertical(controls: Array) -> void:
	_chain_neighbors(controls, false)


static func grab_first(controls: Array) -> void:
	var focusable := collect_focusable(controls)
	if focusable.is_empty():
		return
	focusable[0].call_deferred("grab_focus")


static func grab_last(controls: Array) -> void:
	var focusable := collect_focusable(controls)
	if focusable.is_empty():
		return
	focusable[focusable.size() - 1].call_deferred("grab_focus")


static func is_cancel_pressed(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_cancel")


static func _chain_neighbors(controls: Array, horizontal: bool) -> void:
	var focusable := collect_focusable(controls)
	if focusable.size() < 2:
		return
	for index in focusable.size():
		var current: Control = focusable[index]
		var previous: Control = focusable[(index - 1 + focusable.size()) % focusable.size()]
		var next: Control = focusable[(index + 1) % focusable.size()]
		if horizontal:
			current.focus_neighbor_left = previous.get_path()
			current.focus_neighbor_right = next.get_path()
		else:
			current.focus_neighbor_top = previous.get_path()
			current.focus_neighbor_bottom = next.get_path()
