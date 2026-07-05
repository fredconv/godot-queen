extends Node
## GameEvents (autoload)
## Bus de signaux transversal : découple UI, logique de jeu et services entre eux.
## Ne contient aucune logique métier, uniquement des déclarations de signaux.

signal match_started
signal match_ended(winner_id: int)
signal card_played(player_id: int, card: CardModel)
signal trick_resolved(winner_id: int, points: int)
signal score_updated(player_id: int, score: int)
