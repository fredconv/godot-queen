class_name DialogCopy
extends RefCounted
## Textes formatés des dialogues (fin de manche, fin de partie, confirmations).


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


static func leave_match_confirm() -> String:
	return _t(DialogKeys.CONFIRM_LEAVE_MATCH)


static func hand_winner_line(player_name: String) -> String:
	return _t(DialogKeys.HAND_WINNER) % player_name


static func hand_winner_detail(hand_score: int, match_score: int) -> String:
	return _t(DialogKeys.HAND_WINNER_DETAIL) % [hand_score, match_score]


static func hand_score_row(prefix: String, player_name: String, hand_score: int, total_score: int) -> String:
	return _t(DialogKeys.HAND_SCORE_ROW) % [prefix, player_name, hand_score, total_score]


static func match_winner_line(player_name: String) -> String:
	return _t(DialogKeys.MATCH_WINNER) % player_name


static func match_winner_detail(hand_score: int, match_score: int) -> String:
	return _t(DialogKeys.MATCH_WINNER_DETAIL) % [hand_score, match_score]


static func match_score_row(prefix: String, player_name: String, hand_score: int, total_score: int) -> String:
	return _t(DialogKeys.MATCH_SCORE_ROW) % [prefix, player_name, hand_score, total_score]


static func winner_prefix(is_winner: bool) -> String:
	return "★ " if is_winner else "   "
