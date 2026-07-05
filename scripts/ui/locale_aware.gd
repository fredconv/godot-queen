class_name LocaleAware
extends RefCounted
## Utilitaires pour les écrans réactifs au changement de langue.
## Brancher via `LocaleAware.bind(node, refresh_callable)` ; les clés vivent
## dans `scripts/core/i18n/keys/*` et les CSV de `translations/`.


static func bind(node: Node, refresh_callable: Callable) -> void:
	if not node.is_in_group("locale_aware"):
		node.add_to_group("locale_aware")
	if ConfigService.locale_changed.is_connected(refresh_callable):
		return
	ConfigService.locale_changed.connect(refresh_callable)


static func focus_first_focusable(root: Control) -> void:
	var focus_owner := root.find_child("", true, false) as Control
	if focus_owner == null:
		return
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current is Control:
			var control := current as Control
			if control.visible and control.focus_mode != Control.FOCUS_NONE:
				control.grab_focus()
				return
		for child in current.get_children():
			stack.append(child)
