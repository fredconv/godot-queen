class_name AiPlayer
extends RefCounted
## Joueur IA (étape 5) : associe une stratégie de choix de carte (`AiStrategy`)
## à un générateur aléatoire seedé, pour un comportement déterministe et
## testable. Ne connaît rien de `MatchManager` ni de `RuleEngine` : reçoit les
## coups légaux et le contexte de jeu déjà construits par l'appelant (voir
## `MatchManager.build_ai_context()`), et se contente de choisir une carte
## parmi `legal_plays`. Voir docs/DECISIONS.md (ADR-019) pour l'intégration
## avec `MatchManager` et docs/TECHNICAL_DESIGN.md pour le détail de l'API.

var strategy: AiStrategy
var _rng: RandomNumberGenerator

## `strategy_instance` par défaut : `HeuristicStrategy` (voir ce fichier pour
## le détail des heuristiques). `seed_value >= 0` donne un comportement
## reproductible (tests, replays) ; sinon le générateur est initialisé
## aléatoirement (`randomize()`).
func _init(strategy_instance: AiStrategy = null, seed_value: int = -1) -> void:
	strategy = strategy_instance if strategy_instance != null else HeuristicStrategy.new()
	_rng = RandomNumberGenerator.new()
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()

## Choisit une carte parmi `legal_plays` (jamais vide). `context` est un
## dictionnaire optionnel décrivant l'état du pli en cours : `trick_number`,
## `hearts_broken`, `is_leading`, `lead_suit`, `trick_cards`, `hand_size` (voir
## `MatchManager.build_ai_context()`). Ne recalcule jamais la légalité d'un
## coup elle-même : ne peut donc jamais retourner une carte hors de
## `legal_plays`, quelle que soit la stratégie utilisée.
func choose_card(legal_plays: Array[CardModel], context: Dictionary = {}) -> CardModel:
	assert(not legal_plays.is_empty(), "AiPlayer ne peut pas choisir dans une liste vide")
	if legal_plays.size() == 1:
		return legal_plays[0]
	return strategy.choose_card(legal_plays, context, _rng)
