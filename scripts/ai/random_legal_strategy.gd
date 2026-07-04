class_name RandomLegalStrategy
extends AiStrategy
## Stratégie IA minimale : choix uniformément aléatoire parmi les coups
## légaux, sans aucune heuristique de jeu. Sert de référence/baseline (voir
## tests/unit/test_ai_player.gd) et de stratégie de repli simple. C'est la
## stratégie qui équipait le stub `AiPlayer` de l'étape 4.

func choose_card(legal_plays: Array[CardModel], _context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	return legal_plays[rng.randi_range(0, legal_plays.size() - 1)]
