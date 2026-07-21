class_name UiPalette
extends RefCounted
## Palette UI partagée (ADR-008). Point unique pour menus, overlays et thème.

const CREAM: Color = Color(0.961, 0.941, 0.902, 1.0)
const GOLD: Color = Color(0.831, 0.686, 0.216, 1.0)
const GOLD_BRIGHT: Color = Color(0.95, 0.82, 0.45, 1.0)
const MUTED: Color = Color(0.72, 0.7, 0.66, 0.85)

const PANEL_BG: Color = Color(0.129, 0.129, 0.157, 0.96)
const PANEL_BORDER: Color = GOLD
const ANTHRACITE: Color = Color(0.07, 0.09, 0.11, 1.0)
const SECTION_BG: Color = Color(0.08, 0.09, 0.12, 0.88)
const MENU_STACK_BG: Color = Color(0.04, 0.06, 0.05, 0.72)

const BTN_BG: Color = Color(0.1, 0.16, 0.12, 1.0)
const BTN_BG_HOVER: Color = Color(0.14, 0.22, 0.17, 1.0)
const BTN_BG_PRESSED: Color = Color(0.07, 0.11, 0.09, 1.0)

const DANGER_BG: Color = Color(0.22, 0.08, 0.08, 1.0)
const DANGER_BG_HOVER: Color = Color(0.3, 0.1, 0.1, 1.0)
const DANGER_BG_PRESSED: Color = Color(0.16, 0.06, 0.06, 1.0)
const DANGER_BORDER: Color = Color(0.72, 0.28, 0.28, 1.0)

const DISABLED_BG: Color = Color(0.08, 0.1, 0.09, 0.7)
const DISABLED_BORDER: Color = Color(0.4, 0.4, 0.35, 1.0)

const BACKDROP: Color = Color(0.0, 0.0, 0.0, 0.78)
const VIGNETTE: Color = Color(0.02, 0.08, 0.04, 0.35)

const MENU_TITLE_SIZE: int = 14
const MENU_BUTTON_SIZE: int = 9
const MENU_SUBTITLE_SIZE: int = 8
