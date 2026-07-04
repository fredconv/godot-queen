class_name RuleEngine
extends RefCounted
## Moteur de règles du Dame de Pique (Hearts) : coups légaux, validation d'un
## coup, résolution d'un pli, calcul du score de manche. Pure logique
## (`RefCounted`, aucun nœud Godot), testable hors scène (voir
## tests/unit/test_rule_engine.gd). S'appuie sur les types de l'étape 2
## (`CardModel`, `PlayerHand`, `Suit`, `Rank`) et les constantes de
## `HeartsRules` (scripts/rules/hearts_rules.gd).
##
## Une instance porte l'état d'UNE manche en cours (`hearts_broken`,
## `trick_number`...) : l'orchestrateur (`MatchManager`, étape 4) est
## responsable d'appeler `record_card_played()` après chaque carte posée et
## `advance_to_next_trick()` après chaque pli résolu. Les méthodes de
## résolution de pli et de score (`get_trick_winner`, `score_trick`,
## `score_hand`, `can_lead_suit`) sont statiques et pures : elles ne dépendent
## d'aucun état d'instance, réutilisables telles quelles (ex. par l'IA).

## Résultat détaillé de la validation d'un coup, voir `validate_play()`.
enum ValidationResult {
	VALID,
	CARD_NOT_IN_HAND,
	MUST_PLAY_TWO_OF_CLUBS,
	MUST_FOLLOW_SUIT,
	CANNOT_LEAD_HEARTS_UNBROKEN,
	CANNOT_PLAY_PENALTY_ON_FIRST_TRICK,
}

## `true` dès qu'un Cœur ou la Dame de Pique a été joué dans la manche en
## cours (défonce des Cœurs) : autorise ensuite à entamer un pli avec un
## Cœur (voir docs/DECISIONS.md ADR-016 pour l'inclusion de la Dame de Pique).
var hearts_broken: bool = false

## Numéro du pli en cours dans la manche (1-based).
var trick_number: int = 1

## Équivalent à `trick_number == 1`, exposé comme état séparé pour une
## lecture directe côté appelants (`MatchManager`, tests) sans recalcul.
var is_first_trick: bool = true

## Réinitialise l'état pour le début d'une nouvelle manche.
func reset_for_new_hand() -> void:
	hearts_broken = false
	trick_number = 1
	is_first_trick = true

## À appeler après chaque pli résolu : avance l'état interne au pli suivant.
func advance_to_next_trick() -> void:
	trick_number += 1
	is_first_trick = false

## À appeler après chaque carte posée sur la table : défonce les Cœurs si la
## carte jouée est une carte à points (Cœur ou Dame de Pique).
func record_card_played(card: CardModel) -> void:
	if HeartsRules.is_penalty_card(card):
		hearts_broken = true

## Liste des cartes de `hand` qu'il est légal de jouer compte tenu de l'état
## courant (`hearts_broken`, `is_first_trick`) et du contexte du pli :
## - `lead_suit` : couleur demandée par le pli en cours (`Suit.*`), ignoré si
##   `is_leading` est `true`.
## - `is_leading` : `true` si `hand` entame le pli, `false` si elle répond à
##   une couleur déjà demandée.
## Ne retourne jamais un tableau vide tant que `hand` contient au moins une
## carte : les exceptions "aucun autre choix possible" retombent alors sur
## la main entière (ex. main composée uniquement de Cœurs).
func get_legal_plays(hand: PlayerHand, lead_suit: int, is_leading: bool) -> Array[CardModel]:
	var hand_cards := hand.cards()
	if hand_cards.is_empty():
		return []
	if is_leading:
		return _legal_leads(hand_cards)
	return _legal_follows(hand_cards, lead_suit)

## Vérifie si jouer `card` depuis `hand` est autorisé dans le contexte donné
## (mêmes paramètres que `get_legal_plays()`). Retourne
## `ValidationResult.VALID` si le coup est légal, sinon le code de la règle
## enfreinte.
func validate_play(card: CardModel, hand: PlayerHand, lead_suit: int, is_leading: bool) -> ValidationResult:
	if not hand.contains(card):
		return ValidationResult.CARD_NOT_IN_HAND

	var legal_plays := get_legal_plays(hand, lead_suit, is_leading)
	for legal_card in legal_plays:
		if legal_card.equals(card):
			return ValidationResult.VALID

	if is_leading:
		return _lead_failure_reason(card, hand.cards())
	return _follow_failure_reason(hand.cards(), lead_suit)

func _legal_leads(hand_cards: Array[CardModel]) -> Array[CardModel]:
	if is_first_trick:
		var two_of_clubs := _find_two_of_clubs(hand_cards)
		if two_of_clubs != null:
			return [two_of_clubs]

	var legal: Array[CardModel] = []
	for card in hand_cards:
		if is_first_trick and HeartsRules.is_penalty_card(card):
			continue
		if card.is_heart() and not hearts_broken:
			continue
		legal.append(card)

	if legal.is_empty():
		return hand_cards.duplicate()
	return legal

func _legal_follows(hand_cards: Array[CardModel], lead_suit: int) -> Array[CardModel]:
	var same_suit: Array[CardModel] = []
	for card in hand_cards:
		if card.suit == lead_suit:
			same_suit.append(card)
	if not same_suit.is_empty():
		return same_suit

	if is_first_trick:
		var non_penalty: Array[CardModel] = []
		for card in hand_cards:
			if not HeartsRules.is_penalty_card(card):
				non_penalty.append(card)
		if not non_penalty.is_empty():
			return non_penalty

	return hand_cards.duplicate()

func _lead_failure_reason(card: CardModel, hand_cards: Array[CardModel]) -> ValidationResult:
	if is_first_trick and _find_two_of_clubs(hand_cards) != null:
		return ValidationResult.MUST_PLAY_TWO_OF_CLUBS
	if is_first_trick and HeartsRules.is_penalty_card(card):
		return ValidationResult.CANNOT_PLAY_PENALTY_ON_FIRST_TRICK
	return ValidationResult.CANNOT_LEAD_HEARTS_UNBROKEN

func _follow_failure_reason(hand_cards: Array[CardModel], lead_suit: int) -> ValidationResult:
	for existing_card in hand_cards:
		if existing_card.suit == lead_suit:
			return ValidationResult.MUST_FOLLOW_SUIT
	return ValidationResult.CANNOT_PLAY_PENALTY_ON_FIRST_TRICK

static func _find_two_of_clubs(cards: Array[CardModel]) -> CardModel:
	for card in cards:
		if HeartsRules.is_two_of_clubs(card):
			return card
	return null

## Détermine si `suit` peut être entamée compte tenu de `hearts_broken` et du
## contenu de `hand`. Fonction pure indépendante de l'état d'instance (utile
## pour l'IA ou des tests isolés sans `RuleEngine` complet).
static func can_lead_suit(suit: int, hand: PlayerHand, hearts_broken: bool) -> bool:
	if suit != Suit.HEARTS:
		return true
	if hearts_broken:
		return true
	return HeartsRules.has_only_hearts(hand.cards())

## Détermine le vainqueur d'un pli. `trick` est un tableau ordonné (ordre de
## jeu) de dictionnaires `{"player_index": int, "card": CardModel}` ; le
## premier élément définit la couleur demandée. Sans atout, seule la couleur
## demandée peut remporter le pli (carte de plus haut rang).
static func get_trick_winner(trick: Array[Dictionary]) -> int:
	assert(not trick.is_empty(), "Un pli ne peut pas être vide")
	var lead_suit: int = (trick[0]["card"] as CardModel).suit
	var winning_entry: Dictionary = trick[0]
	for i in range(1, trick.size()):
		var entry: Dictionary = trick[i]
		var card: CardModel = entry["card"]
		var winning_card: CardModel = winning_entry["card"]
		if card.suit == lead_suit and card.compare_rank(winning_card) > 0:
			winning_entry = entry
	return winning_entry["player_index"]

## Somme des points (Cœurs + Dame de Pique) contenus dans les cartes d'un
## pli remporté.
static func score_trick(cards: Array[CardModel]) -> int:
	var points := 0
	for card in cards:
		points += HeartsRules.card_points(card)
	return points

## Calcule le score final d'une manche à partir des cartes remportées par
## chaque joueur. `tricks_taken_per_player` est indexé par `player_index` :
## chaque entrée est un `Array[CardModel]` regroupant toutes les cartes
## capturées par ce joueur pendant la manche (tous plis confondus). Gère la
## "réussite totale" (shoot the moon, voir docs/DECISIONS.md ADR-016) : si un
## seul joueur a capturé les 26 points de la manche, il marque 0 point et
## chacun des autres joueurs marque `HeartsRules.TOTAL_POINTS_PER_HAND`
## points. Retourne un dictionnaire `{player_index: int -> points: int}`.
static func score_hand(tricks_taken_per_player: Array) -> Dictionary:
	var raw_scores: Dictionary = {}
	for player_index in range(tricks_taken_per_player.size()):
		var captured_cards: Array = tricks_taken_per_player[player_index]
		var points := 0
		for card in captured_cards:
			points += HeartsRules.card_points(card)
		raw_scores[player_index] = points

	var moon_shooter := _find_moon_shooter(raw_scores)
	if moon_shooter == -1:
		return raw_scores

	var final_scores: Dictionary = {}
	for player_index in raw_scores.keys():
		final_scores[player_index] = 0 if player_index == moon_shooter else HeartsRules.TOTAL_POINTS_PER_HAND
	return final_scores

static func _find_moon_shooter(raw_scores: Dictionary) -> int:
	for player_index in raw_scores.keys():
		if raw_scores[player_index] == HeartsRules.TOTAL_POINTS_PER_HAND:
			return player_index
	return -1
