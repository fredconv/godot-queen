class_name ScoreManager
extends RefCounted
## Scores cumulés des 4 joueurs sur une partie (plusieurs manches successives).
## Pure logique de données (`RefCounted`, pas de nœud Godot), testable hors
## scène. Orchestré par `MatchManager` (étape 4).

var _scores: Array[int] = [0, 0, 0, 0]

## Ajoute les points d'une manche aux scores cumulés. `hand_scores` est un
## dictionnaire `{player_index: int -> points: int}` : le format retourné
## directement par `RuleEngine.score_hand()`, pour éviter une conversion
## inutile côté `MatchManager` (voir docs/TECHNICAL_DESIGN.md).
func add_hand_scores(hand_scores: Dictionary) -> void:
	for player_index in hand_scores.keys():
		_scores[player_index] += hand_scores[player_index]

## Copie des scores cumulés, indexés par `player_index`.
func get_scores() -> Array[int]:
	return _scores.duplicate()

func get_score(player_index: int) -> int:
	return _scores[player_index]

## Réinitialise les scores cumulés à zéro (début d'une nouvelle partie).
func reset() -> void:
	_scores = [0, 0, 0, 0]
