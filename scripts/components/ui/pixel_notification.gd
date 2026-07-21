class_name PixelNotification
extends Control
## Notification table réutilisable (IDEA-00021 L8) — fond sombre, contour or, fade.


enum Kind {
	INFO,
	LEAD_SUIT,
	YOUR_TURN,
	HEARTS_BROKEN,
	TRICK_WON,
	HAND_END,
}

const DURATION_DEFAULT: float = 1.6
const FADE_SEC: float = 0.18

var _panel: PanelContainer
var _label: Label
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.offset_left = -200.0
	_panel.offset_top = 72.0
	_panel.offset_right = 200.0
	_panel.offset_bottom = 120.0
	UiStyleFactory.apply_pixel_panel(
		_panel,
		UiStyleFactory.pixel_banner_panel_style(Vector4(20, 12, 20, 12), 2, 0.9)
	)
	UiThemeCatalog.apply_variation(_panel, UiThemeCatalog.V_NOTIFICATION_PANEL)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", UiPalette.CREAM)
	_panel.add_child(_label)
	add_child(_panel)
	modulate.a = 0.0


func show_message(text: String, kind: Kind = Kind.INFO, duration_sec: float = DURATION_DEFAULT) -> void:
	_label.text = text
	_label.add_theme_color_override("font_color", _color_for_kind(kind))
	if _tween != null and _tween.is_valid():
		_tween.kill()
	modulate.a = 0.0
	UiOffsetAnim.enable_on(_panel)
	_panel.offset_transform_scale = Vector2(0.96, 0.96)
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_panel, "offset_transform_scale", Vector2.ONE, FADE_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _tween.finished
	await get_tree().create_timer(duration_sec).timeout
	if not is_inside_tree():
		return
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await _tween.finished


static func _color_for_kind(kind: Kind) -> Color:
	match kind:
		Kind.YOUR_TURN:
			return UiPalette.GOLD_BRIGHT
		Kind.HEARTS_BROKEN:
			return Color(0.9, 0.35, 0.4, 1.0)
		Kind.TRICK_WON, Kind.HAND_END:
			return UiPalette.GOLD
		Kind.LEAD_SUIT:
			return UiPalette.CREAM
		_:
			return UiPalette.CREAM
