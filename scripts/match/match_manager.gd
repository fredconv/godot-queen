class_name MatchManager
extends RefCounted
## Orchestrateur d'une manche/partie de Dame de Pique (Hearts), étape 4.
## `RefCounted`, **volontairement pas un autoload** (voir docs/DECISIONS.md
## ADR-002) : cycle de vie borné, instancié par la scène de table
## (`scenes/table/`) quand celle-ci existera. Coordonne `Deck`,
## `PlayerHand` (étape 2), `RuleEngine` (état de manche, étape 3),
## `TrickManager` et `ScoreManager` (étape 4). Aucune passe de cartes (3
## cartes) à cette étape : hors scope du MVP, voir docs/DECISIONS.md.
##
## Émet les signaux de `GameEvents` (`match_started`, `card_played`,
## `trick_resolved`, `score_updated`, `match_ended`) déjà consommés par
## `AudioService`/`GameSession` : aucun câblage supplémentaire n'est requis
## côté UI pour ces événements de base.

## Phase du cycle de vie d'une manche en cours.
enum Phase {
	DEALING,
	PLAYING,
	HAND_END,
	MATCH_END,
}

## Raison de l'échec d'un appel à `play_card()` (voir `PlayResult`).
enum PlayError {
	NONE,
	WRONG_PHASE,
	NOT_YOUR_TURN,
	RULE_VIOLATION,
}

## Résultat détaillé d'un appel à `play_card()`, à destination de l'appelant
## (IA, futur câblage UI) : succès/échec, résolution de pli, fin de manche ou
## de partie déclenchée par ce coup.
class PlayResult:
	var success: bool = false
	var play_error: int = PlayError.NONE
	## Signification valide seulement si `play_error == PlayError.RULE_VIOLATION`.
	var rule_violation: int = RuleEngine.ValidationResult.VALID
	var trick_completed: bool = false
	var trick_winner: int = -1
	var hand_completed: bool = false
	var match_completed: bool = false

## Score cumulé (une partie) à partir duquel la partie s'arrête, voir
## docs/GDD.md ("classiquement 100 points").
const MATCH_SCORE_THRESHOLD: int = 100

var hands: Array[PlayerHand] = []
var deck: Deck
var rule_engine: RuleEngine
var trick_manager: TrickManager
var score_manager: ScoreManager

## `AiPlayer` assigné à chaque siège, ou `null` si le siège est contrôlé par
## un humain (voir `set_ai_player()`). Par convention le siège 0 est le
## joueur humain (voir docs/DECISIONS.md ADR-019) mais `MatchManager` ne
## l'impose pas : c'est à l'appelant (scène de table, tests) d'assigner les
## `AiPlayer` voulus siège par siège.
var ai_players: Array = [null, null, null, null]

var phase: int = Phase.DEALING
var current_player: int = -1
var trick_leader: int = -1
var hand_number: int = 0

## Cartes remportées par chaque joueur pendant la manche en cours (tous plis
## confondus), indexé par `player_index`. Remis à zéro à chaque nouvelle
## manche, consommé par `RuleEngine.score_hand()` en fin de manche.
var _tricks_taken: Array = []

func _init() -> void:
	rule_engine = RuleEngine.new()
	trick_manager = TrickManager.new()
	score_manager = ScoreManager.new()

## Démarre une nouvelle partie : remet les scores cumulés à zéro, émet
## `GameEvents.match_started`, puis distribue la première manche.
## `seed_value` optionnel pour un mélange déterministe (tests, replays).
func start_new_match(seed_value: int = -1) -> void:
	score_manager.reset()
	hand_number = 0
	GameEvents.match_started.emit()
	start_new_hand(seed_value)

## Distribue une nouvelle manche : mélange le paquet, distribue 13 cartes par
## joueur, réinitialise l'état de pli/règles, et positionne en tête le
## joueur possédant le 2 de Trèfle (obligatoire au premier pli, voir
## `RuleEngine`). `seed_value` optionnel pour un mélange déterministe.
func start_new_hand(seed_value: int = -1) -> void:
	phase = Phase.DEALING
	hand_number += 1
	rule_engine.reset_for_new_hand()
	trick_manager.reset()
	_tricks_taken = []
	for _i in range(HeartsRules.PLAYER_COUNT):
		_tricks_taken.append([] as Array[CardModel])

	deck = Deck.create_standard_52()
	deck.shuffle(seed_value)
	hands = []
	for _i in range(HeartsRules.PLAYER_COUNT):
		var hand := PlayerHand.new()
		for card in deck.deal(HeartsRules.CARDS_PER_HAND):
			hand.add_card(card)
		hands.append(hand)

	trick_leader = _find_two_of_clubs_holder()
	current_player = trick_leader
	phase = Phase.PLAYING

## Liste des cartes légales que `player_index` peut jouer dans le contexte du
## pli en cours (voir `RuleEngine.get_legal_plays`).
func get_legal_plays(player_index: int) -> Array[CardModel]:
	var is_leading := trick_manager.played_count() == 0
	return rule_engine.get_legal_plays(hands[player_index], trick_manager.lead_suit, is_leading)

## Assigne `ai_player` au siège `player_index` (`null` pour repasser ce siège
## en contrôle humain). Voir docs/DECISIONS.md ADR-019 pour la convention de
## sièges par défaut (0 = humain, 1-3 = IA).
func set_ai_player(player_index: int, ai_player: AiPlayer) -> void:
	ai_players[player_index] = ai_player

## `true` si `player_index` est actuellement piloté par une IA assignée via
## `set_ai_player()`.
func is_ai_controlled(player_index: int) -> bool:
	return ai_players[player_index] != null

## Construit le contexte transmis à `AiPlayer.choose_card()` pour
## `player_index`, à partir de l'état courant de la manche.
func build_ai_context(player_index: int) -> Dictionary:
	return {
		"trick_number": rule_engine.trick_number,
		"hearts_broken": rule_engine.hearts_broken,
		"is_leading": trick_manager.played_count() == 0,
		"lead_suit": trick_manager.lead_suit,
		"trick_cards": trick_manager.get_plays(),
		"hand_size": hands[player_index].count(),
	}

## Joue le tour du joueur courant via l'`AiPlayer` qui lui est assigné.
## Ne fait rien et retourne `null` si la manche n'est pas en cours
## (`Phase.PLAYING`) ou si le joueur courant n'est pas piloté par une IA
## (tour humain à attendre).
func play_ai_turn() -> PlayResult:
	if phase != Phase.PLAYING:
		return null
	var player_index := current_player
	if not is_ai_controlled(player_index):
		return null

	var legal := get_legal_plays(player_index)
	var context := build_ai_context(player_index)
	var card: CardModel = ai_players[player_index].choose_card(legal, context)
	return play_card(player_index, card)

## Enchaîne `play_ai_turn()` tant que le joueur courant est piloté par une IA
## et que la manche est en cours : s'arrête dès qu'un tour humain doit être
## joué, ou en fin de manche/partie. Pratique pour les tests d'intégration
## (simulation complète à 4 IA) et pour une future UI (avance automatiquement
## les tours adverses entre deux tours du joueur humain).
func advance_ai_turns() -> void:
	while phase == Phase.PLAYING and is_ai_controlled(current_player):
		play_ai_turn()

## Joue `card` pour `player_index` : valide le coup (tour, phase, règles),
## met à jour la main/le pli/le tour, résout le pli si complet et calcule le
## score de la manche si les 13 plis sont joués. Retourne un `PlayResult`
## décrivant ce qui s'est passé ; l'état interne n'est modifié qu'en cas de
## succès (coup invalide = aucun effet de bord).
func play_card(player_index: int, card: CardModel) -> PlayResult:
	var result := PlayResult.new()

	if phase != Phase.PLAYING:
		result.play_error = PlayError.WRONG_PHASE
		return result

	if player_index != current_player:
		result.play_error = PlayError.NOT_YOUR_TURN
		return result

	var is_leading := trick_manager.played_count() == 0
	var validation := rule_engine.validate_play(card, hands[player_index], trick_manager.lead_suit, is_leading)
	if validation != RuleEngine.ValidationResult.VALID:
		result.play_error = PlayError.RULE_VIOLATION
		result.rule_violation = validation
		return result

	hands[player_index].remove_card(card)
	trick_manager.add_play(player_index, card)
	rule_engine.record_card_played(card)
	GameEvents.card_played.emit(player_index, card)
	result.success = true

	if trick_manager.is_complete():
		_resolve_trick(result)
	else:
		current_player = (player_index + 1) % HeartsRules.PLAYER_COUNT

	return result

## `true` si la partie (pas seulement la manche) est terminée (un joueur a
## atteint `MATCH_SCORE_THRESHOLD`).
func is_match_over() -> bool:
	return phase == Phase.MATCH_END

## Points bruts capturés par chaque joueur dans la manche en cours (somme des
## cartes à points dans `_tricks_taken`, sans ajustement « shoot the moon »).
## Utilisé par l'UI pour afficher la progression avant la fin de manche.
func get_current_hand_raw_scores() -> Array[int]:
	var scores: Array[int] = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		var points := 0
		for card in _tricks_taken[player_index]:
			points += HeartsRules.card_points(card)
		scores.append(points)
	return scores

## Nombre de Cœurs capturés par chaque joueur dans la manche en cours.
func get_current_hand_hearts_captured() -> Array[int]:
	var counts: Array[int] = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		var heart_count := 0
		for card in _tricks_taken[player_index]:
			if card.is_heart():
				heart_count += 1
		counts.append(heart_count)
	return counts

## Scores à afficher à côté des avatars : cumul de partie + progression de la
## manche en cours tant que `phase == PLAYING` ; sinon le cumul seul (fin de
## manche ou de partie, les points de la manche sont déjà intégrés au cumul).
func get_display_scores() -> Array[int]:
	var cumulative := score_manager.get_scores()
	if phase != Phase.PLAYING:
		return cumulative

	var hand_scores := get_current_hand_raw_scores()
	var display: Array[int] = []
	for player_index in range(HeartsRules.PLAYER_COUNT):
		display.append(cumulative[player_index] + hand_scores[player_index])
	return display

## Index du joueur ayant le score cumulé le plus bas. Pertinent seulement une
## fois `is_match_over()` vrai.
func get_match_winner() -> int:
	var scores := score_manager.get_scores()
	var winner := 0
	for player_index in range(1, scores.size()):
		if scores[player_index] < scores[winner]:
			winner = player_index
	return winner

func _resolve_trick(result: PlayResult) -> void:
	var winner := trick_manager.get_winner()
	var trick_cards := trick_manager.get_cards()
	var points := RuleEngine.score_trick(trick_cards)
	_tricks_taken[winner].append_array(trick_cards)

	result.trick_completed = true
	result.trick_winner = winner
	GameEvents.trick_resolved.emit(winner, points)

	trick_manager.reset()
	trick_leader = winner
	current_player = winner

	if rule_engine.trick_number >= HeartsRules.CARDS_PER_HAND:
		_end_hand(result)
	else:
		rule_engine.advance_to_next_trick()

func _end_hand(result: PlayResult) -> void:
	phase = Phase.HAND_END
	result.hand_completed = true

	var hand_scores := RuleEngine.score_hand(_tricks_taken)
	score_manager.add_hand_scores(hand_scores)
	for player_index in hand_scores.keys():
		GameEvents.score_updated.emit(player_index, score_manager.get_score(player_index))

	if _has_reached_match_threshold():
		phase = Phase.MATCH_END
		result.match_completed = true
		GameEvents.match_ended.emit(get_match_winner())

func _has_reached_match_threshold() -> bool:
	for score in score_manager.get_scores():
		if score >= MATCH_SCORE_THRESHOLD:
			return true
	return false

func _find_two_of_clubs_holder() -> int:
	var two_of_clubs := CardModel.new(Suit.CLUBS, Rank.TWO)
	for player_index in range(hands.size()):
		if hands[player_index].contains(two_of_clubs):
			return player_index
	return 0
