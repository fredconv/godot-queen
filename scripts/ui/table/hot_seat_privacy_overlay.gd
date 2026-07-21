class_name HotSeatPrivacyOverlay
extends Control
## Overlay plein écran : passage d'appareil entre joueurs hot seat.
## Validation par maintien de la touche Espace (~1,5 s) avec barre de progression.


signal handoff_acknowledged

const HOLD_DURATION_SEC: float = 1.5

@onready var _title_label: Label = $Backdrop/Panel/Margin/VBox/TitleLabel
@onready var _hint_label: Label = $Backdrop/Panel/Margin/VBox/HintLabel
@onready var _progress_label: Label = $Backdrop/Panel/Margin/VBox/ProgressLabel
@onready var _progress_bar: ProgressBar = $Backdrop/Panel/Margin/VBox/ProgressBar

var _player_name: String = ""
var _hold_elapsed_sec: float = 0.0
var _space_held: bool = false


func _ready() -> void:
	visible = false
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_STOP
	LocaleAware.bind(self, _refresh_locale)


func show_handoff(player_name: String) -> void:
	_player_name = player_name
	_reset_hold_progress()
	_refresh_locale()
	visible = true
	set_process(true)


func close_overlay() -> void:
	visible = false
	set_process(false)
	_reset_hold_progress()


func _process(delta: float) -> void:
	if not _space_held:
		return
	_hold_elapsed_sec += delta
	_update_progress_display()
	if _hold_elapsed_sec >= HOLD_DURATION_SEC:
		handoff_acknowledged.emit()
		close_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode != KEY_SPACE:
			return
		if key_event.pressed and not key_event.echo:
			_space_held = true
			get_viewport().set_input_as_handled()
		elif not key_event.pressed:
			_reset_hold_progress()
			get_viewport().set_input_as_handled()


func _reset_hold_progress() -> void:
	_hold_elapsed_sec = 0.0
	_space_held = false
	_update_progress_display()


func _update_progress_display() -> void:
	var ratio: float = clampf(_hold_elapsed_sec / HOLD_DURATION_SEC, 0.0, 1.0)
	var percent: int = int(round(ratio * 100.0))
	_progress_bar.value = ratio * 100.0
	_progress_label.text = tr(TableKeys.HOT_SEAT_HOLD_PROGRESS) % percent


func _refresh_locale() -> void:
	if _player_name.is_empty():
		return
	_title_label.text = tr(TableKeys.HOT_SEAT_PASS_TITLE) % _player_name
	_hint_label.text = tr(TableKeys.HOT_SEAT_PASS_HINT)
	_update_progress_display()
