class_name Rank
extends RefCounted
## Rangs d'une carte à jouer. Valeurs entières explicites (2 à 14) plutôt
## qu'un enum 0-based : la valeur correspond directement au rang réel de la
## carte, ce qui rend les comparaisons de force et le débogage plus lisibles
## (pas de décalage caché à retenir).

enum {
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	JACK = 11,
	QUEEN = 12,
	KING = 13,
	ACE = 14,
}

const MIN: int = TWO
const MAX: int = ACE

const ALL: Array[int] = [
	TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE,
]


static func to_display_name(rank: int) -> String:
	return GameCopy.rank_name(rank)
