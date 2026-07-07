class_name MoonFeasibility
extends RefCounted
## Évalue si le « shoot the moon » reste réalisable.
##
## Règles de blocage :
## - Si un autre joueur a déjà des points, seul le détenteur actuel peut encore
##   viser la Lune ; les trois autres ne peuvent pas la chasser.
## - Si au moins deux joueurs ont des points, la Lune est morte pour tout le monde.
## - Avoir pris un pli pénalisant n'implique pas une tentative de Lune : il faut
##   encore le contrôle de la main, la confiance et le potentiel mathématique.


const OPENING_CONTROL_THRESHOLD_LOW: float = 66.0
const OPENING_CONTROL_THRESHOLD_HIGH: float = 50.0
const EARLY_CONTROL_THRESHOLD_LOW: float = 60.0
const EARLY_CONTROL_THRESHOLD_HIGH: float = 44.0
const RECOVERY_CONTROL_THRESHOLD_LOW: float = 58.0
const RECOVERY_CONTROL_THRESHOLD_HIGH: float = 42.0
const RECOVERY_MIN_CONFIDENCE: float = 0.58
const MOON_HUNTER_RECOVERY_MIN_CONFIDENCE: float = 0.54
const MOON_HUNTER_CONTROL_RELAX: float = 5.5
const EARLY_HAND_MAX_TRICK: int = 5
const LATE_START_MAX_TRICK: int = 3

const MIN_HEARTS_FOR_MOON_ATTEMPT: int = 6
const MIN_HEARTS_WITH_QUEEN: int = 4
const MIN_BIG_HEARTS: int = 3


static func is_viable_for_player(
	player_index: int,
	hand_cards: Array[CardModel],
	tricks_taken: Array,
	confidence: float = AiConfidence.DEFAULT,
	trick_number: int = 1,
	for_moon_hunter: bool = false
) -> bool:
	if player_index < 0 or player_index >= HeartsRules.PLAYER_COUNT:
		return false
	if tricks_taken.size() != HeartsRules.PLAYER_COUNT:
		return false

	if is_moon_busted_globally(tricks_taken):
		return false

	if another_player_has_penalty_points(tricks_taken, player_index):
		return false
	if _opponent_captured_queen_of_spades(tricks_taken, player_index):
		return false

	var total_captured := _total_penalty_points_captured(tricks_taken)
	var our_captured := _penalty_points_in_tricks(tricks_taken[player_index])
	var remaining := HeartsRules.TOTAL_POINTS_PER_HAND - total_captured
	if remaining <= 0:
		return our_captured == HeartsRules.TOTAL_POINTS_PER_HAND

	if our_captured == 0:
		if trick_number > LATE_START_MAX_TRICK:
			return false
		if trick_number <= 1:
			return _opening_hand_viable(hand_cards, confidence, for_moon_hunter)
		if trick_number <= EARLY_HAND_MAX_TRICK:
			return _early_hand_still_viable(hand_cards, confidence, trick_number, for_moon_hunter)
		return false

	var penalties_in_hand := _penalty_points_in_cards(hand_cards)
	if our_captured + penalties_in_hand < remaining:
		return false

	if not _has_queen_coverage(hand_cards, tricks_taken[player_index], remaining):
		return false

	if not _recovery_path_viable(hand_cards, confidence, our_captured, trick_number, for_moon_hunter):
		return false

	return true


## Index du seul joueur ayant des points de pénalité, ou -1 si aucun ou plusieurs.
static func sole_penalty_collector_index(tricks_taken: Array) -> int:
	if _count_players_with_penalty_points(tricks_taken) != 1:
		return -1
	for player_index in range(HeartsRules.PLAYER_COUNT):
		if _penalty_points_in_tricks(tricks_taken[player_index]) > 0:
			return player_index
	return -1


## Vrai si un autre joueur a déjà capturé des points : la chasse est impossible
## pour `player_index` (seul le détenteur actuel peut encore viser la Lune).
static func another_player_has_penalty_points(tricks_taken: Array, player_index: int) -> bool:
	for other_index in range(HeartsRules.PLAYER_COUNT):
		if other_index == player_index:
			continue
		if _penalty_points_in_tricks(tricks_taken[other_index]) > 0:
			return true
	return false


## Lune impossible pour tout le monde : au moins deux joueurs ont déjà des points.
static func is_moon_busted_globally(tricks_taken: Array) -> bool:
	return _count_players_with_penalty_points(tricks_taken) >= 2


static func _count_players_with_penalty_points(tricks_taken: Array) -> int:
	var count := 0
	for player_tricks: Array in tricks_taken:
		if _penalty_points_in_tricks(player_tricks) > 0:
			count += 1
	return count


## Score heuristique de contrôle à la distribution (cartes hautes, longueur,
## gros cœurs, pénalité des petites cartes dispersées).
static func compute_control_score(hand_cards: Array[CardModel]) -> int:
	if hand_cards.is_empty():
		return 0

	var score := 0
	var suit_counts: Array[int] = [0, 0, 0, 0]
	var low_card_count := 0
	var big_heart_count := 0

	for card in hand_cards:
		suit_counts[card.suit] += 1
		if card.rank <= Rank.FIVE:
			low_card_count += 1
		if card.is_heart() and card.rank >= Rank.TEN:
			big_heart_count += 1
		if card.rank >= Rank.QUEEN:
			score += 3
		elif card.rank >= Rank.JACK:
			score += 2
		elif card.rank >= Rank.TEN:
			score += 1

	var longest_suit := _longest_suit_length(suit_counts)
	if longest_suit >= 6:
		score += 14
	elif longest_suit >= 5:
		score += 10
	elif longest_suit >= 4:
		score += 4

	score += big_heart_count * 4
	score -= maxi(0, low_card_count - 3) * 3

	if longest_suit <= 4 and low_card_count >= 5:
		score -= 12

	return score


static func _opening_hand_viable(
	hand_cards: Array[CardModel],
	confidence: float,
	for_moon_hunter: bool = false
) -> bool:
	var threshold := lerpf(OPENING_CONTROL_THRESHOLD_LOW, OPENING_CONTROL_THRESHOLD_HIGH, confidence)
	if for_moon_hunter:
		threshold -= MOON_HUNTER_CONTROL_RELAX
	if compute_control_score(hand_cards) < threshold:
		return false
	return _has_minimum_moon_material(hand_cards, confidence, for_moon_hunter)


static func _early_hand_still_viable(
	hand_cards: Array[CardModel],
	confidence: float,
	trick_number: int,
	for_moon_hunter: bool = false
) -> bool:
	var threshold := lerpf(EARLY_CONTROL_THRESHOLD_LOW, EARLY_CONTROL_THRESHOLD_HIGH, confidence)
	threshold += float(trick_number - 2) * 4.0
	if for_moon_hunter:
		threshold -= MOON_HUNTER_CONTROL_RELAX * 0.5
	if compute_control_score(hand_cards) < threshold:
		return false
	return _has_minimum_moon_material(hand_cards, confidence, for_moon_hunter)


static func _has_minimum_moon_material(
	hand_cards: Array[CardModel],
	confidence: float,
	for_moon_hunter: bool = false
) -> bool:
	var min_hearts := maxi(
		MIN_HEARTS_FOR_MOON_ATTEMPT - int(floor(confidence * 2.0)),
		3
	)
	if for_moon_hunter:
		min_hearts = maxi(min_hearts - 1, 3)
	var min_hearts_with_queen := maxi(
		MIN_HEARTS_WITH_QUEEN - int(floor(confidence * 1.0)),
		2
	)
	var min_big_hearts := maxi(
		MIN_BIG_HEARTS - int(floor(confidence * 1.0)),
		1
	)
	if for_moon_hunter:
		min_big_hearts = maxi(min_big_hearts - 1, 1)

	var heart_count := 0
	var big_heart_count := 0
	var has_queen := false
	for card in hand_cards:
		if card.is_heart():
			heart_count += 1
			if card.rank >= Rank.TEN:
				big_heart_count += 1
		elif card.is_queen_of_spades():
			has_queen = true

	if big_heart_count < min_big_hearts and not has_queen:
		return false
	if has_queen and heart_count >= min_hearts_with_queen:
		return true
	return heart_count >= min_hearts


static func _recovery_path_viable(
	hand_cards: Array[CardModel],
	confidence: float,
	our_captured: int,
	trick_number: int,
	for_moon_hunter: bool = false
) -> bool:
	if our_captured <= 0:
		return true
	var min_confidence := (
		MOON_HUNTER_RECOVERY_MIN_CONFIDENCE if for_moon_hunter else RECOVERY_MIN_CONFIDENCE
	)
	if confidence < min_confidence:
		return false

	var threshold := lerpf(
		RECOVERY_CONTROL_THRESHOLD_LOW,
		RECOVERY_CONTROL_THRESHOLD_HIGH,
		confidence
	)
	threshold += float(our_captured) * 1.5
	threshold += maxf(0.0, float(trick_number - 1)) * 2.0
	if for_moon_hunter:
		threshold -= MOON_HUNTER_CONTROL_RELAX * 0.35
	return compute_control_score(hand_cards) >= threshold


## Probabilité heuristique 0–1 avant une tentative (calibrage « regret stratégique »).
## Plafonnée bas : en pratique <5 % des tentatives réussissent en simulation.
static func estimate_success_probability(
	player_index: int,
	hand_cards: Array[CardModel],
	tricks_taken: Array,
	confidence: float = AiConfidence.DEFAULT,
	trick_number: int = 1
) -> float:
	if not is_viable_for_player(player_index, hand_cards, tricks_taken, confidence, trick_number):
		return 0.0

	var control_norm := clampf(compute_control_score(hand_cards) / 95.0, 0.0, 1.0)
	var probability := lerpf(0.01, 0.10, control_norm)
	probability = lerpf(probability, minf(probability + 0.04, 0.14), confidence)

	var our_captured := 0
	if player_index >= 0 and player_index < tricks_taken.size():
		our_captured = _penalty_points_in_tricks(tricks_taken[player_index])
	if our_captured > 0:
		probability *= lerpf(0.45, 0.75, confidence)

	probability -= maxf(0.0, float(trick_number - 1)) * 0.006
	return clampf(probability, 0.0, 0.14)


static func _opponent_captured_penalty(tricks_taken: Array, player_index: int) -> bool:
	return another_player_has_penalty_points(tricks_taken, player_index)


static func opponent_captured_queen_of_spades(tricks_taken: Array, player_index: int) -> bool:
	return _opponent_captured_queen_of_spades(tricks_taken, player_index)


static func _opponent_captured_queen_of_spades(tricks_taken: Array, player_index: int) -> bool:
	for other_index in range(HeartsRules.PLAYER_COUNT):
		if other_index == player_index:
			continue
		for card: CardModel in tricks_taken[other_index]:
			if card.is_queen_of_spades():
				return true
	return false


static func _longest_suit_length(suit_counts: Array[int]) -> int:
	var longest := 0
	for count in suit_counts:
		longest = maxi(longest, count)
	return longest


static func _total_penalty_points_captured(tricks_taken: Array) -> int:
	var total := 0
	for player_tricks: Array in tricks_taken:
		total += _penalty_points_in_tricks(player_tricks)
	return total


static func _penalty_points_in_tricks(cards: Array) -> int:
	var points := 0
	for card: CardModel in cards:
		points += HeartsRules.card_points(card)
	return points


static func _penalty_points_in_cards(cards: Array[CardModel]) -> int:
	var points := 0
	for card in cards:
		points += HeartsRules.card_points(card)
	return points


static func _has_queen_coverage(
	hand_cards: Array[CardModel],
	captured_cards: Array,
	remaining_points: int
) -> bool:
	var queen_still_needed := HeartsRules.QUEEN_OF_SPADES_POINTS
	for card: CardModel in captured_cards:
		if card.is_queen_of_spades():
			queen_still_needed = 0
			break
	if queen_still_needed == 0:
		return true
	if remaining_points < queen_still_needed:
		return true
	for card in hand_cards:
		if card.is_queen_of_spades():
			return true
	return false
