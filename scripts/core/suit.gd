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


## Symbole Unicode pour l'affichage UI (indicateur de couleur demandée).
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


## Texte court pour l'indicateur de pli (« ♥ Cœur demandé »).
static func to_lead_indicator_text(suit: int) -> String:
	return "%s %s demandé" % [to_symbol(suit), to_display_name(suit)]
