class_name MultiplayerLobbySessions
extends RefCounted
## Helpers liste de sessions du lobby multi (IDEA-00010).


static func apply_list_contrast(sessions_list: ItemList) -> void:
	if sessions_list == null:
		return
	var list_bg := StyleBoxFlat.new()
	list_bg.bg_color = Color(0.06, 0.08, 0.1, 1.0)
	list_bg.set_border_width_all(2)
	list_bg.border_color = UiPalette.GOLD
	list_bg.content_margin_left = 6.0
	list_bg.content_margin_top = 4.0
	list_bg.content_margin_right = 6.0
	list_bg.content_margin_bottom = 4.0
	sessions_list.add_theme_stylebox_override("panel", list_bg)
	sessions_list.add_theme_color_override("font_color", UiPalette.CREAM)
	sessions_list.add_theme_color_override("font_hovered_color", UiPalette.GOLD_BRIGHT)
	sessions_list.add_theme_color_override("font_selected_color", Color(0.05, 0.05, 0.05, 1.0))
	var selected_bg := StyleBoxFlat.new()
	selected_bg.bg_color = UiPalette.GOLD
	sessions_list.add_theme_stylebox_override("selected", selected_bg)
	sessions_list.add_theme_stylebox_override("selected_focus", selected_bg)
	var hover_bg := StyleBoxFlat.new()
	hover_bg.bg_color = Color(0.18, 0.2, 0.24, 1.0)
	sessions_list.add_theme_stylebox_override("hovered", hover_bg)


static func collect_visible(online_search_active: bool) -> Array[Dictionary]:
	var sessions: Array[Dictionary] = []
	if online_search_active:
		for session: Dictionary in NetworkService.get_online_search_results():
			sessions.append(session)
	else:
		for session: Dictionary in NetworkService.get_lan_sessions():
			var entry: Dictionary = session.duplicate()
			entry["source"] = "lan"
			sessions.append(entry)
	return sessions


static func format_label(session: Dictionary) -> String:
	if str(session.get("source", "")) == "online":
		return TranslationServer.translate(MenuKeys.MP_SESSION_ENTRY_ONLINE) % [
			session.get("host_name", ""),
			session.get("players", 1),
			session.get("max_players", HeartsRules.PLAYER_COUNT),
			session.get("invite_code", ""),
		]
	return TranslationServer.translate(MenuKeys.MP_SESSION_ENTRY) % [
		session.get("host_name", session.get("address", "")),
		session.get("players", 1),
		session.get("max_players", HeartsRules.PLAYER_COUNT),
	]


static func selected_id(sessions_list: ItemList) -> String:
	var session: Dictionary = selected_session(sessions_list)
	return str(session.get("id", ""))


static func selected_session(sessions_list: ItemList) -> Dictionary:
	if sessions_list == null:
		return {}
	var selected_items: PackedInt32Array = sessions_list.get_selected_items()
	if selected_items.is_empty():
		return {}
	var session: Variant = sessions_list.get_item_metadata(selected_items[0])
	if session is Dictionary:
		return session
	return {}


static func refresh_list(sessions_list: ItemList, online_search_active: bool) -> void:
	if sessions_list == null:
		return
	var keep_id: String = selected_id(sessions_list)
	sessions_list.clear()
	for session: Dictionary in collect_visible(online_search_active):
		var item_index: int = sessions_list.add_item(format_label(session))
		sessions_list.set_item_metadata(item_index, session)
		if str(session.get("id", "")) == keep_id:
			sessions_list.select(item_index)
