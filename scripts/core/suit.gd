class_name Suit
extends RefCounted
## Couleurs d'une carte à jouer. Ordre volontairement arbitraire mais stable
## (utilisé pour calculer l'identifiant unique d'une carte, voir
## `CardModel.get_id()` et docs/DECISIONS.md ADR-011) : ne pas réordonner
## sans mettre à jour les tests qui dépendent des ids de carte.

enum {
	CLUBS,
	DIAMONDS,
	SPADES,
	HEARTS,
}

const ALL: Array[int] = [CLUBS, DIAMONDS, SPADES, HEARTS]


static func to_display_name(suit: int) -> String:
	return GameCopy.suit_name(suit)


static func to_symbol(suit: int) -> String:
	match suit:
		CLUBS:
			return "♣"
		DIAMONDS:
			return "♦"
		SPADES:
			return "♠"
		HEARTS:
			return "♥"
		_:
			return "?"


static func to_lead_indicator_text(suit: int) -> String:
	return GameCopy.lead_indicator(suit)
