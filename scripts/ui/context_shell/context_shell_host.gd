class_name ContextShellHost
extends Control
## Hosts sidebar + bottom bar + application des insets sur les régions de jeu.
## Note : ne pas nommer une propriété `focus_mode` — conflit avec Control.focus_mode.


signal sidebar_open_changed(is_open: bool)
signal shell_focus_changed(enabled: bool)
signal layout_applied(insets: Vector4)

const SIDEBAR_HOST_NAME: StringName = &"SidebarHost"
const BOTTOM_BAR_HOST_NAME: StringName = &"BottomBarHost"

@export var sidebar_open: bool = false:
	set(value):
		if sidebar_open == value:
			return
		sidebar_open = value
		_apply_layout()
		sidebar_open_changed.emit(sidebar_open)

## Mode Focus produit (chrome réduit) — pas Control.focus_mode.
@export var shell_focus: bool = false:
	set(value):
		if shell_focus == value:
			return
		shell_focus = value
		_apply_layout()
		shell_focus_changed.emit(shell_focus)

## Préférence utilisateur : masquer totalement la bottom bar (hors Focus).
@export var user_hide_bottom_bar: bool = false:
	set(value):
		if user_hide_bottom_bar == value:
			return
		user_hide_bottom_bar = value
		_apply_layout()

## Phase a–c : false jusqu’à peuplement bottom bar (évite de manger la main).
@export var bottom_bar_slot_active: bool = false:
	set(value):
		if bottom_bar_slot_active == value:
			return
		bottom_bar_slot_active = value
		_apply_layout()

var _play_regions: Array[Control] = []
var _sidebar_host: Control
var _bottom_bar_host: Control
var _base_offsets: Dictionary = {} ## Control -> Vector4(left,top,right,bottom) stored as offsets


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ensure_hosts()
	resized.connect(_apply_layout)
	call_deferred("_apply_layout")


func bind_play_regions(regions: Array[Control]) -> void:
	_play_regions.clear()
	_base_offsets.clear()
	for region: Control in regions:
		if region == null:
			continue
		_play_regions.append(region)
		_base_offsets[region] = Vector4(
			region.offset_left,
			region.offset_top,
			region.offset_right,
			region.offset_bottom
		)
	_apply_layout()


func get_sidebar_host() -> Control:
	_ensure_hosts()
	return _sidebar_host


func get_bottom_bar_host() -> Control:
	_ensure_hosts()
	return _bottom_bar_host


func toggle_sidebar() -> void:
	sidebar_open = not sidebar_open


func set_sidebar_open(value: bool) -> void:
	sidebar_open = value


func set_shell_focus(value: bool) -> void:
	shell_focus = value


func current_bottom_bar_mode() -> ContextShellLayout.BottomBarMode:
	if not bottom_bar_slot_active:
		return ContextShellLayout.BottomBarMode.HIDDEN
	return ContextShellLayout.resolve_bottom_bar_mode(
		size.x if size.x > 1.0 else get_viewport_rect().size.x,
		shell_focus,
		user_hide_bottom_bar
	)


func _ensure_hosts() -> void:
	if _sidebar_host == null:
		_sidebar_host = get_node_or_null(NodePath(String(SIDEBAR_HOST_NAME))) as Control
		if _sidebar_host == null:
			_sidebar_host = _make_host(String(SIDEBAR_HOST_NAME))
			add_child(_sidebar_host)
	if _bottom_bar_host == null:
		_bottom_bar_host = get_node_or_null(NodePath(String(BOTTOM_BAR_HOST_NAME))) as Control
		if _bottom_bar_host == null:
			_bottom_bar_host = _make_host(String(BOTTOM_BAR_HOST_NAME))
			add_child(_bottom_bar_host)


func _make_host(host_name: String) -> Control:
	var host := Control.new()
	host.name = host_name
	host.mouse_filter = Control.MOUSE_FILTER_STOP
	host.clip_contents = true
	return host


func _apply_layout() -> void:
	_ensure_hosts()
	var vp: Vector2 = size
	if vp.x < 2.0 or vp.y < 2.0:
		vp = get_viewport_rect().size
	var insets: Vector4 = ContextShellLayout.play_insets(
		vp,
		sidebar_open and not shell_focus,
		shell_focus,
		user_hide_bottom_bar,
		bottom_bar_slot_active
	)
	## Focus : pas de sidebar push.
	if shell_focus:
		insets.z = 0.0
	_layout_hosts(vp, insets)
	_apply_play_insets(insets)
	layout_applied.emit(insets)


func _layout_hosts(_vp: Vector2, insets: Vector4) -> void:
	var sidebar_w: float = insets.z
	_sidebar_host.visible = sidebar_w > 0.5
	_sidebar_host.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_sidebar_host.offset_left = -sidebar_w
	_sidebar_host.offset_right = 0.0
	_sidebar_host.offset_top = 0.0
	_sidebar_host.offset_bottom = -insets.w

	var bottom_h: float = insets.w
	_bottom_bar_host.visible = bottom_h > 0.5
	_bottom_bar_host.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_bar_host.offset_left = 0.0
	_bottom_bar_host.offset_right = -sidebar_w
	_bottom_bar_host.offset_top = -bottom_h
	_bottom_bar_host.offset_bottom = 0.0

	## Phase a : placeholders discrets (pas de widgets).
	_paint_placeholder(_sidebar_host, sidebar_w > 0.5)
	_paint_placeholder(_bottom_bar_host, bottom_h > 0.5)


func _paint_placeholder(host: Control, show_chrome: bool) -> void:
	var panel: Panel = host.get_node_or_null("Placeholder") as Panel
	if not show_chrome:
		if panel != null:
			panel.visible = false
		return
	if panel == null:
		panel = Panel.new()
		panel.name = "Placeholder"
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.06, 0.08, 0.72)
		style.border_color = UiPalette.GOLD
		style.set_border_width_all(2)
		style.set_corner_radius_all(0)
		panel.add_theme_stylebox_override("panel", style)
		host.add_child(panel)
	panel.visible = true


func _apply_play_insets(insets: Vector4) -> void:
	for region: Control in _play_regions:
		if region == null or not is_instance_valid(region):
			continue
		var base: Vector4 = _base_offsets.get(region, Vector4.ZERO) as Vector4
		var next: Vector4 = ContextShellLayout.apply_insets_to_offsets(
			region.anchor_left,
			region.anchor_top,
			region.anchor_right,
			region.anchor_bottom,
			base,
			insets
		)
		region.offset_left = next.x
		region.offset_top = next.y
		region.offset_right = next.z
		region.offset_bottom = next.w
