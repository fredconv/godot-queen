class_name Suit
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

## Libellé français d'affichage (debug, UI future).
static func to_display_name(suit: int) -> String:
	match suit:
		CLUBS:
			return "Trèfle"
		DIAMONDS:
			return "Carreau"
		SPADES:
			return "Pique"
		HEARTS:
			return "Cœur"
		_:
			return "?"
