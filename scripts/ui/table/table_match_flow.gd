class_name TableMatchFlow
extends RefCounted
## Cycle de vie d'une partie : démarrage, navigation menu, popups fin de manche/partie.


static func start_new_match(ctx: TableContext, seed_value: int = -1) -> void:
	ctx.turn_locked = false
	ctx.match_end_dialog.close()
	ctx.hand_end_dialog.close()
	clear_trick_cards(ctx)

	ctx.launch_config = GameSession.take_launch_config()
	var match_seed: int = seed_value
	if match_seed < 0 and GameSession.online_match_seed >= 0:
		match_seed = GameSession.online_match_seed
		GameSession.online_match_seed = -1
	_setup_match_controller(ctx)
	SeatSetup.apply_ai_to_match_manager(ctx.match_manager, ctx.launch_config.seat_assignments)
	ctx.match_controller.start_new_match(match_seed)

	await TableDealing.play_sequence(ctx)
	if not ctx.is_active():
		return
	TableLocale.apply(ctx)
	TableDisplay.refresh_scores(ctx)
	TableDisplay.refresh_turn_ui(ctx)
	if not ctx.is_online_client():
		await TablePlayFlow.run_ai_turns(ctx)
	await TableHotSeat.ensure_local_human_ready(ctx)


static func _setup_match_controller(ctx: TableContext) -> void:
	if ctx.launch_config.mode == MatchMode.Type.ONLINE_HOST:
		var host_controller := HostMatchController.new()
		ctx.match_controller = host_controller
		ctx.match_manager = host_controller.match_controller.match_manager
		NetworkMatchRelay.register_table(ctx, host_controller)
	elif ctx.launch_config.mode == MatchMode.Type.ONLINE_CLIENT:
		var client_controller := ClientMatchController.new()
		ctx.match_controller = client_controller
		ctx.match_manager = client_controller.match_controller.match_manager
		NetworkMatchRelay.register_table(ctx)
	else:
		ctx.match_controller = LocalMatchController.new()
		ctx.match_manager = (ctx.match_controller as LocalMatchController).match_manager


static func clear_trick_cards(ctx: TableContext) -> void:
	for card_view in ctx.trick_card_views.values():
		(card_view as Control).queue_free()
	ctx.trick_card_views.clear()
	if ctx.match_manager:
		TableFx.refresh_lead_suit_indicator(ctx)


static func on_replay_requested(ctx: TableContext) -> void:
	clear_trick_cards(ctx)
	ctx.match_end_dialog.close()
	if ctx.launch_config != null:
		GameSession.set_launch_config(ctx.launch_config)
	await start_new_match(ctx)


static func on_quit_requested(ctx: TableContext) -> void:
	clear_trick_cards(ctx)
	ctx.match_end_dialog.close()
	return_to_main_menu(ctx)


static func return_to_main_menu(ctx: TableContext) -> void:
	ctx.scene_exiting = true
	NetworkMatchRelay.unregister_table()
	if NetworkService.is_online():
		NetworkService.disconnect_from_host()
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
	if winner_index == ctx.get_local_human_seat():
		ctx.victory_petals.play()


static func _play_hand_end_seat_reactions(ctx: TableContext, hand_winner_index: int) -> void:
	for player_index in range(HeartsRules.PLAYER_COUNT):
		if player_index == hand_winner_index:
			ctx.seats[player_index].play_hand_win_reaction()
		else:
			ctx.seats[player_index].play_hand_loss_reaction()
