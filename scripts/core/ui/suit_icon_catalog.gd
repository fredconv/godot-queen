class_name SuitIconCatalog
extends RefCounted
## Sprites de couleurs Royal Salon, réutilisables dans tous les panneaux HUD.


const CLUB: Texture2D = preload("res://assets/sprites/ui/royal_salon/suits/club_v1.png")
const DIAMOND: Texture2D = preload("res://assets/sprites/ui/royal_salon/suits/diamond_v1.png")
const SPADE: Texture2D = preload("res://assets/sprites/ui/royal_salon/suits/spade_v1.png")
const HEART: Texture2D = preload("res://assets/sprites/ui/royal_salon/suits/heart_v1.png")


static func texture(suit: int) -> Texture2D:
	match suit:
		Suit.CLUBS: return CLUB
		Suit.DIAMONDS: return DIAMOND
		Suit.SPADES: return SPADE
		Suit.HEARTS: return HEART
		_: return null


static func make_rect(suit: int, display_size: Vector2 = Vector2(24, 24)) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = display_size
	icon.texture = texture(suit)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon
