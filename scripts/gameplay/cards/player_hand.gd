class_name PlayerHand
extends RefCounted
## Main d'un joueur : ensemble de cartes détenues, maintenue triée (couleur
## puis rang) pour un affichage stable. Pure logique de données, testable
## hors scène (voir tests/unit/test_player_hand.gd).

var _cards: Array[CardModel] = []

func add_card(card: CardModel) -> void:
	_cards.append(card)
	_sort()

## Retire la première carte égale à `card`. Retourne `true` si une carte a
## été retirée, `false` si elle n'était pas dans la main.
func remove_card(card: CardModel) -> bool:
	for i in range(_cards.size()):
		if _cards[i].equals(card):
			_cards.remove_at(i)
			return true
	return false

func contains(card: CardModel) -> bool:
	for existing_card in _cards:
		if existing_card.equals(card):
			return true
	return false

## Copie des cartes de la main, triées par couleur puis par rang croissant.
func cards() -> Array[CardModel]:
	return _cards.duplicate()

func count() -> int:
	return _cards.size()

func is_empty() -> bool:
	return _cards.is_empty()

func _sort() -> void:
	_cards.sort_custom(_is_before)

static func _is_before(a: CardModel, b: CardModel) -> bool:
	if a.suit != b.suit:
		return a.suit < b.suit
	return a.rank < b.rank
