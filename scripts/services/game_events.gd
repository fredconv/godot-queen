extends Node
## GameEvents (autoload)
## Bus de signaux transversal : découple UI, logique de jeu et services entre eux.
## Ne contient aucune logique métier, uniquement des déclarations de signaux.
## Les signaux sont émis par `MatchManager` et consommés par l'UI / les services.

@warning_ignore("unused_signal")
signal match_started
@warning_ignore("unused_signal")
signal match_ended(winner_id: int)
@warning_ignore("unused_signal")
signal card_played(player_id: int, card: CardModel)
@warning_ignore("unused_signal")
signal trick_resolved(winner_id: int, points: int)
@warning_ignore("unused_signal")
signal score_updated(player_id: int, score: int)
@warning_ignore("unused_signal")
signal reaction_sent(seat_index: int, reaction_id: int)
