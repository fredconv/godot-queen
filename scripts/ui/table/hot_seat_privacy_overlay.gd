class_name HotSeatPrivacyOverlay
extends Control
## Overlay plein écran : passage d'appareil entre joueurs hot seat.


signal handoff_acknowledged

@onready var _title_label: Label = $Backdrop/Panel/Margin/VBox/TitleLabel
@onready var _hint_label: Label = $Backdrop/Panel/Margin/VBox/HintLabel

var _player_name: String = ""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	LocaleAware.bind(self, _refresh_locale)


func show_handoff(player_name: String) -> void:
	_player_name = player_name
	_refresh_locale()
	visible = true


func close_overlay() -> void:
	visible = false


func _refresh_locale() -> void:
	if _player_name.is_empty():
		return
	_title_label.text = tr(TableKeys.HOT_SEAT_PASS_TITLE) % _player_name
	_hint_label.text = tr(TableKeys.HOT_SEAT_PASS_HINT)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_SPACE or key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
			handoff_acknowledged.emit()
			close_overlay()
			get_viewport().set_input_as_handled()
