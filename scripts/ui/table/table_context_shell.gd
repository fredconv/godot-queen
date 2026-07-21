class_name TableContextShell
extends RefCounted
## Phase b — coordination table ↔ ContextShell (toggle, dock scoreboard, Escape).
## Pas d’anim TogglePanel ici (phase c) ; pas de bottom bar peuplée (phase d).


const TOGGLE_NAME: StringName = &"ContextShellToggle"
const SCOREBOARD_MARGIN: float = 12.0
const _META_BRIDGE: StringName = &"ddp_table_shell_bridge"


static func setup(ctx: TableContext, shell: ContextShellHost) -> void:
	if ctx == null or shell == null or ctx.host == null:
		return
	ctx.context_shell = shell
	if not shell.has_meta(_META_BRIDGE):
		shell.sidebar_open_changed.connect(_on_sidebar_signal.bind(ctx))
		shell.set_meta(_META_BRIDGE, true)
	_ensure_toggle_button(ctx, shell)
	_capture_scoreboard_home(ctx)
	_sync_scoreboard_dock(ctx, shell.sidebar_open)
	_refresh_toggle_visual(ctx, shell.sidebar_open)


static func toggle_sidebar(ctx: TableContext) -> void:
	if ctx == null or ctx.context_shell == null:
		return
	ctx.context_shell.toggle_sidebar()


static func handle_unhandled_key(ctx: TableContext, event: InputEvent) -> bool:
	if ctx == null or ctx.context_shell == null:
		return false
	if not ctx.context_shell.sidebar_open:
		return false
	if _any_modal_blocking(ctx):
		return false
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			ctx.context_shell.set_sidebar_open(false)
			return true
	return false


static func _on_sidebar_signal(is_open: bool, ctx: TableContext) -> void:
	_sync_scoreboard_dock(ctx, is_open)
	_refresh_toggle_visual(ctx, is_open)


static func _ensure_toggle_button(ctx: TableContext, shell: ContextShellHost) -> void:
	var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return
	var existing: BaseButton = ui_layer.get_node_or_null(NodePath(String(TOGGLE_NAME))) as BaseButton
	if existing != null:
		ctx.shell_toggle_button = existing
		return
	var btn := Button.new()
	btn.name = String(TOGGLE_NAME)
	btn.theme = load(LocaleFonts.PIXEL_THEME_PATH) as Theme
	btn.focus_mode = Control.FOCUS_ALL
	btn.theme_type_variation = UiThemeCatalog.V_SMALL_HUD_BUTTON
	btn.custom_minimum_size = Vector2(34, 44)
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.offset_left = -34.0
	btn.offset_top = 92.0
	btn.offset_right = 0.0
	btn.offset_bottom = 136.0
	btn.z_index = 20
	btn.add_theme_color_override("font_color", UiPalette.GOLD)
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(toggle_sidebar.bind(ctx))
	ui_layer.add_child(btn)
	ctx.shell_toggle_button = btn
	_position_toggle_for_shell(btn, shell.sidebar_open)


static func _position_toggle_for_shell(btn: Control, sidebar_open: bool) -> void:
	# La languette vit à l'extérieur du tiroir/panneau : elle ne masque ni les
	# scores ni la pile de cartes de l'adversaire droit.
	var inset: float = ContextShellLayout.SIDEBAR_WIDTH_OPEN if sidebar_open else 6.0
	btn.offset_left = -34.0 - inset
	btn.offset_right = 0.0 - inset


static func _refresh_toggle_visual(ctx: TableContext, sidebar_open: bool) -> void:
	var btn: BaseButton = ctx.shell_toggle_button
	if btn == null or not is_instance_valid(btn):
		return
	_position_toggle_for_shell(btn, sidebar_open)
	btn.text = "◀" if sidebar_open else "▶"
	btn.tooltip_text = ""


static func _capture_scoreboard_home(ctx: TableContext) -> void:
	var board: Control = ctx.match_scoreboard
	if board == null or not ctx.shell_scoreboard_home.is_empty():
		return
	ctx.shell_scoreboard_home = {
		"parent": board.get_parent(),
		"index": board.get_index(),
		"anchor_left": board.anchor_left,
		"anchor_top": board.anchor_top,
		"anchor_right": board.anchor_right,
		"anchor_bottom": board.anchor_bottom,
		"offset_left": board.offset_left,
		"offset_top": board.offset_top,
		"offset_right": board.offset_right,
		"offset_bottom": board.offset_bottom,
		"visible": board.visible,
	}


static func _sync_scoreboard_dock(ctx: TableContext, sidebar_open: bool) -> void:
	var board: Control = ctx.match_scoreboard
	var shell: ContextShellHost = ctx.context_shell
	if board == null or shell == null:
		return
	_capture_scoreboard_home(ctx)
	if sidebar_open:
		shell.mount_sidebar_child(board)
		board.visible = true
		board.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		board.offset_left = SCOREBOARD_MARGIN
		# Sous la barre supérieure : aucun chevauchement avec NOUVEAU / MENU.
		board.offset_top = 72.0
		board.offset_right = -SCOREBOARD_MARGIN
		board.offset_bottom = 232.0
	else:
		_restore_scoreboard_home(ctx)
		board.visible = false


static func _restore_scoreboard_home(ctx: TableContext) -> void:
	var board: Control = ctx.match_scoreboard
	var home: Dictionary = ctx.shell_scoreboard_home
	if board == null or home.is_empty():
		return
	var parent: Node = home.get("parent") as Node
	if parent == null or not is_instance_valid(parent):
		return
	if board.get_parent() != parent:
		var prev: Node = board.get_parent()
		if prev != null:
			prev.remove_child(board)
		parent.add_child(board)
		var idx: int = int(home.get("index", -1))
		if idx >= 0 and idx < parent.get_child_count():
			parent.move_child(board, mini(idx, parent.get_child_count() - 1))
	board.anchor_left = float(home.get("anchor_left", 1.0))
	board.anchor_top = float(home.get("anchor_top", 0.0))
	board.anchor_right = float(home.get("anchor_right", 1.0))
	board.anchor_bottom = float(home.get("anchor_bottom", 0.0))
	board.offset_left = float(home.get("offset_left", -260.0))
	board.offset_top = float(home.get("offset_top", 72.0))
	board.offset_right = float(home.get("offset_right", -12.0))
	board.offset_bottom = float(home.get("offset_bottom", 220.0))
	board.visible = bool(home.get("visible", true))


static func _any_modal_blocking(ctx: TableContext) -> bool:
	for node: Control in [
		ctx.confirm_dialog,
		ctx.match_end_dialog,
		ctx.hand_end_dialog,
	]:
		if node != null and node.visible:
			return true
	if ctx.host == null:
		return false
	var ui_layer: CanvasLayer = ctx.host.get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return false
	for child_name: String in ["ScoresScreen", "SettingsScreen", "HelpScreen"]:
		var overlay: Control = ui_layer.get_node_or_null(child_name) as Control
		if overlay != null and overlay.visible:
			return true
	return false
