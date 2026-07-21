class_name ModalOverlayScreen
extends Control
## Base des écrans modaux plein écran (menu overlays).
## Open/close : fade backdrop + scale panel via UiOffsetAnim (Godot 4.7).


signal closed

const OPEN_SEC: float = UiOffsetAnim.MODAL_OPEN_SEC
const CLOSE_SEC: float = UiOffsetAnim.MODAL_CLOSE_SEC

var _backdrop: Control = null
var _panel: Control = null
var _anim_tween: Tween = null
var _is_closing: bool = false
var _is_opening: bool = false


func _ready() -> void:
	visible = false
	_backdrop = get_node_or_null("Backdrop") as Control
	_panel = get_node_or_null("Panel") as Control
	if _panel != null:
		UiStyleFactory.apply_pixel_panel(_panel, UiStyleFactory.pixel_overlay_panel_style())
	_reset_visual_state()


func open() -> void:
	if _is_closing:
		_finish_close_immediate()
	UiOffsetAnim.kill_tween(_anim_tween)
	_anim_tween = null
	_is_closing = false
	_is_opening = true
	_before_open()
	_reset_visual_state()
	show()
	_anim_tween = UiOffsetAnim.play_modal_open(self, _backdrop, _panel, OPEN_SEC)
	if _anim_tween != null:
		_anim_tween.finished.connect(_on_open_anim_finished, CONNECT_ONE_SHOT)
	else:
		_on_open_anim_finished()
	call_deferred("_on_overlay_opened")


func close() -> void:
	if not visible or _is_closing:
		return
	_is_closing = true
	_is_opening = false
	UiOffsetAnim.kill_tween(_anim_tween)
	_anim_tween = UiOffsetAnim.play_modal_close(self, _backdrop, _panel, CLOSE_SEC)
	if _anim_tween != null:
		_anim_tween.finished.connect(_finish_close, CONNECT_ONE_SHOT)
	else:
		_finish_close()


func _before_open() -> void:
	pass


func _on_overlay_opened() -> void:
	pass


func _on_open_anim_finished() -> void:
	_is_opening = false
	_anim_tween = null


func _finish_close() -> void:
	_anim_tween = null
	_finish_close_immediate()


func _finish_close_immediate() -> void:
	hide()
	_reset_visual_state()
	_is_closing = false
	_is_opening = false
	closed.emit()


func _reset_visual_state() -> void:
	if _backdrop != null and is_instance_valid(_backdrop):
		_backdrop.modulate = Color(1, 1, 1, 1)
	if _panel != null and is_instance_valid(_panel):
		_panel.modulate = Color(1, 1, 1, 1)
		UiOffsetAnim.reset_scale(_panel)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _is_closing:
		return
	if UiFocusNav.is_cancel_pressed(event):
		close()
		get_viewport().set_input_as_handled()
