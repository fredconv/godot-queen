extends ModalOverlayScreen
## Lobby hot seat : 1 à 4 joueurs locaux sur la même machine.


signal start_requested(config: MatchLaunchConfig)

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _players_label: Label = $Panel/Margin/VBox/PlayersLabel
@onready var _players_option: OptionButton = $Panel/Margin/VBox/PlayersOption
@onready var _name_rows: VBoxContainer = $Panel/Margin/VBox/NameRows
@onready var _name_edits: Array[LineEdit] = [
	$Panel/Margin/VBox/NameRows/NameRow0/NameEdit0,
	$Panel/Margin/VBox/NameRows/NameRow1/NameEdit1,
	$Panel/Margin/VBox/NameRows/NameRow2/NameEdit2,
	$Panel/Margin/VBox/NameRows/NameRow3/NameEdit3,
]
@onready var _name_labels: Array[Label] = [
	$Panel/Margin/VBox/NameRows/NameRow0/NameLabel0,
	$Panel/Margin/VBox/NameRows/NameRow1/NameLabel1,
	$Panel/Margin/VBox/NameRows/NameRow2/NameLabel2,
	$Panel/Margin/VBox/NameRows/NameRow3/NameLabel3,
]
@onready var _btn_start: NinePatchButton = $Panel/Margin/VBox/BtnStart
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	_players_option.item_selected.connect(_on_players_option_selected)
	var focus_chain: Array[Control] = [_players_option]
	for name_edit: LineEdit in _name_edits:
		focus_chain.append(name_edit)
	focus_chain.append(_btn_start)
	focus_chain.append(_btn_back)
	UiFocusNav.chain_vertical(focus_chain)
	LocaleAware.bind(self, _refresh_locale)


func _before_open() -> void:
	_players_option.clear()
	for player_count in range(1, HeartsRules.PLAYER_COUNT + 1):
		_players_option.add_item(str(player_count), player_count)
	_players_option.select(0)
	_name_edits[0].text = PlayerProfileService.get_display_name()
	for seat_index in range(1, HeartsRules.PLAYER_COUNT):
		_name_edits[seat_index].text = "Player %d" % (seat_index + 1)
	_refresh_name_rows()
	_refresh_locale()


func _on_overlay_opened() -> void:
	_players_option.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.HOT_SEAT_TITLE)
	_players_label.text = tr(MenuKeys.HOT_SEAT_PLAYERS)
	_btn_start.set_button_text(tr(MenuKeys.HOT_SEAT_START))
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		_name_labels[seat_index].text = tr(MenuKeys.HOT_SEAT_PLAYER) % (seat_index + 1)


func _on_players_option_selected(_index: int) -> void:
	_refresh_name_rows()


func _refresh_name_rows() -> void:
	var human_count: int = _players_option.get_selected_id()
	for seat_index in range(HeartsRules.PLAYER_COUNT):
		var row: Control = _name_rows.get_child(seat_index)
		row.visible = seat_index < human_count


func _on_btn_start_pressed() -> void:
	var human_count: int = _players_option.get_selected_id()
	var names := PackedStringArray()
	for seat_index in range(human_count):
		var name_text: String = _name_edits[seat_index].text.strip_edges()
		if name_text.is_empty():
			name_text = "Player %d" % (seat_index + 1)
		names.append(name_text)
	var config: MatchLaunchConfig = SeatSetup.create_hot_seat(human_count, names)
	close()
	start_requested.emit(config)


func _on_btn_back_pressed() -> void:
	close()
