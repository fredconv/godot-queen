class_name UiButtonLayout
extends RefCounted
## Grille 8 px et tailles fixes des boutons pixel (voir .cursor/skills/godot-pixel-ui-button).

const GRID: int = 8

const MENU_BUTTON_SIZE: Vector2i = Vector2i(192, 48)
const COMPACT_BUTTON_SIZE: Vector2i = Vector2i(160, 48)

const NINEPATCH_TEXTURE_SIZE: int = 32
const NINEPATCH_MARGIN: int = 8

const CONTENT_MARGIN_H: int = 16
const CONTENT_MARGIN_V: int = 8
const ICON_SIZE: int = 16
const ICON_TEXT_GAP: int = 8

const NINEPATCH_NORMAL: String = "res://assets/sprites/ui/ninepatch/btn_wood_32.png"
const NINEPATCH_PRESSED: String = "res://assets/sprites/ui/ninepatch/btn_wood_32_pressed.png"

const MENU_PANEL_TEXTURE_SIZE: Vector2i = Vector2i(72, 91)
const MENU_PANEL_SCALE: int = 2
const MENU_PANEL_DISPLAY_SIZE: Vector2i = Vector2i(144, 182)
const MENU_COLUMN_SEPARATION: int = 16
const MENU_BUTTON_STACK_SEPARATION: int = 8
