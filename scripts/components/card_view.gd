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
const PLAYABLE_MODULATE: Color = Color(1.04, 1.03, 0.98, 1.0)
const SHAKE_OFFSET: float = 4.0
const SHAKE_SEC: float = 0.06
## Ombres ColorRect : alpha bas + éventail sans ombre au repos (sinon bandes / « step »
## sur la carte éclairée derrière — Nearest + empilement d’alpha).
const SHADOW_REST_ALPHA: float = 0.12
const SHADOW_LIFT_ALPHA: float = 0.20
const SHADOW_REST_OFFSET: Vector2 = Vector2(2, 2)
const SHADOW_LIFT_OFFSET: Vector2 = Vector2(2, 3)

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

## Ombre au repos (pli isolé). False dans l’éventail main / dos adverses.
@export var resting_drop_shadow: bool = false:
	set(value):
		if resting_drop_shadow == value:
			return
		resting_drop_shadow = value
		if is_node_ready():
			_update_drop_shadow()

@onready var _texture_rect: TextureRect = $Visual/Texture
@onready var _visual: Control = $Visual
@onready var _shadow: ColorRect = $Shadow
@onready var _playable_rim: Panel = $Visual/PlayableRim
@onready var _disabled_overlay: ColorRect = $Visual/DisabledOverlay
@onready var _selection_highlight: Control = $Visual/SelectionHighlight

var _lift_tween: Tween
var _shake_tween: Tween

func _ready() -> void:
	_ensure_playable_rim_style()
	_configure_shadow_rect()
	_refresh_texture()
	_update_visual_state(true)


func _configure_shadow_rect() -> void:
	if _shadow == null:
		return
	## Teinte sombre tiède (tapis) plutôt que noir pur — moins de « marches » grises.
	_shadow.color = Color(0.04, 0.06, 0.05, 1.0)
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	## Légèrement plus petite que la carte : moins de débordement en rotation.
	_shadow.size = Vector2(52, 76)


func _ensure_playable_rim_style() -> void:
	if _playable_rim == null:
		return
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = UiPalette.GOLD_BRIGHT
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	_playable_rim.add_theme_stylebox_override("panel", style)

## Alternative explicite aux setters `selected`/`hovered` (mêmes effets),
## demandée pour un usage direct depuis le code appelant (ex. `table.gd`).
func set_selected(value: bool) -> void:
	selected = value

func set_hovered(value: bool) -> void:
	hovered = value

func set_playable(value: bool) -> void:
	playable = value


func set_resting_drop_shadow(value: bool) -> void:
	resting_drop_shadow = value


## Réaction courte sur coup invalide (sans changer la logique de jeu).
func play_invalid_feedback() -> void:
	if _visual == null:
		return
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	var base_x: float = _visual.position.x
	_shake_tween = create_tween()
	_shake_tween.tween_property(_visual, "position:x", base_x + SHAKE_OFFSET, SHAKE_SEC)
	_shake_tween.tween_property(_visual, "position:x", base_x - SHAKE_OFFSET, SHAKE_SEC)
	_shake_tween.tween_property(_visual, "position:x", base_x, SHAKE_SEC)

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
	if _playable_rim != null:
		## Contour or seulement au survol / sélection — pas sur toutes les cartes jouables.
		_playable_rim.visible = playable and (hovered or selected)
	_update_drop_shadow()

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
	elif playable:
		target_modulate = PLAYABLE_MODULATE

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


func _update_drop_shadow() -> void:
	if _shadow == null:
		return
	var emphasize: bool = hovered or selected
	if emphasize:
		_shadow.visible = true
		_shadow.modulate.a = SHADOW_LIFT_ALPHA
		_shadow.position = SHADOW_LIFT_OFFSET
	elif resting_drop_shadow:
		_shadow.visible = true
		_shadow.modulate.a = SHADOW_REST_ALPHA
		_shadow.position = SHADOW_REST_OFFSET
	else:
		## Éventail : pas d’ombre au repos → plus de dégradé en marches sur la carte derrière.
		_shadow.visible = false
