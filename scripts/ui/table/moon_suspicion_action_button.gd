class_name MoonSuspicionActionButton
extends Button
## Bouton d'action « Lune soupçonnée » ancré en bas à droite de la table.


const PIXEL_THEME: Theme = preload("res://resources/themes/pixel_theme.tres")

const DISMISS_POP_SCALE: float = 1.14
const DISMISS_END_SCALE: float = 0.22
const DISMISS_POP_SEC: float = 0.08
const DISMISS_DURATION_SEC: float = 0.42
const DISMISS_SLIDE_RIGHT: float = 150.0
const DISMISS_SLIDE_DOWN: float = 105.0

var _rest_offset_left: float = 0.0
var _rest_offset_top: float = 0.0
var _rest_offset_right: float = 0.0
var _rest_offset_bottom: float = 0.0
var _dismiss_tween: Tween = null
var _is_dismissing: bool = false


func _ready() -> void:
	theme = PIXEL_THEME
	custom_minimum_size = Vector2(210, 52)
	focus_mode = Control.FOCUS_ALL
	LocaleAware.bind(self, _refresh_locale)
	_refresh_locale()
	_apply_flat_button_states()
	resized.connect(_sync_pivot)
	call_deferred("_capture_rest_layout")


func set_action_available(wants_visible: bool, enabled: bool, animate_dismiss: bool = true) -> void:
	if wants_visible:
		_cancel_dismiss()
		_apply_rest_layout()
		show()
		disabled = not enabled
		focus_mode = Control.FOCUS_ALL
		mouse_filter = Control.MOUSE_FILTER_STOP
		return

	disabled = true
	focus_mode = Control.FOCUS_NONE
	if not is_visible() or _is_dismissing:
		return
	if animate_dismiss:
		_play_dismiss_animation()
	else:
		_hide_instant()


func reset_for_new_hand() -> void:
	_cancel_dismiss()
	_apply_rest_layout()
	hide()
	disabled = true


func _capture_rest_layout() -> void:
	_sync_pivot()
	_rest_offset_left = offset_left
	_rest_offset_top = offset_top
	_rest_offset_right = offset_right
	_rest_offset_bottom = offset_bottom


func _apply_rest_layout() -> void:
	offset_left = _rest_offset_left
	offset_top = _rest_offset_top
	offset_right = _rest_offset_right
	offset_bottom = _rest_offset_bottom
	scale = Vector2.ONE
	rotation = 0.0
	modulate = Color.WHITE
	pivot_offset = size * 0.5


func _sync_pivot() -> void:
	if size.x > 0.0 and size.y > 0.0:
		pivot_offset = size * 0.5


func _cancel_dismiss() -> void:
	if _dismiss_tween != null and _dismiss_tween.is_valid():
		_dismiss_tween.kill()
	_dismiss_tween = null
	_is_dismissing = false


func _hide_instant() -> void:
	_cancel_dismiss()
	hide()
	_apply_rest_layout()


func _play_dismiss_animation() -> void:
	_cancel_dismiss()
	_is_dismissing = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sync_pivot()

	var target_left: float = _rest_offset_left + DISMISS_SLIDE_RIGHT
	var target_top: float = _rest_offset_top + DISMISS_SLIDE_DOWN
	var target_right: float = _rest_offset_right + DISMISS_SLIDE_RIGHT
	var target_bottom: float = _rest_offset_bottom + DISMISS_SLIDE_DOWN

	var tween: Tween = create_tween()
	_dismiss_tween = tween
	tween.tween_property(self, "scale", Vector2(DISMISS_POP_SCALE, DISMISS_POP_SCALE), DISMISS_POP_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(DISMISS_END_SCALE, DISMISS_END_SCALE), DISMISS_DURATION_SEC) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "offset_left", target_left, DISMISS_DURATION_SEC) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "offset_top", target_top, DISMISS_DURATION_SEC) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "offset_right", target_right, DISMISS_DURATION_SEC) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "offset_bottom", target_bottom, DISMISS_DURATION_SEC) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, DISMISS_DURATION_SEC * 0.9) \
		.set_delay(DISMISS_POP_SEC)
	tween.finished.connect(_on_dismiss_finished, CONNECT_ONE_SHOT)


func _on_dismiss_finished() -> void:
	_is_dismissing = false
	_dismiss_tween = null
	hide()
	_apply_rest_layout()


func _refresh_locale() -> void:
	text = tr(TableKeys.TOP_MOON_SUSPICION)
	add_theme_font_size_override("font_size", LocaleFonts.TOP_BAR_BUTTON_FONT_SIZE)


func _apply_flat_button_states() -> void:
	for style_name: StringName in ["normal", "hover", "pressed", "focus", "disabled"]:
		var stylebox: StyleBox = PIXEL_THEME.get_stylebox(style_name, &"Button")
		if stylebox != null:
			add_theme_stylebox_override(style_name, stylebox)
