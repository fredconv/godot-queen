class_name CardModel
extends RefCounted
## Représentation d'une carte à jouer (couleur + rang). Aucune dépendance à
## un nœud Godot : entièrement testable hors scène (voir
## tests/unit/test_card_model.gd). Choix suit+rank plutôt qu'un simple id
## documenté en docs/DECISIONS.md (ADR-011).

const CARDS_PER_SUIT: int = 13

var suit: int
var rank: int

func _init(suit_value: int, rank_value: int) -> void:
	suit = suit_value
	rank = rank_value

## Identifiant unique 0-51, dérivé de suit/rank. Pratique pour l'indexation,
## le hachage ou une future sérialisation compacte ; n'est pas la source de
## vérité (suit/rank le reste, voir ADR-011).
func get_id() -> int:
	return suit * CARDS_PER_SUIT + (rank - Rank.MIN)

func equals(other: CardModel) -> bool:
	return other != null and suit == other.suit and rank == other.rank

func is_heart() -> bool:
	return suit == Suit.HEARTS

func is_spade() -> bool:
	return suit == Suit.SPADES

func is_queen_of_spades() -> bool:
	return suit == Suit.SPADES and rank == Rank.QUEEN

## Compare la force de deux cartes de la MÊME couleur (rang le plus élevé
## gagne). Utilitaire de modèle de données uniquement : ne gère ni l'atout
## ni la résolution complète d'un pli (couleur demandée, etc.), voir
## `scripts/rules/` (étape 3) pour la logique de jeu réelle. Retourne un
## entier négatif/nul/positif comme un comparateur classique.
func compare_rank(other: CardModel) -> int:
	assert(suit == other.suit, "compare_rank ne compare que des cartes de même couleur")
	return rank - other.rank

## Représentation lisible pour le débogage (ex. "Dame de Pique"). Redéfinit
## `_to_string()` (méthode virtuelle native appelée par `str()`/l'inspecteur) :
## un simple `to_string()` custom est refusé par Godot (nom réservé sur
## `Object`, avertissement traité comme erreur), voir docs/DECISIONS.md ADR-011.
func _to_string() -> String:
	return "%s de %s" % [Rank.to_display_name(rank), Suit.to_display_name(suit)]

## Construit une carte à partir de son identifiant unique (0-51).
static func from_id(id: int) -> CardModel:
	assert(id >= 0 and id < 52, "id de carte invalide : %d" % id)
	var suit_value: int = id / CARDS_PER_SUIT
	var rank_value: int = (id % CARDS_PER_SUIT) + Rank.MIN
	return CardModel.new(suit_value, rank_value)

## Génère les 52 cartes d'un jeu standard, dans un ordre canonique et stable
## (couleur puis rang croissant) — sans mélange.
static func all_cards() -> Array[CardModel]:
	var cards: Array[CardModel] = []
	for suit_value in Suit.ALL:
		for rank_value in Rank.ALL:
			cards.append(CardModel.new(suit_value, rank_value))
	return cards
