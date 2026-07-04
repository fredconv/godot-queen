class_name HeuristicStrategy
extends AiStrategy
## Stratégie IA "solide" pour Hearts, volontairement simple (pas de recherche
## en profondeur ni de suivi des probabilités de cartes adverses) mais qui
## joue déjà de façon raisonnable :
## - en tête de pli : évite d'entamer avec une carte à points (Cœur ou Dame
##   de Pique) tant qu'une alternative existe, et joue la plus basse d'entre
##   elles pour rester discrète ;
## - en réponse, si elle peut suivre la couleur demandée : "ducke" (joue la
##   plus haute carte qui ne remporte pas le pli) quand c'est possible, pour
##   se débarrasser de cartes hautes sans prendre de points ; si elle est de
##   toute façon forcée de remporter le pli, joue la plus basse carte gagnante
##   pour conserver ses cartes fortes ;
## - en réponse, si elle ne peut pas suivre la couleur demandée (donc ne peut
##   de toute façon pas remporter le pli, voir `RuleEngine.get_trick_winner`) :
##   défausse en priorité la Dame de Pique, puis le Cœur le plus haut, puis la
##   carte la plus haute (se débarrasse des cartes dangereuses).
## Voir docs/DECISIONS.md pour la justification de ce choix de conception.

func choose_card(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	if legal_plays.size() == 1:
		return legal_plays[0]

	var is_leading: bool = context.get("is_leading", false)
	if is_leading:
		return _choose_lead(legal_plays, rng)
	return _choose_follow(legal_plays, context, rng)

func _choose_lead(legal_plays: Array[CardModel], rng: RandomNumberGenerator) -> CardModel:
	var safe_leads := _reject(legal_plays, HeartsRules.is_penalty_card)
	var pool := safe_leads if not safe_leads.is_empty() else legal_plays
	return _extreme_rank(pool, rng, true)

func _choose_follow(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	var lead_suit: int = context.get("lead_suit", -1)
	if not _all_match_suit(legal_plays, lead_suit):
		return _choose_dump(legal_plays, rng)
	return _choose_duck_or_win(legal_plays, context, rng)

## Cas "peut suivre la couleur demandée" : ducke si possible, sinon minimise
## la carte utilisée pour remporter le pli.
func _choose_duck_or_win(legal_plays: Array[CardModel], context: Dictionary, rng: RandomNumberGenerator) -> CardModel:
	var lead_suit: int = context.get("lead_suit", -1)
	var trick_cards: Array = context.get("trick_cards", [])
	var current_best_rank := _current_best_rank(trick_cards, lead_suit)

	var safe := _select(legal_plays, func(card: CardModel) -> bool: return card.rank < current_best_rank)
	if not safe.is_empty():
		return _extreme_rank(safe, rng, false)
	return _extreme_rank(legal_plays, rng, true)

## Cas "ne peut pas suivre la couleur demandée" : la carte jouée ne peut de
## toute façon jamais remporter ce pli (seule la couleur demandée le peut),
## donc toute défausse est "sûre". Priorité à la Dame de Pique, puis au Cœur
## le plus haut, puis à la carte la plus haute toutes couleurs confondues.
func _choose_dump(legal_plays: Array[CardModel], rng: RandomNumberGenerator) -> CardModel:
	for card in legal_plays:
		if card.is_queen_of_spades():
			return card

	var hearts := _select(legal_plays, func(card: CardModel) -> bool: return card.is_heart())
	if not hearts.is_empty():
		return _extreme_rank(hearts, rng, false)

	return _extreme_rank(legal_plays, rng, false)

static func _all_match_suit(cards: Array[CardModel], suit: int) -> bool:
	for card in cards:
		if card.suit != suit:
			return false
	return true

## Rang le plus élevé déjà posé dans la couleur demandée (seule couleur
## pouvant remporter le pli), ou -1 si `trick_cards` est vide.
static func _current_best_rank(trick_cards: Array, lead_suit: int) -> int:
	var best := -1
	for entry in trick_cards:
		var card: CardModel = entry["card"]
		if card.suit == lead_suit and card.rank > best:
			best = card.rank
	return best

static func _reject(cards: Array[CardModel], predicate: Callable) -> Array[CardModel]:
	var result: Array[CardModel] = []
	for card in cards:
		if not predicate.call(card):
			result.append(card)
	return result

static func _select(cards: Array[CardModel], predicate: Callable) -> Array[CardModel]:
	var result: Array[CardModel] = []
	for card in cards:
		if predicate.call(card):
			result.append(card)
	return result

## Carte de rang minimal (`want_lowest`) ou maximal parmi `cards`. Les
## éventuelles égalités de rang (cartes de couleurs différentes) sont
## départagées par `rng`, pour garder un peu de variété tout en restant
## déterministe pour une seed donnée.
static func _extreme_rank(cards: Array[CardModel], rng: RandomNumberGenerator, want_lowest: bool) -> CardModel:
	var best: Array[CardModel] = [cards[0]]
	for i in range(1, cards.size()):
		var card: CardModel = cards[i]
		var is_strictly_better := card.rank < best[0].rank if want_lowest else card.rank > best[0].rank
		if is_strictly_better:
			best = [card]
		elif card.rank == best[0].rank:
			best.append(card)
	return best[rng.randi_range(0, best.size() - 1)]
