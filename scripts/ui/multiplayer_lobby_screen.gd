extends ModalOverlayScreen
## Lobby multijoueur LAN : héberger ou rejoindre une partie ENet.


signal match_starting

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _status_label: Label = $Panel/Margin/VBox/StatusLabel
@onready var _address_label: Label = $Panel/Margin/VBox/AddressRow/AddressLabel
@onready var _address_edit: LineEdit = $Panel/Margin/VBox/AddressRow/AddressEdit
@onready var _port_label: Label = $Panel/Margin/VBox/PortRow/PortLabel
@onready var _port_edit: LineEdit = $Panel/Margin/VBox/PortRow/PortEdit
@onready var _btn_host: NinePatchButton = $Panel/Margin/VBox/BtnHost
@onready var _btn_join: NinePatchButton = $Panel/Margin/VBox/BtnJoin
@onready var _btn_start: NinePatchButton = $Panel/Margin/VBox/BtnStart
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack

var _is_hosting: bool = false
var _is_joining: bool = false


func _ready() -> void:
	super._ready()
	UiFocusNav.chain_vertical([
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
	LocaleAware.bind(self, _refresh_locale)


func _before_open() -> void:
	_is_hosting = false
	_is_joining = false
	_address_edit.text = "127.0.0.1"
	_port_edit.text = str(NetworkService.DEFAULT_PORT)
	_btn_start.visible = false
	_btn_start.disabled = true
	_btn_host.disabled = false
	_btn_join.disabled = false
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_host.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.MP_TITLE)
	_address_label.text = tr(MenuKeys.MP_ADDRESS)
	_port_label.text = tr(MenuKeys.MP_PORT)
	_btn_host.set_button_text(tr(MenuKeys.MP_HOST))
	_btn_join.set_button_text(tr(MenuKeys.MP_JOIN))
	_btn_start.set_button_text(tr(MenuKeys.MP_START))
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	_refresh_status()


func _refresh_status() -> void:
	if _is_hosting:
		_status_label.text = tr(MenuKeys.MP_HOSTING_STATUS) % [
			_port_edit.text,
			NetworkService.get_connected_human_count(),
		]
	elif _is_joining and NetworkService.is_online():
		_status_label.text = tr(MenuKeys.MP_CONNECTED_STATUS)
	elif _is_joining:
		_status_label.text = tr(MenuKeys.MP_CONNECTING_STATUS)
	else:
		_status_label.text = tr(MenuKeys.MP_LOBBY_HINT)


func _get_port() -> int:
	return clampi(int(_port_edit.text), 1, 65535)


func _on_btn_host_pressed() -> void:
	if _is_hosting or _is_joining:
		return
	var error_code: Error = NetworkService.host_game(_get_port())
	if error_code != OK:
		_status_label.text = tr(MenuKeys.MP_ERROR_HOST) % error_string(error_code)
		return
	_is_hosting = true
	_btn_host.disabled = true
	_btn_join.disabled = true
	_btn_start.visible = true
	_btn_start.disabled = false
	_refresh_status()


func _on_btn_join_pressed() -> void:
	if _is_hosting or _is_joining:
		return
	var error_code: Error = NetworkService.join_game(_address_edit.text.strip_edges(), _get_port())
	if error_code != OK:
		_status_label.text = tr(MenuKeys.MP_ERROR_JOIN) % error_string(error_code)
		return
	_is_joining = true
	_btn_host.disabled = true
	_btn_join.disabled = true
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
	_refresh_status()


func _on_connection_failed() -> void:
	_is_joining = false
	_btn_host.disabled = false
	_btn_join.disabled = false
	_status_label.text = tr(MenuKeys.MP_ERROR_CONNECTION)


func _on_lobby_state_changed() -> void:
	_refresh_status()


func _on_match_start_received(_seed_value: int, _launch_config: MatchLaunchConfig) -> void:
	close()
	match_starting.emit()
	get_tree().change_scene_to_file(TableConstants.TABLE_SCENE_PATH)
