class_name ReactionPicker
extends Control
## Bouton 💬 (dessiné) + palette 2×2 ; cooldown local affiché.


signal reaction_selected(reaction_id: int)

const BUTTON_SIZE: Vector2 = Vector2(48, 48)
const CELL_SIZE: int = 42
const FACE_SIZE: int = 26
const GRID_SEP: int = 6
const PANEL_PAD: int = 8
const PALETTE_GAP_ABOVE: int = 8

var _toggle: Button
var _palette: PanelContainer
var _grid: GridContainer
var _cooldown_overlay: ColorRect
var _open: bool = false
var _cooldown_left: float = 0.0
var _cells: Array[Button] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = BUTTON_SIZE
	size = BUTTON_SIZE
	_build_toggle()
	_build_palette()
	set_process(false)
	_refresh_enabled()


func _build_toggle() -> void:
	_toggle = Button.new()
	_toggle.name = "Toggle"
	_toggle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_toggle.focus_mode = Control.FOCUS_ALL
	_toggle.tooltip_text = tr(TableKeys.REACTION_TOOLTIP)
	_toggle.pressed.connect(_on_toggle_pressed)
	_toggle.draw.connect(_draw_toggle_icon)
	_apply_toggle_style()
	add_child(_toggle)
	_cooldown_overlay = ColorRect.new()
	_cooldown_overlay.name = "CooldownOverlay"
	_cooldown_overlay.color = Color(0.05, 0.05, 0.06, 0.55)
	_cooldown_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cooldown_overlay.visible = false
	_toggle.add_child(_cooldown_overlay)


func _apply_toggle_style() -> void:
	for state: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		var style: StyleBoxFlat = UiStyleFactory.pixel_bar_button_style(
			UiPalette.BTN_BG if state != &"hover" else UiPalette.BTN_BG_HOVER,
			UiPalette.GOLD if state != &"hover" else UiPalette.GOLD_BRIGHT,
			2
		)
		## Icône dessinée : pas de content_margin qui décale le hitbox.
		style.content_margin_left = 0
		style.content_margin_right = 0
		style.content_margin_top = 0
		style.content_margin_bottom = 0
		_toggle.add_theme_stylebox_override(state, style)


func _draw_toggle_icon() -> void:
	## Bulle de dialogue pixel (pas d’emoji système).
	var r := Rect2(Vector2(10, 10), Vector2(28, 20))
	_toggle.draw_rect(r, UiPalette.CREAM, true)
	_toggle.draw_rect(r, UiPalette.GOLD, false, 1.0)
	var tail := PackedVector2Array([
		Vector2(16, 30),
		Vector2(20, 36),
		Vector2(24, 30),
	])
	_toggle.draw_colored_polygon(tail, UiPalette.CREAM)
	_toggle.draw_line(tail[0], tail[1], UiPalette.GOLD, 1.0)
	_toggle.draw_line(tail[1], tail[2], UiPalette.GOLD, 1.0)
	## Trois points.
	for i in range(3):
		var d := Vector2(16 + i * 6, 18)
		_toggle.draw_rect(Rect2(d, Vector2(3, 3)), Color(0.15, 0.12, 0.1, 1.0), true)


func _palette_inner_size() -> Vector2i:
	var grid: int = CELL_SIZE * 2 + GRID_SEP
	return Vector2i(grid + PANEL_PAD * 2, grid + PANEL_PAD * 2)


func _build_palette() -> void:
	_palette = PanelContainer.new()
	_palette.name = "Palette"
	_palette.visible = false
	_palette.clip_contents = true
	var inner: Vector2i = _palette_inner_size()
	_palette.custom_minimum_size = Vector2(inner)
	## Aligné à droite du toggle : la palette ne doit pas sortir de l’écran (1280).
	_palette.position = Vector2(
		float(int(BUTTON_SIZE.x) - inner.x),
		-float(inner.y + PALETTE_GAP_ABOVE)
	)
	## Marges panel = 0 : le padding est porté par MarginContainer (évite double marge).
	UiStyleFactory.apply_pixel_panel(
		_palette,
		UiStyleFactory.pixel_compact_panel_style(Vector4(0, 0, 0, 0), Color(0.05, 0.06, 0.08, 0.92))
	)
	_grid = GridContainer.new()
	_grid.name = "Grid"
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", GRID_SEP)
	_grid.add_theme_constant_override("v_separation", GRID_SEP)
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", PANEL_PAD)
	margin.add_theme_constant_override("margin_top", PANEL_PAD)
	margin.add_theme_constant_override("margin_right", PANEL_PAD)
	margin.add_theme_constant_override("margin_bottom", PANEL_PAD)
	margin.add_child(_grid)
	_palette.add_child(margin)
	add_child(_palette)
	for reaction_id: int in ReactionIds.all_ids():
		_grid.add_child(_make_cell(reaction_id))
	UiFocusNav.chain_horizontal([_cells[0], _cells[1]])
	UiFocusNav.chain_horizontal([_cells[2], _cells[3]])


func _make_cell(reaction_id: int) -> Button:
	var cell := Button.new()
	cell.name = "Cell_%d" % reaction_id
	cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	cell.focus_mode = Control.FOCUS_ALL
	cell.clip_contents = true
	cell.pressed.connect(_on_cell_pressed.bind(reaction_id))
	_apply_cell_style(cell)
	## Marges explicites : fiable dans un Button (pas un Container).
	var pad: int = int((CELL_SIZE - FACE_SIZE) / 2)
	var holder := MarginContainer.new()
	holder.name = "Pad"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_theme_constant_override("margin_left", pad)
	holder.add_theme_constant_override("margin_top", pad)
	holder.add_theme_constant_override("margin_right", pad)
	holder.add_theme_constant_override("margin_bottom", pad)
	var icon := ReactionIcon.new()
	icon.name = "Icon"
	icon.reaction_id = reaction_id
	icon.face_size = FACE_SIZE
	icon.custom_minimum_size = Vector2(FACE_SIZE, FACE_SIZE)
	icon.size = Vector2(FACE_SIZE, FACE_SIZE)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(icon)
	cell.add_child(holder)
	_cells.append(cell)
	return cell


func _apply_cell_style(btn: Button) -> void:
	for state: StringName in [&"normal", &"hover", &"pressed", &"focus"]:
		var style: StyleBoxFlat = UiStyleFactory.pixel_bar_button_style(
			UiPalette.SECTION_BG,
			UiPalette.GOLD,
			1
		)
		## 1 px = intérieur de la bordure or (évite icône collée au trait).
		style.content_margin_left = 1
		style.content_margin_right = 1
		style.content_margin_top = 1
		style.content_margin_bottom = 1
		btn.add_theme_stylebox_override(state, style)


func _on_toggle_pressed() -> void:
	if _cooldown_left > 0.0:
		return
	if not ConfigService.get_emotes_enabled():
		return
	set_open(not _open)


func set_open(value: bool) -> void:
	_open = value
	_palette.visible = _open
	if _open:
		## Forcer le layout immédiat (évite assert/MCP sur grille non triée).
		_palette.reset_size()
		_palette.size = _palette.get_combined_minimum_size()
		_clamp_palette_on_screen()
		if not _cells.is_empty():
			_cells[0].grab_focus()


func _clamp_palette_on_screen() -> void:
	## Sécurité multi-résolution : évite sortie à droite / en haut (cas réel bas-droite).
	var vp: Rect2 = get_viewport().get_visible_rect()
	var rect: Rect2 = _palette.get_global_rect()
	var delta := Vector2.ZERO
	if rect.end.x > vp.end.x - 4.0:
		delta.x = (vp.end.x - 4.0) - rect.end.x
	if rect.position.y < vp.position.y + 4.0:
		delta.y = (vp.position.y + 4.0) - rect.position.y
	if delta != Vector2.ZERO:
		_palette.global_position += delta


func close_palette() -> void:
	set_open(false)


func _on_cell_pressed(reaction_id: int) -> void:
	if _cooldown_left > 0.0:
		return
	close_palette()
	reaction_selected.emit(reaction_id)


func begin_cooldown(seconds: float = ReactionIds.COOLDOWN_SEC) -> void:
	_cooldown_left = seconds
	_cooldown_overlay.visible = true
	_toggle.disabled = true
	set_process(true)
	close_palette()


func _process(delta: float) -> void:
	_cooldown_left = maxf(0.0, _cooldown_left - delta)
	if _cooldown_left <= 0.0:
		_cooldown_overlay.visible = false
		_toggle.disabled = false
		_refresh_enabled()
		set_process(false)


func refresh_from_config() -> void:
	var enabled: bool = ConfigService.get_emotes_enabled()
	visible = enabled
	if not enabled:
		close_palette()


func _refresh_enabled() -> void:
	refresh_from_config()


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if UiFocusNav.is_cancel_pressed(event):
		close_palette()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		## Clic hors bouton ET hors palette → fermer (ne pas voler le clic cellule).
		var canvas_pos: Vector2 = event.position
		if get_global_rect().has_point(canvas_pos) or _palette.get_global_rect().has_point(canvas_pos):
			return
		close_palette()


## Helpers tests / MCP — chaque icône doit être strictement dans sa cellule.
func assert_icons_fit_cells(epsilon: float = 0.5) -> bool:
	if not is_inside_tree() or _cells.is_empty():
		return false
	for cell: Button in _cells:
		var icon: ReactionIcon = cell.find_child("Icon", true, false) as ReactionIcon
		if icon == null:
			return false
		var cell_rect: Rect2 = cell.get_global_rect()
		var icon_rect: Rect2 = icon.get_global_rect()
		if not cell_rect.grow(-epsilon).encloses(icon_rect):
			return false
	return true
