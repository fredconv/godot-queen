class_name TableAnimations
extends RefCounted
## Regroupe les animations `Tween` de la table de jeu (pose d'une carte,
## surbrillance du vainqueur d'un pli, ramassage du pli) : fonctions statiques
## sans état, appelées depuis `scripts/ui/table.gd`. Purement visuel, aucune
## règle de jeu ici.
##
## Toutes les fonctions attendent des `Control` dont la rotation reste à 0° et
## dont `pivot_offset` reste à sa valeur par défaut `(0, 0)` (voir
## `table.gd::_spawn_traveling_card`) : dans ces conditions, le centre visuel
## de la carte est toujours `global_position + size * scale / 2`, quelle que
## soit l'échelle appliquée, ce qui évite toute ambiguïté liée au pivot lors
## du calcul de la position cible.

## Durée du glissement d'une carte jouée depuis la main/le siège d'origine
## jusqu'à son emplacement dans le pli.
const CARD_PLAY_DURATION_SEC: float = 0.15
## Durée minimale d'affichage du pli complet avant ramassage.
const TRICK_VISIBLE_DURATION_SEC: float = 1.0
## Dernier pli d'une partie : laisser les cartes visibles avant la popup de fin.
const MATCH_END_TRICK_VISIBLE_DURATION_SEC: float = 3.5
## Durée du glissement des 4 cartes du pli vers le siège du vainqueur.
const TRICK_COLLECT_DURATION_SEC: float = 0.18
## Facteur d'agrandissement appliqué à la carte gagnante lors de sa mise en
## surbrillance (en plus des crochets de coin déjà gérés par `CardView`).
const WINNER_HIGHLIGHT_SCALE_FACTOR: float = 1.18
const WINNER_HIGHLIGHT_DURATION_SEC: float = 0.1
## Distribution visuelle : glissement rapide depuis le bord de l'écran.
const DEAL_CARD_DURATION_SEC: float = 0.1
## Pause entre l'arrivée de deux cartes consécutives (même siège).
const DEAL_CARD_STAGGER_SEC: float = 0.023
## Pause lisible après la distribution, avant le premier coup de la manche.
const HAND_START_BANNER_VISIBLE_SEC: float = 2.0
const HAND_START_BANNER_EXIT_SEC: float = 0.35
const HAND_START_BANNER_EXIT_OFFSET_Y: float = -140.0
const CARD_LAND_BOUNCE_UP_PX: float = 6.0
const CARD_LAND_BOUNCE_UP_SEC: float = 0.05
const CARD_LAND_BOUNCE_DOWN_SEC: float = 0.07
const QUEEN_BULLET_TRAVEL_SEC: float = 1.15
const QUEEN_BULLET_ZOOM: float = 2.75
const QUEEN_BULLET_RELEASE_SEC: float = 0.42
const QUEEN_BULLET_HOLD_SEC: float = 0.35
const QUEEN_EMPHASIS_PAUSE_SEC: float = 0.15
const QUEEN_EMPHASIS_SCALE_FACTOR: float = 1.22
const QUEEN_EMPHASIS_DURATION_SEC: float = 0.18
const QUEEN_DIM_ALPHA: float = 0.58

## Fait glisser `card_view` vers `target_position` (espace local du parent).
static func deal_card_to_local_position(
	host: Node,
	card_view: Control,
	target_position: Vector2,
	duration_sec: float = DEAL_CARD_DURATION_SEC
) -> void:
	var tween: Tween = host.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_view, "position", target_position, duration_sec)
	await tween.finished

## Fait glisser `card_view` (déjà positionnée à son point de départ) jusqu'à
## `target_global_center` en `CARD_PLAY_DURATION_SEC`. `host` doit être un
## `Node` de la scène (fournit `create_tween()`).
static func play_card_to_trick(host: Node, card_view: Control, target_global_center: Vector2) -> void:
	var visual_half_size: Vector2 = card_view.size * card_view.scale / 2.0
	var target_pos: Vector2 = target_global_center - visual_half_size
	var tween: Tween = host.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_view, "global_position", target_pos, CARD_PLAY_DURATION_SEC)
	await tween.finished
	var bounce: Tween = host.create_tween()
	bounce.tween_property(
		card_view,
		"global_position",
		target_pos + Vector2(0.0, -CARD_LAND_BOUNCE_UP_PX),
		CARD_LAND_BOUNCE_UP_SEC
	).set_ease(Tween.EASE_OUT)
	bounce.tween_property(card_view, "global_position", target_pos, CARD_LAND_BOUNCE_DOWN_SEC) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await bounce.finished


## Bullet time : glissement lent, zoom caméra fort et assombrissement jusqu'à
## l'arrivée de la Dame de Pique sur le tapis.
static func play_queen_bullet_time(
	host: Control,
	card_view: Control,
	target_global_center: Vector2,
	camera: Camera2D,
	dim_overlay: ColorRect
) -> void:
	var visual_half_size: Vector2 = card_view.size * card_view.scale / 2.0
	var target_pos: Vector2 = target_global_center - visual_half_size
	var table_center_global: Vector2 = host.get_global_transform_with_canvas() * (host.size * 0.5)

	camera.enabled = true
	camera.make_current()
	camera.global_position = table_center_global
	camera.zoom = Vector2.ONE

	dim_overlay.visible = true
	dim_overlay.modulate.a = 0.0
	card_view.z_index = 20

	var cinematic: Tween = host.create_tween().set_parallel(true)
	cinematic.set_trans(Tween.TRANS_CUBIC)
	cinematic.set_ease(Tween.EASE_IN_OUT)
	cinematic.tween_property(camera, "global_position", target_global_center, QUEEN_BULLET_TRAVEL_SEC)
	cinematic.tween_property(camera, "zoom", Vector2(QUEEN_BULLET_ZOOM, QUEEN_BULLET_ZOOM), QUEEN_BULLET_TRAVEL_SEC)
	cinematic.tween_property(dim_overlay, "modulate:a", QUEEN_DIM_ALPHA, QUEEN_BULLET_TRAVEL_SEC * 0.45)

	var card_tween: Tween = host.create_tween()
	card_tween.set_trans(Tween.TRANS_QUAD)
	card_tween.set_ease(Tween.EASE_IN_OUT)
	card_tween.tween_property(card_view, "global_position", target_pos, QUEEN_BULLET_TRAVEL_SEC)
	await card_tween.finished

	if not is_instance_valid(card_view):
		await _release_queen_bullet_time(host, camera, dim_overlay, table_center_global)
		return

	await emphasize_queen_of_spades(host, card_view)
	await host.get_tree().create_timer(QUEEN_BULLET_HOLD_SEC).timeout
	await _release_queen_bullet_time(host, camera, dim_overlay, table_center_global)

	if is_instance_valid(card_view):
		card_view.z_index = 0


static func _release_queen_bullet_time(
	host: Control,
	camera: Camera2D,
	dim_overlay: ColorRect,
	table_center_global: Vector2
) -> void:
	var release: Tween = host.create_tween().set_parallel(true)
	release.set_trans(Tween.TRANS_CUBIC)
	release.set_ease(Tween.EASE_IN_OUT)
	release.tween_property(camera, "zoom", Vector2.ONE, QUEEN_BULLET_RELEASE_SEC)
	release.tween_property(camera, "global_position", table_center_global, QUEEN_BULLET_RELEASE_SEC)
	release.tween_property(dim_overlay, "modulate:a", 0.0, QUEEN_BULLET_RELEASE_SEC)
	await release.finished
	camera.enabled = false
	dim_overlay.visible = false


## Pause, assombrissement et léger zoom lorsque la Dame de Pique est posée.
static func emphasize_queen_of_spades(host: Node, card_view: Control) -> void:
	await host.get_tree().create_timer(QUEEN_EMPHASIS_PAUSE_SEC).timeout
	if not is_instance_valid(card_view):
		return
	var base_scale: Vector2 = card_view.scale
	var base_modulate: Color = card_view.modulate
	var tween: Tween = host.create_tween().set_parallel(true)
	tween.tween_property(card_view, "scale", base_scale * QUEEN_EMPHASIS_SCALE_FACTOR, QUEEN_EMPHASIS_DURATION_SEC) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_view, "modulate", Color(0.72, 0.72, 0.82, 1.0), QUEEN_EMPHASIS_DURATION_SEC)
	await tween.finished
	if is_instance_valid(card_view):
		card_view.modulate = base_modulate

## Met en évidence la carte gagnante d'un pli : réutilise la surbrillance à
## crochets de coin existante (`CardView.set_selected`) et ajoute un léger
## agrandissement.
static func highlight_winning_card(host: Node, card_view: Control) -> void:
	card_view.set_selected(true)
	var tween: Tween = host.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_view, "scale", card_view.scale * WINNER_HIGHLIGHT_SCALE_FACTOR, WINNER_HIGHLIGHT_DURATION_SEC)
	await tween.finished

## Ramasse les cartes du pli (`card_views`) en les faisant glisser ensemble
## vers `target_global_center` (siège du vainqueur), puis les fait disparaître
## d'un coup à l'arrivée (comportement "ramassage de pli").
static func collect_trick(host: Node, card_views: Array, target_global_center: Vector2) -> void:
	var tween: Tween = host.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	for card_view in card_views:
		var control: Control = card_view as Control
		var visual_half_size: Vector2 = control.size * control.scale / 2.0
		tween.tween_property(control, "global_position", target_global_center - visual_half_size, TRICK_COLLECT_DURATION_SEC)
	await tween.finished
	for card_view in card_views:
		(card_view as Control).queue_free()
