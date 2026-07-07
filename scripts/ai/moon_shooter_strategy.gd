class_name MoonShooterStrategy
extends AiStrategy
## IA « chasseur de lune » : tente de capturer les cartes à points (♥, Q♠).


func choose_card(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	if legal_plays.size() == 1:
		return legal_plays[0]

	if context.get("is_leading", false):
		return _choose_lead(legal_plays, context, rng)

	var lead_suit: int = context.get("lead_suit", -1)
	if not _all_match_suit(legal_plays, lead_suit):
		return _choose_void_dump(legal_plays, rng)
	return _choose_follow(legal_plays, context, rng)


func _choose_lead(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	if context.get("hearts_broken", false):
		var hearts := _select(legal_plays, func(card: CardModel) -> bool: return card.is_heart())
		if not hearts.is_empty():
			return _highest_rank(hearts, rng)

	var safe_leads := _reject_penalty(legal_plays)
	var pool := safe_leads if not safe_leads.is_empty() else legal_plays
	return _lowest_rank(pool, rng)


func _choose_follow(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	var lead_suit: int = context.get("lead_suit", -1)
	var current_best := _current_best_rank(context.get("trick_cards", []), lead_suit)
	var winning := _select(legal_plays, func(card: CardModel) -> bool: return card.rank > current_best)

	if winning.is_empty():
		return _lowest_rank(legal_plays, rng)

	var penalty_winners := _select(winning, func(card: CardModel) -> bool: return HeartsRules.is_penalty_card(card))
	if not penalty_winners.is_empty():
		return _lowest_rank(penalty_winners, rng)

	if _trick_has_penalty(context):
		return _lowest_rank(winning, rng)

	return _lowest_rank(legal_plays, rng)


func _choose_void_dump(legal_plays: Array[CardModel], rng: RandomNumberGenerator) -> CardModel:
	var safe_dumps := _reject_penalty(legal_plays)
	if not safe_dumps.is_empty():
		return _highest_rank(safe_dumps, rng)
	return _lowest_rank(legal_plays, rng)


static func _trick_has_penalty(context: Dictionary) -> bool:
	for entry in context.get("trick_cards", []):
		var card: CardModel = entry["card"]
		if HeartsRules.is_penalty_card(card):
			return true
	return false


static func _reject_penalty(cards: Array[CardModel]) -> Array[CardModel]:
	var result: Array[CardModel] = []
	for card in cards:
		if not HeartsRules.is_penalty_card(card):
			result.append(card)
	return result


static func _select(cards: Array[CardModel], predicate: Callable) -> Array[CardModel]:
	var result: Array[CardModel] = []
	for card in cards:
		if predicate.call(card):
			result.append(card)
	return result


static func _all_match_suit(cards: Array[CardModel], suit: int) -> bool:
	for card in cards:
		if card.suit != suit:
			return false
	return true


static func _current_best_rank(trick_cards: Array, lead_suit: int) -> int:
	var best := -1
	for entry in trick_cards:
		var card: CardModel = entry["card"]
		if card.suit == lead_suit and card.rank > best:
			best = card.rank
	return best


static func _lowest_rank(cards: Array[CardModel], rng: RandomNumberGenerator) -> CardModel:
	return _extreme_rank(cards, rng, true)


static func _highest_rank(cards: Array[CardModel], rng: RandomNumberGenerator) -> CardModel:
	return _extreme_rank(cards, rng, false)


static func _extreme_rank(cards: Array[CardModel], rng: RandomNumberGenerator, want_lowest: bool) -> CardModel:
	var best: Array[CardModel] = [cards[0]]
	for index in range(1, cards.size()):
		var card: CardModel = cards[index]
		var is_strictly_better := card.rank < best[0].rank if want_lowest else card.rank > best[0].rank
		if is_strictly_better:
			best = [card]
		elif card.rank == best[0].rank:
			best.append(card)
	return best[rng.randi_range(0, best.size() - 1)]
