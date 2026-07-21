class_name TableContextHelpState
extends RefCounted
## Projection en lecture seule des règles réelles vers l'aide contextuelle.


static func build(ctx: TableContext) -> Dictionary:
	var result := {
		"title": "AIDE CONTEXTUELLE",
		"instruction": "La partie se prépare.",
		"lead_suit": -1,
		"legal_cards": [] as Array[CardModel],
		"illegal_card": null,
		"rules": [] as Array[String],
	}
	if ctx == null or ctx.match_manager == null:
		return result
	var local_seat: int = ctx.get_local_human_seat()
	var hand: Array[CardModel] = ctx.match_manager.hands[local_seat].cards()
	var lead: int = ctx.match_manager.trick_manager.lead_suit
	result["lead_suit"] = lead
	var legal: Array[CardModel] = []
	if ctx.is_local_human_turn():
		legal = ctx.match_manager.get_legal_plays(local_seat)
	result["legal_cards"] = legal.slice(0, mini(3, legal.size()))
	for card: CardModel in hand:
		if not _contains_card(legal, card):
			result["illegal_card"] = card
			break
	var rules: Array[String] = result["rules"]
	if not ctx.is_local_human_turn():
		result["title"] = "PATIENTEZ"
		result["instruction"] = "Un autre joueur réfléchit. Observez le pli en cours."
	elif ctx.match_manager.rule_engine.trick_number == 1 and lead < 0:
		result["title"] = "À VOUS DE JOUER"
		result["instruction"] = "Commencez avec le 2 de Trèfle."
		rules.append("Premier pli : 2 de Trèfle obligatoire")
	elif lead >= 0:
		var owns_lead: bool = hand.any(func(card: CardModel) -> bool: return card.suit == lead)
		result["title"] = "À VOUS DE JOUER"
		if owns_lead:
			result["instruction"] = "Vous devez suivre %s. Sélectionnez une carte de cette couleur." % Suit.to_display_name(lead).to_upper()
		else:
			result["instruction"] = "Vous ne possédez aucun %s. Vous pouvez jouer une autre couleur." % Suit.to_display_name(lead)
		rules.append("Couleur demandée : %s" % Suit.to_display_name(lead).to_upper())
	else:
		result["title"] = "À VOUS DE JOUER"
		result["instruction"] = "Vous ouvrez le pli. Choisissez une couleur autorisée."
	if ctx.match_manager.rule_engine.hearts_broken:
		rules.append("Cœurs brisés")
	else:
		rules.append("Cœurs non brisés")
	rules.append("Dame de Pique %s" % ("déjà sortie" if _queen_was_played(ctx) else "encore en jeu"))
	return result


static func _contains_card(cards: Array[CardModel], target: CardModel) -> bool:
	for card: CardModel in cards:
		if card.equals(target):
			return true
	return false


static func _queen_was_played(ctx: TableContext) -> bool:
	for trick: Dictionary in ctx.match_manager.get_recent_tricks(13):
		for play: Dictionary in trick.get("plays", []):
			var card: CardModel = play.get("card") as CardModel
			if card != null and card.suit == Suit.SPADES and card.rank == Rank.QUEEN:
				return true
	for play: Dictionary in ctx.match_manager.trick_manager.get_plays():
		var card: CardModel = play.get("card") as CardModel
		if card != null and card.suit == Suit.SPADES and card.rank == Rank.QUEEN:
			return true
	return false
