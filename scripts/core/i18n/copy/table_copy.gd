class_name TableCopy
extends RefCounted
## Textes formatés de la table (hints, barre de menu, scoreboard).
## Logique pure : délègue à `TranslationServer` et aux clés `TableKeys`.


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


static func default_player_name(player_index: int) -> String:
	if player_index == 0:
		return _t(TableKeys.PLAYER_YOU)
	return _t(TableKeys.PLAYER_OPPONENT) % player_index


static func hand_match_score_line(hand_score: int, match_score: int) -> String:
	return _t(TableKeys.SCORE_HAND_MATCH) % [hand_score, match_score]


static func opponent_turn_line(player_name: String) -> String:
	return _t(TableKeys.TURN_OPPONENT) % player_name


static func human_turn_hint(
	is_first_trick_lead: bool,
	must_play_two_of_clubs: bool,
	hearts_not_broken_lead: bool
) -> String:
	if is_first_trick_lead and must_play_two_of_clubs:
		return _t(TableKeys.TURN_TWO_CLUBS)
	if is_first_trick_lead:
		return _t(TableKeys.TURN_FIRST_TRICK)
	if hearts_not_broken_lead:
		return _t(TableKeys.TURN_HEARTS_NOT_BROKEN)
	return _t(TableKeys.TURN_YOUR_PLAY)


static func scoreboard_title(hand_number: int, goal_points: int) -> String:
	return _t(TableKeys.SCOREBOARD_TITLE) % [hand_number, goal_points]


static func theme_label(theme_id: StringName) -> String:
	var normalized: StringName = TableThemePaths.normalize_theme_id(theme_id)
	if normalized == TableThemePaths.THEME_TAPIS:
		return _t(TableKeys.THEME_TAPIS)
	return _t(TableKeys.THEME_CLASSIC)


static func music_toggle_label(enabled: bool) -> String:
	return _t(TableKeys.TOP_MUSIC_ON) if enabled else _t(TableKeys.TOP_MUSIC_OFF)


static func help_rules_body() -> String:
	return "\n".join([
		_t(TableKeys.HELP_RULE_1),
		_t(TableKeys.HELP_RULE_2),
		_t(TableKeys.HELP_RULE_3),
		_t(TableKeys.HELP_RULE_4),
	])
