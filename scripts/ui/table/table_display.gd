class_name TableDisplay
extends RefCounted
## Rafraîchissement de l'affichage : scores, tour actif, légalité de la main.


static func refresh_opponent_hand_counts(ctx: TableContext) -> void:
	for player_index in range(HeartsRules.PLAYER_COUNT):
		ctx.seats[player_index].hand_card_count = ctx.match_manager.hands[player_index].count()


static func refresh_scores(ctx: TableContext) -> void:
	var hand_scores: Array = ctx.match_manager.get_current_hand_raw_scores()
	var hearts: Array = ctx.match_manager.get_current_hand_hearts_captured()
	for player_index in range(HeartsRules.PLAYER_COUNT):
		ctx.seats[player_index].score = hand_scores[player_index]
		ctx.seats[player_index].heart_penalty = hearts[player_index]
	refresh_cumulative_scoreboard(ctx)


static func refresh_cumulative_scoreboard(ctx: TableContext) -> void:
	var names: Array = []
	for seat in ctx.seats:
		names.append(seat.player_name)
	ctx.match_scoreboard.update_display(
		ctx.match_manager.hand_number,
		names,
		ctx.match_manager.score_manager.get_scores()
	)


static func refresh_turn_ui(ctx: TableContext) -> void:
	var playing: bool = ctx.match_manager.phase == MatchManager.Phase.PLAYING
	var local_seat: int = ctx.get_local_human_seat()
	for player_index in range(HeartsRules.PLAYER_COUNT):
		ctx.seats[player_index].set_active_turn(playing and player_index == ctx.match_manager.current_player)

	if playing:
		if ctx.is_local_human_turn():
			ctx.top_menu_bar.set_turn_text(_human_turn_hint_text(ctx, local_seat))
		else:
			ctx.top_menu_bar.set_turn_text(
				TableCopy.opponent_turn_line(ctx.seats[ctx.match_manager.current_player].player_name)
			)
		var hand_score: int = ctx.match_manager.get_current_hand_raw_scores()[local_seat]
		var match_score: int = ctx.match_manager.score_manager.get_score(local_seat)
		ctx.top_menu_bar.set_score_text(TableCopy.hand_match_score_line(hand_score, match_score))

	refresh_human_hand_legality(ctx)
	TableFx.refresh_lead_suit_indicator(ctx)


static func refresh_human_hand_legality(ctx: TableContext) -> void:
	var legal: Array[CardModel] = current_human_legal_plays(ctx)
	var allow_play: bool = not ctx.turn_locked
	for i in ctx.hand_card_views.size():
		var card_view: Control = ctx.hand_card_views[i]
		var card: CardModel = ctx.hand_cards[i]
		var is_legal: bool = allow_play and card_in_list(card, legal)
		card_view.modulate = Color.WHITE
		card_view.set_playable(is_legal)
		card_view.mouse_filter = Control.MOUSE_FILTER_STOP if is_legal else Control.MOUSE_FILTER_IGNORE


static func _human_turn_hint_text(ctx: TableContext, local_seat: int) -> String:
	var is_leading := ctx.match_manager.trick_manager.played_count() == 0
	var rule_engine: RuleEngine = ctx.match_manager.rule_engine
	var must_play_two_of_clubs := false
	var hearts_not_broken_lead := false

	if is_leading and rule_engine.is_first_trick:
		var legal := ctx.match_manager.get_legal_plays(local_seat)
		must_play_two_of_clubs = legal.size() == 1 and HeartsRules.is_two_of_clubs(legal[0])
		return TableCopy.human_turn_hint(true, must_play_two_of_clubs, false)

	if is_leading and not rule_engine.hearts_broken:
		for card in ctx.match_manager.get_legal_plays(local_seat):
			if not card.is_heart():
				hearts_not_broken_lead = true
				break
		return TableCopy.human_turn_hint(false, false, hearts_not_broken_lead)

	return TableCopy.human_turn_hint(false, false, false)


static func current_human_legal_plays(ctx: TableContext) -> Array[CardModel]:
	var local_seat: int = ctx.get_local_human_seat()
	if ctx.match_manager.phase != MatchManager.Phase.PLAYING \
			or ctx.match_manager.current_player != local_seat:
		return []
	return ctx.match_manager.get_legal_plays(local_seat)


static func card_in_list(card: CardModel, cards: Array[CardModel]) -> bool:
	for existing_card in cards:
		if existing_card.equals(card):
			return true
	return false
