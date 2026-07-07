class_name CardTexturePaths
extends RefCounted
## Associe un `CardModel` au chemin de sa texture recto dans le pack de
## cartes `assets/cards/kerenel_Cards_seperated`. Centralise cette
## correspondance pour éviter toute divergence entre les différents endroits
## qui affichent une carte face visible (main du joueur humain, cartes
## adverses animées vers le pli, voir `scripts/ui/table.gd`).

const BASE_PATH: String = "res://assets/cards/kerenel_Cards_seperated/"

const SUIT_FILE_NAMES: Dictionary = {
	Suit.CLUBS: "clubs",
	Suit.DIAMONDS: "diamonds",
	Suit.SPADES: "spades",
	Suit.HEARTS: "hearts",
}

const RANK_FILE_NAMES: Dictionary = {
	Rank.TWO: "2",
	Rank.THREE: "3",
	Rank.FOUR: "4",
	Rank.FIVE: "5",
	Rank.SIX: "6",
	Rank.SEVEN: "7",
	Rank.EIGHT: "8",
	Rank.NINE: "9",
	Rank.TEN: "10",
	Rank.JACK: "jack",
	Rank.QUEEN: "queen",
	Rank.KING: "king",
	Rank.ACE: "ace",
}

static var _texture_cache: Dictionary = {}

static func get_front_texture_path(card: CardModel) -> String:
	return "%s%s_%s.png" % [BASE_PATH, SUIT_FILE_NAMES[card.suit], RANK_FILE_NAMES[card.rank]]

static func get_front_texture(card: CardModel) -> Texture2D:
	var path: String = get_front_texture_path(card)
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var texture: Texture2D = load(path) as Texture2D
	_texture_cache[path] = texture
	return texture
