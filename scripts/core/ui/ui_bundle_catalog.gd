class_name UiBundleCatalog
extends RefCounted
## Atlas UIBundleFree : chemins sources et régions découpées (voir ui/DesignSystem.md).


const BUNDLE_ROOT: String = "res://assets/sprites/UIBundleFree/"
const SLICES_ROOT: String = "res://assets/sprites/ui/"

#region Thème principal — Medieval (taverne / bois)
const MEDIEVAL_SHEET: String = BUNDLE_ROOT + "MediavelFree.png"
const MEDIEVAL: String = SLICES_ROOT + "medieval/"

const MEDIEVAL_PANEL_HANGING: String = MEDIEVAL + "panel_hanging.png"
const MEDIEVAL_BTN_PLANK_NORMAL: String = MEDIEVAL + "btn_plank_normal.png"
const MEDIEVAL_BTN_PLANK_PRESSED: String = MEDIEVAL + "btn_plank_pressed.png"
const MEDIEVAL_PLANK_SIGN: String = MEDIEVAL + "plank_sign.png"
const MEDIEVAL_PROGRESS_TRACK: String = MEDIEVAL + "progress_track.png"
const MEDIEVAL_BTN_LIGHT_NORMAL: String = MEDIEVAL + "btn_light_normal.png"
const MEDIEVAL_BTN_LIGHT_PRESSED: String = MEDIEVAL + "btn_light_pressed.png"
const MEDIEVAL_BTN_DARK_NORMAL: String = MEDIEVAL + "btn_dark_normal.png"
const MEDIEVAL_BTN_DARK_PRESSED: String = MEDIEVAL + "btn_dark_pressed.png"
const MEDIEVAL_ICON_HOME: String = MEDIEVAL + "icon_home.png"
const MEDIEVAL_ICON_GEAR: String = MEDIEVAL + "icon_gear.png"
const MEDIEVAL_ICON_CHECK: String = MEDIEVAL + "icon_check.png"
const MEDIEVAL_ICON_CLOSE: String = MEDIEVAL + "icon_close.png"
const MEDIEVAL_CORNER_TL: String = MEDIEVAL + "corner_tl.png"
const MEDIEVAL_CORNER_TR: String = MEDIEVAL + "corner_tr.png"
const MEDIEVAL_CORNER_BL: String = MEDIEVAL + "corner_bl.png"
const MEDIEVAL_CORNER_BR: String = MEDIEVAL + "corner_br.png"
#endregion

#region Accents — Casino (couronne vainqueur, cadres or)
const CASINO_SHEET: String = BUNDLE_ROOT + "freecasinoui.png"
const CASINO: String = SLICES_ROOT + "casino/"

const CASINO_CROWN: String = CASINO + "casino_crown.png"
const CASINO_BRACKETS_GOLD: String = CASINO + "casino_brackets_gold.png"
const CASINO_FRAME_MARQUEE: String = CASINO + "casino_frame_marquee.png"
#endregion

#region Existant projet
const LEGACY_UI_SHEET: String = "res://assets/sprites/8bit-color-retro-pixel-art-buttons-interface-menu-icons-old-video-game-symbols.png"
const TABLE_FELT: String = "res://assets/sprites/texture_tapis.jpg"
#endregion

# Feuilles demo archivées sous `res://assets/_archive/sprites/UIBundleFree/` (hors export).

## Régions source (pixels) pour re-découpe si le sheet change.
const REGIONS_MEDIEVAL: Dictionary = {
	"panel_hanging": Rect2i(2, 1, 72, 91),
	"btn_plank_normal": Rect2i(24, 72, 80, 16),
	"btn_plank_pressed": Rect2i(24, 88, 80, 16),
	"icon_home": Rect2i(194, 66, 16, 16),
	"icon_gear": Rect2i(210, 66, 16, 16),
	"icon_check": Rect2i(226, 66, 16, 16),
	"icon_close": Rect2i(242, 66, 16, 16),
	"corner_tl": Rect2i(130, 96, 16, 16),
}
