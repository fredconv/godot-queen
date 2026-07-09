class_name TableSeatDisplayMap
extends RefCounted
## Mapping siège logique (moteur) → emplacement visuel (UI) pour le hot seat.
## Le pivot est le joueur humain actif : il est toujours affiché en bas.


enum VisualSlot { BOTTOM = 0, LEFT = 1, TOP = 2, RIGHT = 3 }


static func get_pivot_seat(ctx: TableContext) -> int:
	if ctx.launch_config != null and ctx.launch_config.is_hot_seat_multi_human():
		var active: int = ctx.launch_config.active_human_seat_index
		if active >= 0:
			return active
	return TableConstants.HUMAN_INDEX


static func visual_slot_for_logical_seat(logical_seat: int, pivot_seat: int) -> int:
	return (logical_seat - pivot_seat + HeartsRules.PLAYER_COUNT) % HeartsRules.PLAYER_COUNT


static func logical_seat_for_visual_slot(visual_slot: int, pivot_seat: int) -> int:
	return (visual_slot + pivot_seat) % HeartsRules.PLAYER_COUNT


static func uses_rotation(ctx: TableContext) -> bool:
	return ctx.is_hot_seat_multi_human()


static func get_seat_node(ctx: TableContext, logical_seat: int) -> PlayerSeat:
	var pivot: int = get_pivot_seat(ctx)
	var visual_slot: int = visual_slot_for_logical_seat(logical_seat, pivot)
	return ctx.seats[visual_slot]


static func get_trick_slot(ctx: TableContext, logical_seat: int) -> Control:
	var pivot: int = get_pivot_seat(ctx)
	var visual_slot: int = visual_slot_for_logical_seat(logical_seat, pivot)
	return ctx.trick_slots[visual_slot]


static func get_logical_display_name(ctx: TableContext, logical_seat: int) -> String:
	if ctx.launch_config != null:
		return ctx.launch_config.get_display_name_for_seat(logical_seat)
	if logical_seat == TableConstants.HUMAN_INDEX:
		return PlayerProfileService.get_display_name()
	return TableCopy.default_player_name(logical_seat)


static func apply(ctx: TableContext) -> void:
	if ctx.match_manager == null:
		return
	if not uses_rotation(ctx):
		return

	var pivot: int = get_pivot_seat(ctx)
	var hands_revealed: bool = ctx.launch_config.hands_revealed_for_active_human
	var playing: bool = ctx.match_manager.phase == MatchManager.Phase.PLAYING
	var current_player: int = ctx.match_manager.current_player
	var hand_scores: Array = ctx.match_manager.get_current_hand_raw_scores()
	var hearts: Array = ctx.match_manager.get_current_hand_hearts_captured()

	for visual_slot in range(HeartsRules.PLAYER_COUNT):
		var logical_seat: int = logical_seat_for_visual_slot(visual_slot, pivot)
		var seat: PlayerSeat = ctx.seats[visual_slot]
		seat.player_name = get_logical_display_name(ctx, logical_seat)
		seat.character_id = logical_seat
		seat.score = hand_scores[logical_seat]
		seat.heart_penalty = hearts[logical_seat]
		seat.hand_card_count = ctx.match_manager.hands[logical_seat].count()
		seat.set_active_turn(playing and logical_seat == current_player)
		var is_pivot_at_bottom: bool = visual_slot == VisualSlot.BOTTOM
		seat.show_hand_back = not is_pivot_at_bottom or not hands_revealed

	if ctx.human_hand_area != null:
		ctx.human_hand_area.visible = hands_revealed and pivot >= 0
