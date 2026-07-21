class_name ContextShellLayout
extends RefCounted
## Calcul des insets Context Shell (pas de Tween, pas de métier Hearts).


const SIDEBAR_WIDTH_OPEN: float = 280.0
const BOTTOM_BAR_HEIGHT_FULL: float = 56.0
const BOTTOM_BAR_HEIGHT_COMPACT: float = 44.0
## Largeur sous laquelle la bottom bar passe en compact (pas hide).
const COMPACT_VIEWPORT_WIDTH: float = 900.0


enum BottomBarMode {
	FULL,
	COMPACT,
	HIDDEN,
}


static func resolve_bottom_bar_mode(
	viewport_width: float,
	focus_mode: bool,
	user_hide_bottom_bar: bool
) -> BottomBarMode:
	if focus_mode or user_hide_bottom_bar:
		return BottomBarMode.HIDDEN
	if viewport_width < COMPACT_VIEWPORT_WIDTH:
		return BottomBarMode.COMPACT
	return BottomBarMode.FULL


static func bottom_bar_height(mode: BottomBarMode) -> float:
	match mode:
		BottomBarMode.FULL:
			return BOTTOM_BAR_HEIGHT_FULL
		BottomBarMode.COMPACT:
			return BOTTOM_BAR_HEIGHT_COMPACT
		_:
			return 0.0


static func sidebar_width(sidebar_open: bool) -> float:
	return SIDEBAR_WIDTH_OPEN if sidebar_open else 0.0


## Marges appliquées aux zones de jeu (gauche, haut, droite, bas).
static func play_insets(
	viewport_size: Vector2,
	sidebar_open: bool,
	focus_mode: bool,
	user_hide_bottom_bar: bool,
	bottom_bar_slot_active: bool = false
) -> Vector4:
	var mode: BottomBarMode = BottomBarMode.HIDDEN
	if bottom_bar_slot_active:
		mode = resolve_bottom_bar_mode(viewport_size.x, focus_mode, user_hide_bottom_bar)
	var right: float = sidebar_width(sidebar_open)
	var bottom: float = bottom_bar_height(mode)
	return Vector4(0.0, 0.0, right, bottom)


## Applique des insets en respectant le type d’ancrage (évite d’écraser TrickArea centré).
## `base` = offsets capturés hors chrome (left, top, right, bottom).
static func apply_insets_to_offsets(
	anchor_left: float,
	anchor_top: float,
	anchor_right: float,
	anchor_bottom: float,
	base: Vector4,
	insets: Vector4
) -> Vector4:
	var left: float = base.x
	var top: float = base.y
	var right: float = base.z
	var bottom: float = base.w

	if is_equal_approx(anchor_left, anchor_right):
		if is_equal_approx(anchor_left, 0.0):
			left = base.x + insets.x
			right = base.z + insets.x
		elif is_equal_approx(anchor_left, 1.0):
			left = base.x - insets.z
			right = base.z - insets.z
		else:
			## Centre (ex. TrickArea 0.5/0.5) : décale sans changer la taille.
			var shift_x: float = (insets.x - insets.z) * 0.5
			left = base.x + shift_x
			right = base.z + shift_x
	else:
		left = base.x + insets.x
		right = base.z - insets.z

	if is_equal_approx(anchor_top, anchor_bottom):
		if is_equal_approx(anchor_top, 0.0):
			top = base.y + insets.y
			bottom = base.w + insets.y
		elif is_equal_approx(anchor_top, 1.0):
			top = base.y - insets.w
			bottom = base.w - insets.w
		else:
			var shift_y: float = (insets.y - insets.w) * 0.5
			top = base.y + shift_y
			bottom = base.w + shift_y
	else:
		top = base.y + insets.y
		bottom = base.w - insets.w

	return Vector4(left, top, right, bottom)
