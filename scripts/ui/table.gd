extends Control
## Table
## Contrôleur léger de la scène table : assemble le contexte partagé et
## délègue la logique aux modules `scripts/ui/table/*` (main humaine, coups,
## distribution, affichage, effets FX, cycle de partie). Voir
## docs/DECISIONS.md ADR-020/ADR-021 pour le câblage `MatchManager` et les
## animations.

enum ConfirmAction { NONE, LEAVE_MATCH, RESTART_MATCH }

var _ctx: TableContext
var _confirm_action: ConfirmAction = ConfirmAction.NONE

@onready var _player_bottom_hand: Control = $HumanHandArea/PlayerBottomHand
@onready var _animation_layer: Control = $AnimationLayer
@onready var _top_menu_bar: Control = $UILayer/TopMenuBar
@onready var _confirm_dialog: Control = $UILayer/ConfirmDialog
@onready var _match_end_dialog: Control = $UILayer/MatchEndDialog
@onready var _hand_end_dialog: Control = $UILayer/HandEndDialog
@onready var _match_scoreboard: Control = $UILayer/MatchScoreboard
@onready var _scores_screen: Control = $UILayer/ScoresScreen
@onready var _settings_screen: Control = $UILayer/SettingsScreen
@onready var _help_screen: Control = $UILayer/HelpScreen
@onready var _trick_area: Control = $TrickArea
@onready var _background_color: ColorRect = $Background/ColorFill
@onready var _background_texture: TextureRect = $Background/TextureFill
@onready var _seats: Array[PlayerSeat] = [
	$PlayerSeats/SeatBottom,
	$PlayerSeats/SeatLeft,
	$PlayerSeats/SeatTop,
	$PlayerSeats/SeatRight,
]
@onready var _trick_slots: Array[Control] = [
	$TrickArea/TrickCardBottom,
	$TrickArea/TrickCardLeft,
	$TrickArea/TrickCardTop,
	$TrickArea/TrickCardRight,
]


func _ready() -> void:
	_ctx = _build_context()
	TableFx.apply_table_theme(_ctx)
	TableFx.setup(_ctx)
	_top_menu_bar.menu_pressed.connect(_on_top_menu_bar_menu_pressed)
	_top_menu_bar.scores_pressed.connect(_on_top_menu_bar_scores_pressed)
	_top_menu_bar.new_game_pressed.connect(_on_top_menu_bar_new_game_pressed)
	_top_menu_bar.hamburger_pressed.connect(_on_top_menu_bar_hamburger_pressed)
	_top_menu_bar.help_pressed.connect(_on_top_menu_bar_help_pressed)
	_top_menu_bar.settings_pressed.connect(_on_top_menu_bar_settings_pressed)
	_confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	_match_end_dialog.replay_requested.connect(_on_match_end_replay_requested)
	_match_end_dialog.quit_requested.connect(_on_match_end_quit_requested)
	TableChrome.setup_music_controls(_ctx)
	LocaleAware.bind(self, _on_locale_changed)
	TableLocale.refresh_seat_names(_ctx)
	call_deferred("_start_new_match")


func _exit_tree() -> void:
	if _ctx == null:
		return
	_ctx.scene_exiting = true
	TableFx.on_exit(_ctx)


func _build_context() -> TableContext:
	var ctx := TableContext.new()
	ctx.host = self
	ctx.player_bottom_hand = _player_bottom_hand
	ctx.animation_layer = _animation_layer
	ctx.top_menu_bar = _top_menu_bar
	ctx.confirm_dialog = _confirm_dialog
	ctx.match_end_dialog = _match_end_dialog
	ctx.hand_end_dialog = _hand_end_dialog
	ctx.match_scoreboard = _match_scoreboard
	ctx.trick_area = _trick_area
	ctx.background_color = _background_color
	ctx.background_texture = _background_texture
	ctx.seats = _seats
	ctx.trick_slots = _trick_slots
	return ctx


func _start_new_match() -> void:
	await TableMatchFlow.start_new_match(_ctx)


func _dispatch_human_card_selected(card_view: Control, card: CardModel) -> void:
	TablePlayFlow.on_human_card_selected(_ctx, card_view, card)


func _on_top_menu_bar_scores_pressed() -> void:
	_scores_screen.open()


func _on_top_menu_bar_new_game_pressed() -> void:
	if not TableServiceAccess.session(self).match_in_progress:
		await TableMatchFlow.on_replay_requested(_ctx)
		return
	_confirm_action = ConfirmAction.RESTART_MATCH
	_confirm_dialog.open(DialogCopy.restart_match_confirm())


func _on_top_menu_bar_hamburger_pressed() -> void:
	_match_scoreboard.visible = not _match_scoreboard.visible


func _on_top_menu_bar_help_pressed() -> void:
	_help_screen.open()


func _on_top_menu_bar_settings_pressed() -> void:
	_settings_screen.open()


func _on_locale_changed(_locale: String = "") -> void:
	if _ctx != null:
		TableLocale.apply(_ctx)


func _on_top_menu_bar_menu_pressed() -> void:
	if TableServiceAccess.session(self).match_in_progress:
		_confirm_action = ConfirmAction.LEAVE_MATCH
		_confirm_dialog.open(DialogCopy.leave_match_confirm())
	else:
		TableMatchFlow.return_to_main_menu(_ctx)


func _on_confirm_dialog_confirmed() -> void:
	match _confirm_action:
		ConfirmAction.LEAVE_MATCH:
			TableMatchFlow.on_leave_match_confirmed(_ctx)
		ConfirmAction.RESTART_MATCH:
			await TableMatchFlow.on_replay_requested(_ctx)
	_confirm_action = ConfirmAction.NONE


func _on_match_end_replay_requested() -> void:
	await TableMatchFlow.on_replay_requested(_ctx)


func _on_match_end_quit_requested() -> void:
	TableMatchFlow.on_quit_requested(_ctx)
