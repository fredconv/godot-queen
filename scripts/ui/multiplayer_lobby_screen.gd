extends ModalOverlayScreen
## Lobby multijoueur : code d'invitation, recherche par pseudo, découverte LAN.


signal match_starting

const _LOBBY_BUTTON_SIZE := Vector2i(400, 48)
const _PublicIpLookup = preload("res://scripts/network/public_ip_lookup.gd")
const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _status_label: Label = $Panel/Margin/VBox/StatusLabel
@onready var _join_container: VBoxContainer = $Panel/Margin/VBox/JoinContainer
@onready var _invite_code_label: Label = $Panel/Margin/VBox/JoinContainer/InviteCodeLabel
@onready var _invite_code_edit: LineEdit = $Panel/Margin/VBox/JoinContainer/InviteCodeRow/InviteCodeEdit
@onready var _btn_join_code: Button = $Panel/Margin/VBox/JoinContainer/InviteCodeRow/BtnJoinCode
@onready var _search_label: Label = $Panel/Margin/VBox/JoinContainer/SearchLabel
@onready var _search_edit: LineEdit = $Panel/Margin/VBox/JoinContainer/SearchRow/SearchEdit
@onready var _btn_search: Button = $Panel/Margin/VBox/JoinContainer/SearchRow/BtnSearch
@onready var _sessions_label: Label = $Panel/Margin/VBox/SessionsLabel
@onready var _sessions_list: ItemList = $Panel/Margin/VBox/SessionsList
@onready var _host_code_container: VBoxContainer = $Panel/Margin/VBox/HostCodeContainer
@onready var _host_code_label: Label = $Panel/Margin/VBox/HostCodeContainer/HostCodeLabel
@onready var _host_code_edit: LineEdit = $Panel/Margin/VBox/HostCodeContainer/HostCodeRow/HostCodeEdit
@onready var _host_code_hint: Label = $Panel/Margin/VBox/HostCodeContainer/HostCodeHint
@onready var _btn_copy_code: Button = $Panel/Margin/VBox/HostCodeContainer/HostCodeRow/BtnCopyCode
@onready var _advanced_container: VBoxContainer = $Panel/Margin/VBox/AdvancedContainer
@onready var _address_label: Label = $Panel/Margin/VBox/AdvancedContainer/AddressRow/AddressLabel
@onready var _address_edit: LineEdit = $Panel/Margin/VBox/AdvancedContainer/AddressRow/AddressEdit
@onready var _port_label: Label = $Panel/Margin/VBox/AdvancedContainer/PortRow/PortLabel
@onready var _port_edit: LineEdit = $Panel/Margin/VBox/AdvancedContainer/PortRow/PortEdit
@onready var _btn_advanced: Button = $Panel/Margin/VBox/BtnAdvanced
@onready var _btn_host: NinePatchButton = $Panel/Margin/VBox/BtnHost
@onready var _btn_join: NinePatchButton = $Panel/Margin/VBox/BtnJoin
@onready var _btn_start: NinePatchButton = $Panel/Margin/VBox/BtnStart
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack

var _is_hosting: bool = false
var _is_joining: bool = false
var _advanced_visible: bool = false
var _public_ip_lookup: RefCounted
var _cached_public_ip: String = ""
var _online_search_active: bool = false
var _pending_join_by_code: bool = false


func _ready() -> void:
	super._ready()
	UiFocusNav.chain_vertical([
		_invite_code_edit,
		_btn_join_code,
		_search_edit,
		_btn_search,
		_sessions_list,
		_host_code_edit,
		_btn_copy_code,
		_btn_advanced,
		_address_edit,
		_port_edit,
		_btn_host,
		_btn_join,
		_btn_start,
		_btn_back,
	])
	NetworkService.connection_succeeded.connect(_on_connection_succeeded)
	NetworkService.connection_failed.connect(_on_connection_failed)
	NetworkService.lobby_state_changed.connect(_on_lobby_state_changed)
	NetworkService.match_start_received.connect(_on_match_start_received)
	NetworkService.lan_sessions_changed.connect(_on_lan_sessions_changed)
	NetworkService.host_invite_code_changed.connect(_on_host_invite_code_changed)
	NetworkService.online_lobby_lookup_completed.connect(_on_online_lobby_lookup_completed)
	NetworkService.online_lobby_lookup_failed.connect(_on_online_lobby_lookup_failed)
	NetworkService.online_lobby_search_completed.connect(_on_online_lobby_search_completed)
	NetworkService.online_lobby_search_failed.connect(_on_online_lobby_search_failed)
	_sessions_list.item_activated.connect(_on_session_activated)
	_invite_code_edit.text_changed.connect(_on_invite_code_text_changed)
	_apply_sessions_list_contrast()
	LocaleAware.bind(self, _refresh_locale)


func _apply_sessions_list_contrast() -> void:
	var list_bg := StyleBoxFlat.new()
	list_bg.bg_color = Color(0.06, 0.08, 0.1, 1.0)
	list_bg.set_border_width_all(2)
	list_bg.border_color = UiPalette.GOLD
	list_bg.content_margin_left = 6.0
	list_bg.content_margin_top = 4.0
	list_bg.content_margin_right = 6.0
	list_bg.content_margin_bottom = 4.0
	_sessions_list.add_theme_stylebox_override("panel", list_bg)
	_sessions_list.add_theme_color_override("font_color", UiPalette.CREAM)
	_sessions_list.add_theme_color_override("font_hovered_color", UiPalette.GOLD_BRIGHT)
	_sessions_list.add_theme_color_override("font_selected_color", Color(0.05, 0.05, 0.05, 1.0))
	var selected_bg := StyleBoxFlat.new()
	selected_bg.bg_color = UiPalette.GOLD
	_sessions_list.add_theme_stylebox_override("selected", selected_bg)
	_sessions_list.add_theme_stylebox_override("selected_focus", selected_bg)
	var hover_bg := StyleBoxFlat.new()
	hover_bg.bg_color = Color(0.18, 0.2, 0.24, 1.0)
	_sessions_list.add_theme_stylebox_override("hovered", hover_bg)


func _before_open() -> void:
	_is_hosting = false
	_is_joining = false
	_advanced_visible = false
	_online_search_active = false
	_pending_join_by_code = false
	_cached_public_ip = ""
	_invite_code_edit.text = ""
	_search_edit.text = ""
	_address_edit.text = "127.0.0.1"
	_port_edit.text = str(NetworkService.DEFAULT_PORT)
	_btn_start.visible = false
	_btn_start.disabled = true
	_btn_host.disabled = false
	_btn_join.disabled = false
	_set_advanced_visible(false)
	_set_host_code_visible(false)
	_set_join_mode_visible(true)
	_apply_button_sizes()
	_refresh_locale()
	NetworkService.clear_online_search_results()
	NetworkService.start_lan_browsing()
	_start_public_ip_lookup()


func close() -> void:
	_cancel_public_ip_lookup()
	if not _is_hosting and not _is_joining:
		NetworkService.stop_lan_browsing()
	super.close()


func _on_overlay_opened() -> void:
	_invite_code_edit.grab_focus()


func _apply_button_sizes() -> void:
	for button: NinePatchButton in [_btn_host, _btn_join, _btn_start, _btn_back]:
		button.apply_button_size(_LOBBY_BUTTON_SIZE)


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.MP_TITLE)
	_invite_code_label.text = tr(MenuKeys.MP_INVITE_CODE_LABEL)
	_invite_code_edit.placeholder_text = tr(MenuKeys.MP_INVITE_CODE_PLACEHOLDER)
	_search_label.text = tr(MenuKeys.MP_SEARCH_LABEL)
	_search_edit.placeholder_text = tr(MenuKeys.MP_SEARCH_PLACEHOLDER)
	_btn_join_code.text = tr(MenuKeys.MP_BTN_JOIN_CODE)
	_btn_search.text = tr(MenuKeys.MP_BTN_SEARCH)
	_sessions_label.text = tr(MenuKeys.MP_SESSIONS_LABEL)
	_host_code_label.text = tr(MenuKeys.MP_HOST_CODE_LABEL)
	_host_code_hint.text = tr(MenuKeys.MP_HOST_CODE_HINT)
	_btn_copy_code.text = tr(MenuKeys.MP_HOST_SHARE_COPY)
	_address_label.text = tr(MenuKeys.MP_ADDRESS)
	_port_label.text = tr(MenuKeys.MP_PORT)
	_btn_host.set_button_text(tr(MenuKeys.MP_HOST))
	_btn_join.set_button_text(tr(MenuKeys.MP_JOIN))
	_btn_start.set_button_text(tr(MenuKeys.MP_START))
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	_refresh_advanced_toggle_label()
	_refresh_status()
	_refresh_sessions_list()
	_refresh_host_code_display()


func _refresh_advanced_toggle_label() -> void:
	if _advanced_visible:
		_btn_advanced.text = tr(MenuKeys.MP_HIDE_ADVANCED)
	else:
		_btn_advanced.text = tr(MenuKeys.MP_ADVANCED_OPTIONS)


func _refresh_status() -> void:
	if _is_hosting:
		_status_label.text = tr(MenuKeys.MP_HOSTING_STATUS) % NetworkService.get_connected_human_count()
	elif _is_joining and NetworkService.is_online():
		_status_label.text = tr(MenuKeys.MP_CONNECTED_STATUS)
	elif _is_joining:
		_status_label.text = tr(MenuKeys.MP_CONNECTING_STATUS)
	elif not NetworkService.is_online_registry_available():
		_status_label.text = tr(MenuKeys.MP_ONLINE_UNAVAILABLE)
	else:
		_status_label.text = tr(MenuKeys.MP_LOBBY_HINT)
	_refresh_online_join_fields()


func _refresh_online_join_fields() -> void:
	var online_ok: bool = NetworkService.is_online_registry_available()
	var show_online_join: bool = online_ok and not _is_hosting and not _is_joining
	_invite_code_label.visible = show_online_join
	_invite_code_edit.get_parent().visible = show_online_join
	_search_label.visible = show_online_join
	_search_edit.get_parent().visible = show_online_join
	_invite_code_edit.editable = show_online_join
	_btn_join_code.disabled = not show_online_join
	_search_edit.editable = show_online_join
	_btn_search.disabled = not show_online_join


func _refresh_sessions_list() -> void:
	var selected_id: String = _get_selected_session_id()
	_sessions_list.clear()
	var sessions: Array[Dictionary] = _collect_visible_sessions()
	for session: Dictionary in sessions:
		var label: String = _format_session_label(session)
		var item_index: int = _sessions_list.add_item(label)
		_sessions_list.set_item_metadata(item_index, session)
		if str(session.get("id", "")) == selected_id:
			_sessions_list.select(item_index)


func _collect_visible_sessions() -> Array[Dictionary]:
	var sessions: Array[Dictionary] = []
	if _online_search_active:
		for session: Dictionary in NetworkService.get_online_search_results():
			sessions.append(session)
	else:
		for session: Dictionary in NetworkService.get_lan_sessions():
			var entry: Dictionary = session.duplicate()
			entry["source"] = "lan"
			sessions.append(entry)
	return sessions


func _format_session_label(session: Dictionary) -> String:
	if str(session.get("source", "")) == "online":
		return tr(MenuKeys.MP_SESSION_ENTRY_ONLINE) % [
			session.get("host_name", ""),
			session.get("players", 1),
			session.get("max_players", HeartsRules.PLAYER_COUNT),
			session.get("invite_code", ""),
		]
	return tr(MenuKeys.MP_SESSION_ENTRY) % [
		session.get("host_name", session.get("address", "")),
		session.get("players", 1),
		session.get("max_players", HeartsRules.PLAYER_COUNT),
	]


func _refresh_host_code_display() -> void:
	if not _is_hosting:
		return
	_host_code_edit.text = NetworkService.get_host_invite_code()


func _set_host_code_visible(visible_state: bool) -> void:
	_host_code_container.visible = visible_state
	if visible_state:
		_refresh_host_code_display()


func _set_join_mode_visible(visible_state: bool) -> void:
	_join_container.visible = visible_state
	_sessions_label.visible = visible_state
	_sessions_list.visible = visible_state
	_btn_join.visible = visible_state


func _get_selected_session_id() -> String:
	var selected_items: PackedInt32Array = _sessions_list.get_selected_items()
	if selected_items.is_empty():
		return ""
	var session: Variant = _sessions_list.get_item_metadata(selected_items[0])
	if session is Dictionary:
		return str(session.get("id", ""))
	return ""


func _get_selected_session() -> Dictionary:
	var selected_items: PackedInt32Array = _sessions_list.get_selected_items()
	if selected_items.is_empty():
		return {}
	var session: Variant = _sessions_list.get_item_metadata(selected_items[0])
	if session is Dictionary:
		return session
	return {}


func _get_port() -> int:
	return clampi(int(_port_edit.text), 1, 65535)


func _set_advanced_visible(visible_state: bool) -> void:
	_advanced_visible = visible_state
	_advanced_container.visible = visible_state
	_refresh_advanced_toggle_label()


func _start_public_ip_lookup() -> void:
	_cancel_public_ip_lookup()
	_public_ip_lookup = _PublicIpLookup.new()
	_public_ip_lookup.lookup_succeeded.connect(_on_public_ip_lookup_succeeded)
	_public_ip_lookup.lookup_failed.connect(_on_public_ip_lookup_failed)
	_public_ip_lookup.fetch(self)


func _cancel_public_ip_lookup() -> void:
	if _public_ip_lookup != null:
		if _public_ip_lookup.lookup_succeeded.is_connected(_on_public_ip_lookup_succeeded):
			_public_ip_lookup.lookup_succeeded.disconnect(_on_public_ip_lookup_succeeded)
		if _public_ip_lookup.lookup_failed.is_connected(_on_public_ip_lookup_failed):
			_public_ip_lookup.lookup_failed.disconnect(_on_public_ip_lookup_failed)
		_public_ip_lookup = null


func _on_public_ip_lookup_succeeded(public_ip: String) -> void:
	_cached_public_ip = public_ip
	_cancel_public_ip_lookup()
	if _is_hosting:
		NetworkService.set_host_public_address(public_ip)


func _on_public_ip_lookup_failed() -> void:
	_cancel_public_ip_lookup()


func _on_invite_code_text_changed(new_text: String) -> void:
	var cursor: int = _invite_code_edit.caret_column
	var normalized: String = _InviteCodeGenerator.normalize_raw(new_text)
	if normalized.length() <= 4:
		_invite_code_edit.text = normalized
	elif normalized.length() <= 8:
		_invite_code_edit.text = "%s-%s" % [normalized.substr(0, 4), normalized.substr(4)]
	else:
		_invite_code_edit.text = _InviteCodeGenerator.format_code(normalized.substr(0, 8))
	_invite_code_edit.caret_column = mini(cursor + 1, _invite_code_edit.text.length())


func _on_btn_advanced_pressed() -> void:
	_set_advanced_visible(not _advanced_visible)


func _on_btn_copy_code_pressed() -> void:
	var code: String = _host_code_edit.text.strip_edges()
	if code.is_empty():
		return
	DisplayServer.clipboard_set(code)
	_btn_copy_code.text = tr(MenuKeys.MP_HOST_SHARE_COPIED)
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(_btn_copy_code):
		_btn_copy_code.text = tr(MenuKeys.MP_HOST_SHARE_COPY)


func _on_btn_join_code_pressed() -> void:
	if _is_hosting or _is_joining:
		return
	if not NetworkService.is_online_registry_available():
		_status_label.text = tr(MenuKeys.MP_ONLINE_UNAVAILABLE)
		return
	var invite_code: String = _InviteCodeGenerator.normalize_input(_invite_code_edit.text)
	if invite_code.is_empty():
		_status_label.text = tr(MenuKeys.MP_INVITE_NOT_FOUND)
		return
	_pending_join_by_code = true
	_status_label.text = tr(MenuKeys.MP_CONNECTING_STATUS)
	NetworkService.lookup_lobby_by_invite_code(invite_code)


func _on_btn_search_pressed() -> void:
	if _is_hosting or _is_joining:
		return
	if not NetworkService.is_online_registry_available():
		_status_label.text = tr(MenuKeys.MP_ONLINE_UNAVAILABLE)
		return
	var query: String = _search_edit.text.strip_edges()
	if query.length() < 2:
		_status_label.text = tr(MenuKeys.MP_SEARCH_EMPTY)
		return
	_online_search_active = true
	NetworkService.search_lobbies_by_host_name(query)


func _on_btn_host_pressed() -> void:
	if _is_hosting or _is_joining:
		return
	NetworkService.stop_lan_browsing()
	var error_code: Error = NetworkService.host_game(_get_port())
	if error_code != OK:
		NetworkService.start_lan_browsing()
		_status_label.text = tr(MenuKeys.MP_ERROR_HOST) % error_string(error_code)
		return
	_is_hosting = true
	_btn_host.disabled = true
	_btn_join.disabled = true
	_btn_advanced.visible = false
	_advanced_container.visible = false
	_btn_start.visible = true
	_btn_start.disabled = false
	_set_join_mode_visible(false)
	_set_host_code_visible(true)
	_refresh_host_code_display()
	if not _cached_public_ip.is_empty():
		NetworkService.set_host_public_address(_cached_public_ip)
	elif NetworkService.is_online_registry_available():
		_start_public_ip_lookup()
	_refresh_status()


func _on_btn_join_pressed() -> void:
	_join_selected_or_manual()


func _on_session_activated(_index: int) -> void:
	_join_selected_or_manual()


func _join_selected_or_manual() -> void:
	if _is_hosting or _is_joining:
		return
	var session: Dictionary = _get_selected_session()
	if not session.is_empty():
		_connect_to_session(session)
		return
	if _advanced_visible:
		var address: String = _address_edit.text.strip_edges()
		if address.is_empty():
			_status_label.text = tr(MenuKeys.MP_ERROR_NO_SESSION)
			return
		_connect_to_session({
			"address": address,
			"port": _get_port(),
		})
		return
	_status_label.text = tr(MenuKeys.MP_ERROR_NO_SESSION)


func _connect_to_session(session: Dictionary) -> void:
	var address: String = str(session.get("address", "")).strip_edges()
	var port: int = int(session.get("port", NetworkService.DEFAULT_PORT))
	if address.is_empty():
		_status_label.text = tr(MenuKeys.MP_ERROR_NO_SESSION)
		return
	NetworkService.stop_lan_browsing()
	var error_code: Error = NetworkService.join_game(address, port)
	if error_code != OK:
		NetworkService.start_lan_browsing()
		_status_label.text = tr(MenuKeys.MP_ERROR_JOIN) % error_string(error_code)
		_pending_join_by_code = false
		return
	_is_joining = true
	_btn_host.disabled = true
	_btn_join.disabled = true
	_btn_join_code.disabled = true
	_btn_search.disabled = true
	_refresh_status()


func _on_btn_start_pressed() -> void:
	if not _is_hosting:
		return
	var error_code: Error = NetworkService.host_start_match()
	if error_code != OK:
		_status_label.text = tr(MenuKeys.MP_ERROR_START) % error_string(error_code)
		return
	close()
	match_starting.emit()
	get_tree().change_scene_to_file(TableConstants.TABLE_SCENE_PATH)


func _on_btn_back_pressed() -> void:
	if NetworkService.is_online():
		NetworkService.disconnect_from_host()
	close()


func _on_connection_succeeded() -> void:
	_pending_join_by_code = false
	_refresh_status()


func _on_connection_failed() -> void:
	_is_joining = false
	_pending_join_by_code = false
	_btn_host.disabled = false
	_btn_join.disabled = false
	_btn_join_code.disabled = false
	_btn_search.disabled = false
	NetworkService.start_lan_browsing()
	_refresh_status()


func _on_lobby_state_changed() -> void:
	_refresh_status()
	_refresh_sessions_list()


func _on_lan_sessions_changed() -> void:
	if not _online_search_active:
		_refresh_sessions_list()


func _on_host_invite_code_changed(_invite_code: String) -> void:
	_refresh_host_code_display()


func _on_online_lobby_lookup_completed(session: Dictionary) -> void:
	if not _pending_join_by_code:
		return
	_connect_to_session(session)


func _on_online_lobby_lookup_failed() -> void:
	_pending_join_by_code = false
	_status_label.text = tr(MenuKeys.MP_INVITE_NOT_FOUND)


func _on_online_lobby_search_completed(_sessions: Array) -> void:
	_refresh_sessions_list()
	if _sessions.is_empty():
		_status_label.text = tr(MenuKeys.MP_SEARCH_EMPTY)
	else:
		_refresh_status()


func _on_online_lobby_search_failed() -> void:
	_refresh_sessions_list()
	_status_label.text = tr(MenuKeys.MP_SEARCH_EMPTY)


func _on_match_start_received(_seed_value: int, _launch_config: MatchLaunchConfig) -> void:
	close()
	match_starting.emit()
	get_tree().change_scene_to_file(TableConstants.TABLE_SCENE_PATH)
