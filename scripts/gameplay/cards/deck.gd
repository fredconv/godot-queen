class_name Deck
extends RefCounted
## Paquet de cartes : ordre courant de pioche + mélange. Pure logique de
## données (RefCounted, pas de nœud Godot), testable hors scène (voir
## tests/unit/test_deck.gd).

var _cards: Array[CardModel] = []

func _init() -> void:
	reset()

## Fabrique un paquet standard de 52 cartes, non mélangé.
static func create_standard_52() -> Deck:
	return Deck.new()

## Réinitialise le paquet à l'ordre canonique de `CardModel.all_cards()`
## (couleur puis rang croissant), sans mélange.
func reset() -> void:
	_cards = CardModel.all_cards()

## Mélange le paquet en place (Fisher-Yates). `seed_value` optionnel : fournir
## une valeur >= 0 donne un mélange déterministe (même seed -> même ordre),
## utile pour des tests ou des replays reproductibles.
func shuffle(seed_value: int = -1) -> void:
	var rng := RandomNumberGenerator.new()
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	for i in range(_cards.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: CardModel = _cards[i]
		_cards[i] = _cards[j]
		_cards[j] = tmp

## Retire et retourne jusqu'à `count` cartes du dessus du paquet (moins si
## le paquet est épuisé avant).
func deal(count: int) -> Array[CardModel]:
	var dealt: Array[CardModel] = []
	for _i in range(count):
		var card: CardModel = draw()
		if card == null:
			break
		dealt.append(card)
	return dealt

## Retire et retourne la carte du dessus du paquet, ou `null` si vide.
func draw() -> CardModel:
	if _cards.is_empty():
		return null
	return _cards.pop_back()

## Nombre de cartes restantes dans le paquet.
func size() -> int:
	return _cards.size()

## Consulte la carte du dessus sans la retirer (`null` si le paquet est vide).
func peek() -> CardModel:
	if _cards.is_empty():
		return null
	return _cards[-1]

func is_empty() -> bool:
	return _cards.is_empty()
