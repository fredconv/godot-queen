class_name ScoreBarRow
extends HBoxContainer
## Une ligne du panneau de score : nom, barre de progression et total cumulé.

const NAME_MIN_WIDTH: float = 82.0
const SCORE_MIN_WIDTH: float = 28.0
const BAR_HEIGHT: float = 12.0
const BAR_TRACK_COLOR: Color = Color(0.18, 0.18, 0.22, 1.0)
const HUMAN_NAME_COLOR: Color = Color(0.831, 0.686, 0.216, 1.0)
const ENTRY_NAME_COLOR: Color = Color(0.961, 0.941, 0.902, 1.0)
const HUMAN_BAR_COLOR: Color = Color(0.831, 0.686, 0.216, 1.0)
const ENTRY_BAR_COLOR: Color = Color(0.45, 0.58, 0.72, 1.0)
const SCORE_COLOR: Color = Color(0.88, 0.88, 0.9, 1.0)

var _name_label: Label
var _bar_track: Control
var _bar_fill: ColorRect
var _score_label: Label
var _score: int = 0
var _max_score: int = 100


func _ready() -> void:
	_ensure_nodes()


func configure(display_name: String, score: int, max_score: int, is_human: bool) -> void:
	_ensure_nodes()
	_score = maxi(score, 0)
	_max_score = maxi(max_score, 1)
	var prefix: String = TranslationServer.translate(
		CommonKeys.WINNER_MARK if is_human else CommonKeys.WINNER_PAD
	)
	_name_label.text = "%s%s" % [prefix, display_name]
	_name_label.add_theme_color_override("font_color", HUMAN_NAME_COLOR if is_human else ENTRY_NAME_COLOR)
	_bar_fill.color = HUMAN_BAR_COLOR if is_human else ENTRY_BAR_COLOR
	_score_label.text = str(_score)
	_update_bar_fill()


func _ensure_nodes() -> void:
	if _name_label != null:
		return
	add_theme_constant_override("separation", 6)
	_build_nodes()


func _build_nodes() -> void:
	_name_label = Label.new()
	_name_label.custom_minimum_size = Vector2(NAME_MIN_WIDTH, 0.0)
	_name_label.clip_text = true
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name_label.add_theme_font_size_override("font_size", 11)
	add_child(_name_label)

	_bar_track = Control.new()
	_bar_track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar_track.custom_minimum_size = Vector2(48.0, BAR_HEIGHT)
	_bar_track.resized.connect(_update_bar_fill)
	add_child(_bar_track)

	var track_bg := ColorRect.new()
	track_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	track_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track_bg.color = BAR_TRACK_COLOR
	_bar_track.add_child(track_bg)

	_bar_fill = ColorRect.new()
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_track.add_child(_bar_fill)

	_score_label = Label.new()
	_score_label.custom_minimum_size = Vector2(SCORE_MIN_WIDTH, 0.0)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_score_label.add_theme_font_size_override("font_size", 11)
	_score_label.add_theme_color_override("font_color", SCORE_COLOR)
	add_child(_score_label)


func _update_bar_fill() -> void:
	if _bar_fill == null or _bar_track == null:
		return
	var track_width: float = _bar_track.size.x
	var ratio: float = clampf(float(_score) / float(_max_score), 0.0, 1.0)
	_bar_fill.size = Vector2(track_width * ratio, BAR_HEIGHT)
	_bar_fill.position = Vector2.ZERO
