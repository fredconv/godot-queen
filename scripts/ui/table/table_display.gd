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
	for player_index in range(HeartsRules.PLAYER_COUNT):
		ctx.seats[player_index].set_active_turn(playing and player_index == ctx.match_manager.current_player)

	if playing:
		if ctx.match_manager.current_player == TableConstants.HUMAN_INDEX:
			ctx.top_menu_bar.set_turn_text(_human_turn_hint_text(ctx))
		else:
			ctx.top_menu_bar.set_turn_text(
				"%s joue..." % ctx.seats[ctx.match_manager.current_player].player_name
			)
		var hand_score: int = ctx.match_manager.get_current_hand_raw_scores()[TableConstants.HUMAN_INDEX]
		var match_score: int = ctx.match_manager.score_manager.get_score(TableConstants.HUMAN_INDEX)
		ctx.top_menu_bar.set_score_text("Manche : %d pts  |  Partie : %d pts" % [hand_score, match_score])

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


static func _human_turn_hint_text(ctx: TableContext) -> String:
	var is_leading := ctx.match_manager.trick_manager.played_count() == 0
	var rule_engine: RuleEngine = ctx.match_manager.rule_engine

	if is_leading and rule_engine.is_first_trick:
		var legal := ctx.match_manager.get_legal_plays(TableConstants.HUMAN_INDEX)
		if legal.size() == 1 and HeartsRules.is_two_of_clubs(legal[0]):
			return "À vous — jouez le 2 de Trèfle"
		return "À vous de jouer (1er pli : pas de points)"

	if is_leading and not rule_engine.hearts_broken:
		for card in ctx.match_manager.get_legal_plays(TableConstants.HUMAN_INDEX):
			if not card.is_heart():
				return "À vous — les Cœurs ne sont pas encore défoncés"

	return "À vous de jouer"


static func current_human_legal_plays(ctx: TableContext) -> Array[CardModel]:
	if ctx.match_manager.phase != MatchManager.Phase.PLAYING \
			or ctx.match_manager.current_player != TableConstants.HUMAN_INDEX:
		return []
	return ctx.match_manager.get_legal_plays(TableConstants.HUMAN_INDEX)


static func card_in_list(card: CardModel, cards: Array[CardModel]) -> bool:
	for existing_card in cards:
		if existing_card.equals(card):
			return true
	return false
