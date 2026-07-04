extends Control
## CardView
## Composant d'affichage d'une carte (recto ou dos). Purement visuel :
## ne contient aucune règle de jeu, uniquement la logique d'affichage
## de la texture appropriée (dos canonique "card_back_red" ou recto fourni)
## et des états visuels de survol/sélection (surélévation + surbrillance).

const BACK_TEXTURE: Texture2D = preload("res://assets/cards/kerenel_Cards_seperated/card_back_red.png")

## Décalage vertical (px) appliqué à la carte lorsqu'elle est survolée.
const HOVER_LIFT: float = -20.0
## Décalage vertical (px) appliqué à la carte lorsqu'elle est sélectionnée.
const SELECTED_LIFT: float = -28.0
## Décalage vertical (px) appliqué aux cartes non jouables : restent légèrement
## plus basses dans l'éventail pour renforcer le contraste avec les cartes légales.
const DISABLED_LIFT: float = 10.0
const LIFT_DURATION: float = 0.12
const HOVER_MODULATE: Color = Color(1.08, 1.08, 1.08, 1.0)
const SELECTED_MODULATE: Color = Color(1.15, 1.15, 1.15, 1.0)
const DEFAULT_MODULATE: Color = Color(1.0, 1.0, 1.0, 1.0)

@export var face_up: bool = false:
	set(value):
		face_up = value
		_refresh_texture()

@export var front_texture: Texture2D:
	set(value):
		front_texture = value
		_refresh_texture()

## Vrai si la carte est actuellement sélectionnée par le joueur (surbrillance
## à crochets de coin + surélévation marquée).
@export var selected: bool = false:
	set(value):
		if selected == value:
			return
		selected = value
		_update_visual_state()

## Vrai si le pointeur survole actuellement la carte (légère surélévation).
@export var hovered: bool = false:
	set(value):
		if hovered == value:
			return
		hovered = value
		if hovered and playable:
			AudioService.play_card_hover()
		_update_visual_state()

## Vrai si la carte peut être jouée dans le contexte courant (main humaine).
## Les cartes non jouables conservent leur opacité pleine mais affichent un
## voile gris semi-transparent et restent légèrement plus basses dans l'éventail.
@export var playable: bool = true:
	set(value):
		if playable == value:
			return
		playable = value
		if not playable:
			hovered = false
		_update_visual_state()

@onready var _texture_rect: TextureRect = $Visual/Texture
@onready var _visual: Control = $Visual
@onready var _disabled_overlay: ColorRect = $Visual/DisabledOverlay
@onready var _selection_highlight: Control = $Visual/SelectionHighlight

var _lift_tween: Tween

func _ready() -> void:
	_refresh_texture()
	_update_visual_state(true)

## Alternative explicite aux setters `selected`/`hovered` (mêmes effets),
## demandée pour un usage direct depuis le code appelant (ex. `table.gd`).
func set_selected(value: bool) -> void:
	selected = value

func set_hovered(value: bool) -> void:
	hovered = value

func set_playable(value: bool) -> void:
	playable = value

func _refresh_texture() -> void:
	if not _texture_rect:
		return
	_texture_rect.texture = front_texture if (face_up and front_texture) else BACK_TEXTURE

## Anime la surélévation (position Y du conteneur visuel) et la teinte selon
## l'état combiné sélection/survol (la sélection prime sur le simple survol).
## `instant` évite l'animation lors de l'initialisation (`_ready`).
func _update_visual_state(instant: bool = false) -> void:
	if not _visual or not _selection_highlight or not _disabled_overlay:
		return
	_selection_highlight.visible = selected
	_disabled_overlay.visible = not playable

	var target_y: float = 0.0
	var target_modulate: Color = DEFAULT_MODULATE
	if not playable:
		target_y = DISABLED_LIFT
	elif selected:
		target_y = SELECTED_LIFT
		target_modulate = SELECTED_MODULATE
	elif hovered:
		target_y = HOVER_LIFT
		target_modulate = HOVER_MODULATE

	if instant:
		_visual.position.y = target_y
		_visual.modulate = target_modulate
		return

	if _lift_tween and _lift_tween.is_valid():
		_lift_tween.kill()
	_lift_tween = create_tween()
	_lift_tween.set_parallel(true)
	_lift_tween.tween_property(_visual, "position:y", target_y, LIFT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_lift_tween.tween_property(_visual, "modulate", target_modulate, LIFT_DURATION)
