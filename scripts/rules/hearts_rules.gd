class_name HeartsRules
extends RefCounted
## Constantes et requêtes pures sur les règles du Dame de Pique (Hearts),
## sans aucun état de partie (pas de notion de "pli en cours" ou de "Cœurs
## défoncés" ici, voir `RuleEngine` pour la logique avec état). Entièrement
## testable hors scène (voir tests/unit/test_rule_engine.gd).

const PLAYER_COUNT: int = 4
const CARDS_PER_HAND: int = 13

## Points marqués par carte capturée. Voir docs/GDD.md pour le détail des
## règles de score.
const HEART_POINTS: int = 1
const QUEEN_OF_SPADES_POINTS: int = 13

## Total de points en jeu dans une manche (13 Cœurs x 1 pt + Dame de Pique).
## Sert aussi de seuil de détection du "shoot the moon" (voir
## docs/DECISIONS.md ADR-016).
const TOTAL_POINTS_PER_HAND: int = HEART_POINTS * CardModel.CARDS_PER_SUIT + QUEEN_OF_SPADES_POINTS

## Carte qui doit obligatoirement entamer le tout premier pli d'une manche.
static func is_two_of_clubs(card: CardModel) -> bool:
	return card.suit == Suit.CLUBS and card.rank == Rank.TWO

## Une carte "à points" : n'importe quel Cœur, ou la Dame de Pique.
static func is_penalty_card(card: CardModel) -> bool:
	return card.is_heart() or card.is_queen_of_spades()

## Valeur en points d'une carte capturée dans un pli (0 si carte neutre).
static func card_points(card: CardModel) -> int:
	if card.is_queen_of_spades():
		return QUEEN_OF_SPADES_POINTS
	if card.is_heart():
		return HEART_POINTS
	return 0

## `true` si `cards` est non vide et ne contient que des Cœurs. Cas
## exceptionnel qui autorise à entamer un pli avec un Cœur avant que les
## Cœurs soient défoncés.
static func has_only_hearts(cards: Array[CardModel]) -> bool:
	if cards.is_empty():
		return false
	for card in cards:
		if not card.is_heart():
			return false
	return true

## `true` si `cards` est non vide et ne contient que des cartes "à points"
## (Cœurs et/ou Dame de Pique). Cas exceptionnel qui autorise à jouer une
## carte à points au tout premier pli, faute d'alternative.
static func has_only_penalty_cards(cards: Array[CardModel]) -> bool:
	if cards.is_empty():
		return false
	for card in cards:
		if not is_penalty_card(card):
			return false
	return true
