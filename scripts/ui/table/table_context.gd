class_name TableContext
extends RefCounted
## État et références partagés entre les modules UI de la table. Possédé par
## `table.gd`, passé aux coordinateurs (`TableFx`, `TableHumanHand`, etc.).

var host: Control
var match_manager: MatchManager
var match_controller: MatchControllerBase
var launch_config: MatchLaunchConfig = null

var turn_locked: bool = false
var scene_exiting: bool = false

var hand_card_views: Array[Control] = []
var hand_cards: Array[CardModel] = []
var trick_card_views: Dictionary = {}
## Hot seat : pli terminé conservé jusqu'après le handoff (-1 = aucun).
var pending_trick_collection_winner: int = -1

var player_bottom_hand: Control
var animation_layer: Control
var top_menu_bar: Control
var confirm_dialog: Control
var match_end_dialog: Control
var hand_end_dialog: Control
var match_scoreboard: Control
var trick_area: Control
var background_color: ColorRect
var background_texture: TextureRect

var lead_suit_indicator: Label
var victory_petals: VictoryPetals
var bullet_time_camera: Camera2D
var bullet_time_dim: ColorRect
var queen_avatar_burst: QueenOfSpadesAvatarBurst

var seats: Array[PlayerSeat] = []
var trick_slots: Array[Control] = []
var human_hand_area: Control
var hot_seat_overlay: HotSeatPrivacyOverlay
var moon_suspicion_button: MoonSuspicionActionButton = null
var moon_suspicion_manager: MoonSuspicionManager = null


func is_active() -> bool:
	return host != null and host.is_inside_tree() and not scene_exiting


func get_local_human_seat() -> int:
	if launch_config != null:
		return launch_config.get_local_player_seat()
	return TableConstants.HUMAN_INDEX


func is_hot_seat_multi_human() -> bool:
	return launch_config != null and launch_config.is_hot_seat_multi_human()


func is_local_human_turn() -> bool:
	if match_manager == null:
		return false
	return match_manager.current_player == get_local_human_seat()


func is_online_host() -> bool:
	return launch_config != null and launch_config.mode == MatchMode.Type.ONLINE_HOST


func is_online_client() -> bool:
	return launch_config != null and launch_config.mode == MatchMode.Type.ONLINE_CLIENT


func is_online() -> bool:
	return is_online_host() or is_online_client()


func unlock_turn() -> void:
	turn_locked = false
	TableDisplay.refresh_human_hand_legality(self)
