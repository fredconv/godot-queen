class_name TableMatchFlow
extends RefCounted
## Cycle de vie d'une partie : démarrage, navigation menu, popups fin de manche/partie.


static func start_new_match(ctx: TableContext, seed_value: int = -1) -> void:
	ctx.turn_locked = false
	ctx.match_end_dialog.close()
	ctx.hand_end_dialog.close()
	clear_trick_cards(ctx)

	ctx.match_controller = LocalMatchController.new()
	ctx.match_manager = ctx.match_controller.match_manager
	for player_index in range(1, HeartsRules.PLAYER_COUNT):
		ctx.match_manager.set_ai_player(player_index, AiPlayer.new())
	ctx.match_controller.start_new_match(seed_value)

	await TableDealing.play_sequence(ctx)
	if not ctx.is_active():
		return
	TableLocale.apply(ctx)
	TableDisplay.refresh_scores(ctx)
	TableDisplay.refresh_turn_ui(ctx)
	await TablePlayFlow.run_ai_turns(ctx)


static func clear_trick_cards(ctx: TableContext) -> void:
	for card_view in ctx.trick_card_views.values():
		(card_view as Control).queue_free()
	ctx.trick_card_views.clear()
	if ctx.match_manager:
		TableFx.refresh_lead_suit_indicator(ctx)


static func on_replay_requested(ctx: TableContext) -> void:
	clear_trick_cards(ctx)
	ctx.match_end_dialog.close()
	await start_new_match(ctx)


static func on_quit_requested(ctx: TableContext) -> void:
	clear_trick_cards(ctx)
	ctx.match_end_dialog.close()
	return_to_main_menu(ctx)


static func return_to_main_menu(ctx: TableContext) -> void:
	ctx.scene_exiting = true
	ctx.host.get_tree().call_deferred("change_scene_to_file", TableConstants.MAIN_MENU_SCENE_PATH)


static func on_menu_pressed(ctx: TableContext) -> void:
	if TableServiceAccess.session(ctx.host).match_in_progress:
		ctx.confirm_dialog.open(DialogCopy.leave_match_confirm())
	else:
		return_to_main_menu(ctx)


static func on_leave_match_confirmed(ctx: TableContext) -> void:
	TableServiceAccess.session(ctx.host).end_match()
	return_to_main_menu(ctx)


static func show_hand_end_popup(ctx: TableContext) -> void:
	var winner_index: int = ctx.match_manager.get_last_hand_winner()
	_play_hand_end_seat_reactions(ctx, winner_index)
	var names: Array = []
	var character_ids: Array = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		names.append(ctx.seats[player_index].player_name)
		character_ids.append(ctx.seats[player_index].character_id)
	ctx.hand_end_dialog.show_result(
		winner_index,
		names,
		ctx.match_manager.last_hand_scores,
		ctx.match_manager.score_manager.get_scores(),
		character_ids
	)
	await ctx.hand_end_dialog.continue_requested
	if not ctx.is_active():
		return


static func show_match_end_popup(ctx: TableContext) -> void:
	if ctx.match_end_dialog.visible:
		return
	TableDisplay.refresh_turn_ui(ctx)
	var winner_index: int = ctx.match_manager.get_match_winner()
	var names: Array = []
	var character_ids: Array = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		names.append(ctx.seats[player_index].player_name)
		character_ids.append(ctx.seats[player_index].character_id)
	ctx.match_end_dialog.show_result(
		winner_index,
		names,
		ctx.match_manager.score_manager.get_scores(),
		ctx.match_manager.last_hand_scores,
		character_ids
	)
	if winner_index == TableConstants.HUMAN_INDEX:
		ctx.victory_petals.play()


static func _play_hand_end_seat_reactions(ctx: TableContext, hand_winner_index: int) -> void:
	for player_index in range(HeartsRules.PLAYER_COUNT):
		if player_index == hand_winner_index:
			ctx.seats[player_index].play_hand_win_reaction()
		else:
			ctx.seats[player_index].play_hand_loss_reaction()
