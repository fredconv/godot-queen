class_name TableContext
extends RefCounted
## État et références partagés entre les modules UI de la table. Possédé par
## `table.gd`, passé aux coordinateurs (`TableFx`, `TableHumanHand`, etc.).

var host: Control
var match_manager: MatchManager
var match_controller: LocalMatchController
var launch_config: MatchLaunchConfig = null

var turn_locked: bool = false
var scene_exiting: bool = false

var hand_card_views: Array[Control] = []
var hand_cards: Array[CardModel] = []
var trick_card_views: Dictionary = {}

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


func is_active() -> bool:
	return host != null and host.is_inside_tree() and not scene_exiting


func unlock_turn() -> void:
	turn_locked = false
	TableDisplay.refresh_human_hand_legality(self)
