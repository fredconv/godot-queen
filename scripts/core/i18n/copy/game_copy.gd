class_name GameCopy
extends RefCounted
## Textes formatés liés aux cartes, couleurs et sièges joueur.


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


static func suit_name(suit: int) -> String:
	match suit:
		Suit.CLUBS:
			return _t(GameKeys.SUIT_CLUBS)
		Suit.DIAMONDS:
			return _t(GameKeys.SUIT_DIAMONDS)
		Suit.SPADES:
			return _t(GameKeys.SUIT_SPADES)
		Suit.HEARTS:
			return _t(GameKeys.SUIT_HEARTS)
		_:
			return _t(GameKeys.SUIT_UNKNOWN)


static func rank_name(rank: int) -> String:
	match rank:
		Rank.JACK:
			return _t(GameKeys.RANK_JACK)
		Rank.QUEEN:
			return _t(GameKeys.RANK_QUEEN)
		Rank.KING:
			return _t(GameKeys.RANK_KING)
		Rank.ACE:
			return _t(GameKeys.RANK_ACE)
		_:
			return str(rank)


static func card_description(rank: int, suit: int) -> String:
	var rank_str := rank_name(rank)
	var suit_str := suit_name(suit)
	if LocaleCatalog.normalize(TranslationServer.get_locale()) == "zh":
		return _t(GameKeys.CARD_OF) % [suit_str, rank_str]
	return _t(GameKeys.CARD_OF) % [rank_str, suit_str]


static func lead_indicator(suit: int) -> String:
	return _t(GameKeys.LEAD_SUIT) % [Suit.to_symbol(suit), suit_name(suit)]


static func default_seat_name() -> String:
	return _t(GameKeys.SEAT_DEFAULT_NAME)


static func seat_score_parens(score: int) -> String:
	return _t(GameKeys.SEAT_SCORE_PARENS) % score


static func seat_hearts_count(count: int) -> String:
	return _t(GameKeys.SEAT_HEARTS) % count


static func seat_score_tooltip() -> String:
	return _t(GameKeys.SEAT_SCORE_TOOLTIP)
