class_name LocaleAware
extends RefCounted
## Utilitaires pour les écrans réactifs au changement de langue.
## Brancher via `LocaleAware.bind(node, refresh_callable)` ; les clés vivent
## dans `scripts/core/i18n/keys/*` et les CSV de `translations/`.

const META_REFRESH_CALLABLE: StringName = &"_locale_refresh_callable"

static var _dispatcher_connected: bool = false


static func bind(node: Node, refresh_callable: Callable) -> void:
	if not node.is_in_group("locale_aware"):
		node.add_to_group("locale_aware")
	node.set_meta(META_REFRESH_CALLABLE, refresh_callable)
	_ensure_dispatcher()


static func refresh_all() -> void:
	_dispatch_locale_changed(ConfigService.get_language())


static func focus_first_focusable(root: Control) -> void:
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


static func _ensure_dispatcher() -> void:
	if _dispatcher_connected:
		return
	ConfigService.locale_changed.connect(_dispatch_locale_changed)
	_dispatcher_connected = true


static func _dispatch_locale_changed(_locale: String = "") -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	for node in tree.get_nodes_in_group("locale_aware"):
		if not is_instance_valid(node) or not node.has_meta(META_REFRESH_CALLABLE):
			continue
		var refresh_callable: Callable = node.get_meta(META_REFRESH_CALLABLE)
		if refresh_callable.is_valid():
			refresh_callable.call()
