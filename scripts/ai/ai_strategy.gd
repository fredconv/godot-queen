class_name AiStrategy
extends RefCounted
## Interface commune des stratégies de choix de carte IA (voir
## `RandomLegalStrategy`, `HeuristicStrategy`). Chaque sous-classe reçoit une
## liste de coups légaux déjà calculée (par `RuleEngine`/`MatchManager`,
## jamais recalculée ici), un contexte de jeu (`MatchManager.build_ai_context()`)
## et un générateur aléatoire seedé fourni par `AiPlayer` (jamais créé en
## interne), pour rester entièrement déterministe et testable.

## À surcharger par chaque stratégie concrète. Doit toujours retourner une
## carte appartenant à `legal_plays` (jamais `null`, jamais une carte hors
## liste) : c'est ce qui garantit que l'IA ne joue jamais un coup illégal.
func choose_card(_legal_plays: Array[CardModel], _context: Dictionary, _rng: RandomNumberGenerator) -> CardModel:
	assert(false, "AiStrategy.choose_card() doit être surchargée par une sous-classe")
	return null
