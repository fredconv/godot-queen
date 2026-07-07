class_name PassiveStrategy
extends AiStrategy
## IA passive : joue bas, évite de remporter les plis quand c'est possible.


func choose_card(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	if legal_plays.size() == 1:
		return legal_plays[0]

	if context.get("is_leading", false):
		var safe_leads := _reject_penalty(legal_plays)
		var pool := safe_leads if not safe_leads.is_empty() else legal_plays
		return _lowest_rank(pool, rng)

	var lead_suit: int = context.get("lead_suit", -1)
	if not _all_match_suit(legal_plays, lead_suit):
		return _lowest_rank(legal_plays, rng)

	return _duck_if_possible(legal_plays, context, rng)


func _duck_if_possible(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	var lead_suit: int = context.get("lead_suit", -1)
	var current_best := _current_best_rank(context.get("trick_cards", []), lead_suit)
	var losing := _select(legal_plays, func(card: CardModel) -> bool: return card.rank < current_best)
	if not losing.is_empty():
		return _lowest_rank(losing, rng)
	return _lowest_rank(legal_plays, rng)


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
	var best: Array[CardModel] = [cards[0]]
	for index in range(1, cards.size()):
		var card: CardModel = cards[index]
		if card.rank < best[0].rank:
			best = [card]
		elif card.rank == best[0].rank:
			best.append(card)
	return best[rng.randi_range(0, best.size() - 1)]
