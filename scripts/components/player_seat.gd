class_name PlayerSeat
extends Control
## PlayerSeat
## Composant d'affichage d'un siège joueur : avatar (placeholder), nom,
## score, pénalité cœur, et pile de dos de carte représentant la main
## restante. Purement visuel, aucune règle de jeu.
##
## `orientation` détermine la disposition : pile de cartes horizontale
## proche du bord (TOP/BOTTOM) ou pile verticale proche du bord (LEFT/RIGHT),
## avec le bloc avatar/nom/score placé du côté centre de la table (BOTTOM,
## LEFT, RIGHT). Exception : TOP dispose la pile et le bloc avatar/nom/score
## côte à côte (pile à gauche, avatar à droite) afin de dégager tout le
## centre du haut de table pour `TrickCardTop` (voir `_layout_seat`).

const CardViewScene: PackedScene = preload("res://scenes/components/card_view.tscn")

## Taille de base d'une carte (voir `card_view.tscn`), avant application de
## `CARD_BACK_SCALE`/`CARD_BACK_SCALE_SIDE` et rotation éventuelle.
const CARD_BASE_SIZE: Vector2 = Vector2(56.0, 80.0)
const CARD_BACK_SCALE: float = 2.0
## Échelle des dos de carte pour les piles latérales (LEFT/RIGHT). Ces cartes
## sont tournées de 90° (voir `_hand_back_rotation_degrees`) : l'empreinte
## verticale de la pile s'en trouve réduite, ce qui permet une échelle plus
## grande que `CARD_BACK_SCALE` sans déborder du siège.
const CARD_BACK_SCALE_SIDE: float = 2.2
## Largeur (en pixels) de carte encore visible entre deux cartes empilées :
## détermine le chevauchement (pile condensée façon éventail fermé). Fixe
## (indépendante de l'échelle) et calibrée pour qu'une main complète de 13
## cartes (`hand_card_count` par défaut) reste dans l'empreinte des sièges de
## `table.tscn` sans déborder.
const HAND_BACK_VISIBLE_STRIP: float = 16.0
## Marge entre le bord de la pile de dos de carte et le bord du siège.
const HAND_STACK_PADDING: float = 4.0
## Espace entre la pile de dos de carte et le bloc avatar/nom/score.
const HAND_INFO_GAP: float = 4.0
## Distance (px) entre le haut du siège TOP et le haut du bloc avatar/nom/score
## (`InfoBox`), pour cette orientation uniquement. Contrairement aux autres
## orientations, TOP place la pile de dos de carte et l'avatar côte à côte
## (voir `_layout_seat`) : la pile peut légèrement déborder sous la barre de
## menu (siège volontairement positionné haut dans `table.tscn`), mais
## l'avatar doit lui rester entièrement visible sous cette barre. Ce décalage
## fixe le haut de l'avatar en dessous du haut du siège pour garantir cela.
const TOP_INFO_BOX_OFFSET: float = 50.0
## Largeur réservée à la pile de dos (jusqu'à 13 cartes empilées).
const TOP_HAND_STACK_MAX_WIDTH: float = 320.0
const TOP_INFO_BOX_WIDTH: float = 128.0
## Siège humain sans pile de dos : bloc avatar ancré en bas à droite du siège.
const BOTTOM_INFO_BOX_WIDTH: float = 124.0
const BOTTOM_INFO_BOX_HEIGHT: float = 98.0
## Marge sous le bloc avatar/nom/score pour éviter le rognage en bas d'écran.
const BOTTOM_INFO_BOX_BOTTOM_OFFSET: float = 14.0
## Largeur du bloc avatar pour les sièges latéraux (évite le chevauchement avec la pile).
const SIDE_INFO_BOX_WIDTH: float = 112.0
const SIDE_HAND_INFO_GAP: float = 14.0
## Rotation (degrés) des dos de carte des piles latérales : les cartes sont
## couchées (bord long horizontal) plutôt que debout, avec leur ancien bord
## "haut" tourné vers le centre de la table (symétrie gauche/droite).
const LEFT_CARD_ROTATION_DEGREES: float = 90.0
const RIGHT_CARD_ROTATION_DEGREES: float = -90.0

enum SeatOrientation { TOP, BOTTOM, LEFT, RIGHT }

@export var orientation: SeatOrientation = SeatOrientation.BOTTOM:
	set(value):
		orientation = value
		_layout_seat()
		_refresh_hand_back()

@export var player_name: String = "":
	set(value):
		player_name = value
		_refresh_labels()

@export var score: int = 0:
	set(value):
		score = value
		_refresh_labels()

@export var heart_penalty: int = 0:
	set(value):
		heart_penalty = value
		_refresh_labels()

## Personnage affiché par l'avatar (0-3), voir `PlayerAvatar.CHARACTER_SHEETS`.
@export_range(0, 3, 1) var character_id: int = 0:
	set(value):
		character_id = value
		_refresh_avatar()

@export var hand_card_count: int = 13:
	set(value):
		hand_card_count = value
		_refresh_hand_back()

## Si faux, aucune pile de dos de carte n'est affichée (siège du joueur
## humain : sa main est déjà visible en face via `PlayerBottomHand`).
@export var show_hand_back: bool = true:
	set(value):
		show_hand_back = value
		_refresh_hand_back()

## Vrai si c'est le tour de ce joueur : affiche une surbrillance à crochets
## de coin bleus sur son avatar.
@export var is_active_turn: bool = false:
	set(value):
		is_active_turn = value
		_refresh_turn_highlight()

@onready var _hand_back_row: Control = $HandBackRow
@onready var _hand_back_column: Control = $HandBackColumn
@onready var _info_box: VBoxContainer = $InfoBox
@onready var _name_label: Label = $InfoBox/NameLabel
@onready var _score_label: Label = $InfoBox/ScoreRow/ScoreLabel
@onready var _heart_label: Label = $InfoBox/ScoreRow/HeartPenaltyLabel
@onready var _avatar_placeholder: Control = $InfoBox/AvatarPlaceholder
@onready var _turn_highlight: Control = $InfoBox/AvatarPlaceholder/TurnHighlight
@onready var _avatar: Control = $InfoBox/AvatarPlaceholder/Avatar

var _turn_pulse_tween: Tween


func _ready() -> void:
	if player_name.is_empty():
		player_name = GameCopy.default_seat_name()
	_layout_seat()
	LocaleAware.bind(self, _refresh_locale)
	_refresh_locale()
	_refresh_hand_back()
	_refresh_turn_highlight()
	_refresh_avatar()
	_hand_back_row.resized.connect(_on_hand_back_container_resized)
	_hand_back_column.resized.connect(_on_hand_back_container_resized)
	resized.connect(_on_seat_resized)


func _on_seat_resized() -> void:
	if orientation == SeatOrientation.TOP:
		_layout_seat()


func _refresh_locale() -> void:
	_refresh_labels()
	_setup_score_tooltip()


func _on_hand_back_container_resized() -> void:
	if hand_card_count <= 0 or not show_hand_back:
		return
	var container: Control = _hand_back_row if _is_horizontal_stack() else _hand_back_column
	if container.size.x <= 0.0 or container.size.y <= 0.0:
		return
	_refresh_hand_back()

func _setup_score_tooltip() -> void:
	if _avatar_placeholder:
		_avatar_placeholder.mouse_filter = Control.MOUSE_FILTER_STOP
		_avatar_placeholder.tooltip_text = GameCopy.seat_score_tooltip()

func set_active_turn(value: bool) -> void:
	is_active_turn = value

func _refresh_turn_highlight() -> void:
	if not _turn_highlight:
		return
	_turn_highlight.visible = is_active_turn
	_update_turn_pulse()
	if _avatar is PlayerAvatar:
		(_avatar as PlayerAvatar).set_turn_active(is_active_turn)


func _update_turn_pulse() -> void:
	if _turn_pulse_tween and _turn_pulse_tween.is_valid():
		_turn_pulse_tween.kill()
		_turn_pulse_tween = null
	if not _avatar_placeholder:
		return
	if not is_active_turn:
		_avatar_placeholder.modulate = Color.WHITE
		return
	_turn_pulse_tween = create_tween().set_loops()
	_turn_pulse_tween.tween_property(_avatar_placeholder, "modulate", Color(1.25, 1.2, 1.05, 1.0), 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_turn_pulse_tween.tween_property(_avatar_placeholder, "modulate", Color.WHITE, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func play_hand_win_reaction() -> void:
	if _avatar is PlayerAvatar:
		(_avatar as PlayerAvatar).play_hand_win_bounce()


func play_hand_loss_reaction() -> void:
	if _avatar is PlayerAvatar:
		(_avatar as PlayerAvatar).play_hand_loss_shake()

func _refresh_avatar() -> void:
	if not _avatar:
		return
	# `_avatar` est un `PlayerAvatar` (voir scenes/components/player_avatar.tscn),
	# mais typé `Control` ici pour rester cohérent avec `_turn_highlight` :
	# `set()` évite une dépendance statique inutile à ce script de composant.
	_avatar.set("character_index", character_id)

func set_player_info(new_name: String, new_score: int, new_heart_penalty: int) -> void:
	player_name = new_name
	score = new_score
	heart_penalty = new_heart_penalty

func _refresh_labels() -> void:
	if not _name_label:
		return
	_name_label.add_theme_font_size_override("font_size", LocaleFonts.SEAT_FONT_SIZE)
	_score_label.add_theme_font_size_override("font_size", LocaleFonts.SEAT_FONT_SIZE)
	_heart_label.add_theme_font_size_override("font_size", LocaleFonts.SEAT_FONT_SIZE)
	_name_label.text = player_name
	_score_label.text = GameCopy.seat_score_parens(score)
	_heart_label.text = GameCopy.seat_hearts_count(heart_penalty)

## Place la pile de cartes contre le bord de la table (haut/bas/gauche/droite
## selon l'orientation) et le bloc avatar/nom/score entre cette pile et le
## centre de la table.
func _layout_seat() -> void:
	if not _hand_back_row or not _hand_back_column or not _info_box:
		return

	_hand_back_row.visible = _is_horizontal_stack()
	_hand_back_column.visible = not _is_horizontal_stack()
	# Réinitialisé à chaque relayout : seule l'orientation TOP a besoin d'un
	# alignement en haut de bloc (voir plus bas) ; toutes les autres gardent
	# l'avatar/nom/score centré verticalement dans l'espace disponible.
	_info_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var thickness: float = _hand_stack_thickness()

	match orientation:
		SeatOrientation.TOP:
			# Pile + avatar centrés horizontalement dans le siège (espacement fixe
			# entre les deux) pour éviter le déséquilibre vers la gauche.
			var block_width: float = _top_block_width()
			var hand_left: float = maxf(0.0, (size.x - block_width) / 2.0)
			var hand_right: float = hand_left + TOP_HAND_STACK_MAX_WIDTH
			var info_left: float = hand_right + HAND_INFO_GAP
			var info_right: float = info_left + TOP_INFO_BOX_WIDTH
			_hand_back_row.anchor_left = 0.0
			_hand_back_row.anchor_top = 0.0
			_hand_back_row.anchor_right = 0.0
			_hand_back_row.anchor_bottom = 0.0
			_hand_back_row.offset_left = hand_left
			_hand_back_row.offset_top = 0.0
			_hand_back_row.offset_right = hand_right
			_hand_back_row.offset_bottom = thickness
			_info_box.anchor_left = 0.0
			_info_box.anchor_top = 0.0
			_info_box.anchor_right = 0.0
			_info_box.anchor_bottom = 0.0
			_info_box.offset_left = info_left
			_info_box.offset_right = info_right
			_info_box.offset_top = TOP_INFO_BOX_OFFSET
			_info_box.offset_bottom = thickness
			_info_box.alignment = BoxContainer.ALIGNMENT_BEGIN
		SeatOrientation.BOTTOM:
			_hand_back_row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
			_hand_back_row.offset_top = -thickness
			if show_hand_back:
				_info_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				_info_box.offset_bottom = -(thickness + HAND_INFO_GAP)
			else:
				_info_box.anchor_left = 1.0
				_info_box.anchor_top = 1.0
				_info_box.anchor_right = 1.0
				_info_box.anchor_bottom = 1.0
				_info_box.offset_left = -BOTTOM_INFO_BOX_WIDTH
				_info_box.offset_top = -(BOTTOM_INFO_BOX_HEIGHT + BOTTOM_INFO_BOX_BOTTOM_OFFSET)
				_info_box.offset_right = 0.0
				_info_box.offset_bottom = -BOTTOM_INFO_BOX_BOTTOM_OFFSET
		SeatOrientation.LEFT:
			_hand_back_column.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
			_hand_back_column.offset_right = thickness
			_info_box.anchor_left = 1.0
			_info_box.anchor_top = 0.0
			_info_box.anchor_right = 1.0
			_info_box.anchor_bottom = 1.0
			_info_box.offset_left = -(SIDE_INFO_BOX_WIDTH + SIDE_HAND_INFO_GAP + thickness)
			_info_box.offset_right = -(thickness + SIDE_HAND_INFO_GAP)
			_info_box.alignment = BoxContainer.ALIGNMENT_CENTER
		SeatOrientation.RIGHT:
			_hand_back_column.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
			_hand_back_column.offset_left = -thickness
			_info_box.anchor_left = 0.0
			_info_box.anchor_top = 0.0
			_info_box.anchor_right = 0.0
			_info_box.anchor_bottom = 1.0
			_info_box.offset_left = 0.0
			_info_box.offset_right = SIDE_INFO_BOX_WIDTH
			_info_box.alignment = BoxContainer.ALIGNMENT_CENTER

func _is_horizontal_stack() -> bool:
	return orientation == SeatOrientation.TOP or orientation == SeatOrientation.BOTTOM


func _top_block_width() -> float:
	return TOP_HAND_STACK_MAX_WIDTH + HAND_INFO_GAP + TOP_INFO_BOX_WIDTH

## Échelle des dos de carte selon l'orientation : `CARD_BACK_SCALE` pour les
## piles horizontales (TOP/BOTTOM), `CARD_BACK_SCALE_SIDE` pour les piles
## latérales (LEFT/RIGHT, cartes tournées de 90°).
func _hand_back_scale() -> float:
	return CARD_BACK_SCALE if _is_horizontal_stack() else CARD_BACK_SCALE_SIDE

## Rotation (degrés) à appliquer à chaque dos de carte : aucune pour les piles
## horizontales, ±90° pour les piles latérales (voir constantes ci-dessus).
func _hand_back_rotation_degrees() -> float:
	match orientation:
		SeatOrientation.LEFT:
			return LEFT_CARD_ROTATION_DEGREES
		SeatOrientation.RIGHT:
			return RIGHT_CARD_ROTATION_DEGREES
		_:
			return 0.0

## Épaisseur (en pixels) réservée à la pile de dos de carte : dimension de la
## carte perpendiculaire à l'axe d'empilement, c'est-à-dire sa hauteur de base
## à l'échelle courante. Pour une pile horizontale (TOP/BOTTOM), c'est
## directement la hauteur visuelle de la carte debout. Pour une pile latérale
## (LEFT/RIGHT), la carte est couchée à 90° : sa hauteur de base devient sa
## largeur visuelle, qui est justement la dimension perpendiculaire à
## l'empilement (vertical) recherchée ici — la rotation permute exactement
## les deux usages, d'où la même formule dans les deux cas. Aucune
## réservation si la pile de dos n'est pas affichée (siège du joueur humain) :
## le bloc avatar/nom/score récupère alors tout l'espace du siège.
func _hand_stack_thickness() -> float:
	if not show_hand_back:
		return 0.0
	var effective_size: Vector2 = CARD_BASE_SIZE * _hand_back_scale()
	return effective_size.y + HAND_STACK_PADDING

## Position de chaque carte de la pile, calculée manuellement (et non via un
## `BoxContainer`) : un conteneur de layout automatique n'a aucune
## connaissance de la mise à l'échelle (`scale`) ni de la rotation
## appliquées directement sur ses enfants, il continue de les arranger selon
## leur taille non transformée (`custom_minimum_size`). C'était la cause de
## deux bugs : les piles latérales (LEFT/RIGHT) semblaient ne jamais tourner
## visuellement à l'écran (l'empilement vertical utilisait toujours la
## hauteur non tournée de la carte) et l'agrandissement des dos de carte se
## traduisait par un chevauchement excessif plutôt qu'une pile plus grande.
## En positionnant chaque carte nous-mêmes (comme le fait déjà la main du
## joueur humain dans `table.gd`), on peut placer précisément l'empreinte
## réellement visible à l'écran, tournée ou non.
##
## Retourne le centre (dans l'espace local du conteneur cible) de chaque
## carte de la pile, ainsi que la taille visuelle (après rotation) commune à
## toutes les cartes.
func _hand_back_layout(container_size: Vector2, back_scale: float, back_rotation: float, count: int) -> Dictionary:
	var effective_size: Vector2 = CARD_BASE_SIZE * back_scale
	# Empreinte visible à l'écran une fois la rotation appliquée : une
	# rotation de ±90° échange largeur et hauteur.
	var visual_size: Vector2 = effective_size
	if back_rotation != 0.0:
		visual_size = Vector2(effective_size.y, effective_size.x)
	# Bande visible fixe en pixels écran (indépendante de l'échelle) : garde
	# une pile condensée de largeur prévisible même quand `back_scale` change,
	# plutôt que de laisser la pile totale grandir avec l'échelle.
	var visible_strip: float = HAND_BACK_VISIBLE_STRIP
	var horizontal_stack: bool = _is_horizontal_stack()
	var step: float = visible_strip
	var stack_extent: float = visual_size.x + step * maxf(count - 1, 0.0) if horizontal_stack \
		else visual_size.y + step * maxf(count - 1, 0.0)
	var start_offset: float = -stack_extent / 2.0
	var centers: Array[Vector2] = []
	for i in count:
		var along_stack: float = start_offset + (visual_size.x if horizontal_stack else visual_size.y) / 2.0 + step * i
		var center: Vector2 = Vector2(container_size.x / 2.0 + along_stack, container_size.y / 2.0) if horizontal_stack \
			else Vector2(container_size.x / 2.0, container_size.y / 2.0 + along_stack)
		centers.append(center)
	return {"centers": centers, "visual_size": visual_size}

func get_hand_back_card_views() -> Array[Control]:
	if not show_hand_back:
		return []
	var container: Control = _hand_back_row if _is_horizontal_stack() else _hand_back_column
	var cards: Array[Control] = []
	for child in container.get_children():
		if is_instance_valid(child):
			cards.append(child as Control)
	return cards

## Supprime immédiatement les dos de carte d'un conteneur (évite les références
## invalides si `queue_free()` différé pendant une animation de distribution).
func _clear_hand_back_container(container: Control) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.free()

## Décalage local (dans le conteneur de dos de carte) depuis lequel chaque
## carte glisse jusqu'à sa position finale lors de la distribution.
func get_deal_start_offset() -> Vector2:
	match orientation:
		SeatOrientation.LEFT:
			return Vector2(-420.0, 0.0)
		SeatOrientation.RIGHT:
			return Vector2(420.0, 0.0)
		SeatOrientation.TOP:
			return Vector2(0.0, -320.0)
		_:
			return Vector2(0.0, 420.0)

## Force la reconstruction de la pile de dos de carte (utile avant une
## animation de distribution si `hand_card_count` n'a pas changé).
func force_refresh_hand_back() -> void:
	_refresh_hand_back()

func _refresh_hand_back() -> void:
	if not _hand_back_row or not _hand_back_column:
		return
	_clear_hand_back_container(_hand_back_row)
	_clear_hand_back_container(_hand_back_column)
	if not show_hand_back:
		return
	var target_container: Control = _hand_back_row if _is_horizontal_stack() else _hand_back_column
	var back_scale: float = _hand_back_scale()
	var back_rotation: float = _hand_back_rotation_degrees()
	var layout: Dictionary = _hand_back_layout(target_container.size, back_scale, back_rotation, hand_card_count)
	var centers: Array = layout["centers"]
	var pivot: Vector2 = CARD_BASE_SIZE * 0.5
	for i in hand_card_count:
		var card: Control = CardViewScene.instantiate()
		card.scale = Vector2(back_scale, back_scale)
		card.pivot_offset = pivot
		card.rotation_degrees = back_rotation
		target_container.add_child(card)
		# La position déplace l'origine (coin haut-gauche non transformé) du
		# nœud ; le point qui reste fixe à l'écran lors de la mise à
		# l'échelle/rotation est `position + pivot_offset` (voir
		# `table.gd::_rebuild_human_hand` pour le même principe). On veut que
		# ce point (le centre géométrique de la carte) coïncide avec le
		# centre calculé par `_hand_back_layout`.
		card.position = (centers[i] as Vector2) - pivot
