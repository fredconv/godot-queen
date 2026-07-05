class_name TableConstants
extends RefCounted
## Constantes partagées de la scène table (main humaine, pli, IA, navigation).

const CardViewScene: PackedScene = preload("res://scenes/components/card_view.tscn")
const MAIN_MENU_SCENE_PATH: String = "res://scenes/menus/main_menu.tscn"

const HUMAN_INDEX: int = 0

const HAND_FAN_SPREAD_DEG: float = 34.0
const HAND_FAN_RADIUS: float = 370.0
const HAND_CARD_SCALE: float = 1.9
const CARD_BASE_SIZE: Vector2 = Vector2(56.0, 80.0)
const HAND_FAN_BOTTOM_MARGIN: float = -30.0
const HUMAN_HAND_DEAL_OFFSET: Vector2 = Vector2(0.0, 480.0)
const AI_TURN_DELAY_SEC: float = 0.4
const TRICK_CARD_SCALE: float = 1.5
