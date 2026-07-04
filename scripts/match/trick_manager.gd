class_name TrickManager
extends RefCounted
## Gère l'état du pli en cours (cartes posées dans l'ordre de jeu, couleur
## demandée) pour une manche orchestrée par `MatchManager` (étape 4). Pure
## logique de données (`RefCounted`, pas de nœud Godot), s'appuie sur
## `RuleEngine.get_trick_winner()` (étape 3) pour la résolution du vainqueur.

## Cartes posées dans l'ordre de jeu, chaque entrée étant un dictionnaire
## `{"player_index": int, "card": CardModel}` (même format que celui attendu
## par `RuleEngine.get_trick_winner()`).
var _plays: Array[Dictionary] = []

## Couleur demandée par le pli en cours (`Suit.*`), `-1` si aucune carte n'a
## encore été posée (pli vide).
var lead_suit: int = -1

## Ajoute la carte jouée par `player_index` à la fin du pli en cours. La
## première carte posée fixe `lead_suit`.
func add_play(player_index: int, card: CardModel) -> void:
	if _plays.is_empty():
		lead_suit = card.suit
	_plays.append({"player_index": player_index, "card": card})

## `true` une fois que les 4 joueurs ont posé une carte dans le pli en cours.
func is_complete() -> bool:
	return _plays.size() == HeartsRules.PLAYER_COUNT

## Nombre de cartes déjà posées dans le pli en cours (0 à 4). Utile à
## l'appelant pour savoir si le prochain joueur entame le pli (`== 0`).
func played_count() -> int:
	return _plays.size()

## Index du joueur vainqueur du pli complet (voir `RuleEngine.get_trick_winner`).
## Ne doit être appelé que si `is_complete()` est vrai.
func get_winner() -> int:
	return RuleEngine.get_trick_winner(_plays)

## Cartes posées dans le pli en cours, dans l'ordre de jeu (copie).
func get_cards() -> Array[CardModel]:
	var cards: Array[CardModel] = []
	for play in _plays:
		cards.append(play["card"])
	return cards

## Cartes posées dans le pli en cours, avec l'index du joueur ayant joué
## chacune (copie, même format `{"player_index": int, "card": CardModel}` que
## `RuleEngine.get_trick_winner()`). Utile à l'IA (étape 5) pour connaître la
## carte actuellement gagnante du pli, contrairement à `get_cards()` qui perd
## l'information du joueur.
func get_plays() -> Array[Dictionary]:
	return _plays.duplicate()

## Remet le pli à zéro (à appeler après résolution, avant le pli suivant).
func reset() -> void:
	_plays = []
	lead_suit = -1
