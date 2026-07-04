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
## jusqu'à son emplacement dans le pli (spec UX : "environ 0.3 seconde").
const CARD_PLAY_DURATION_SEC: float = 0.3
## Durée minimale d'affichage du pli complet avant ramassage (spec UX : "au
## moins 2 secondes").
const TRICK_VISIBLE_DURATION_SEC: float = 2.0
## Durée du glissement des 4 cartes du pli vers le siège du vainqueur.
const TRICK_COLLECT_DURATION_SEC: float = 0.35
## Facteur d'agrandissement appliqué à la carte gagnante lors de sa mise en
## surbrillance (en plus des crochets de coin déjà gérés par `CardView`).
const WINNER_HIGHLIGHT_SCALE_FACTOR: float = 1.18
const WINNER_HIGHLIGHT_DURATION_SEC: float = 0.2

## Fait glisser `card_view` (déjà positionnée à son point de départ) jusqu'à
## `target_global_center` en `CARD_PLAY_DURATION_SEC`. `host` doit être un
## `Node` de la scène (fournit `create_tween()`).
static func play_card_to_trick(host: Node, card_view: Control, target_global_center: Vector2) -> void:
	var visual_half_size: Vector2 = card_view.size * card_view.scale / 2.0
	var tween: Tween = host.create_tween()
	tween.tween_property(card_view, "global_position", target_global_center - visual_half_size, CARD_PLAY_DURATION_SEC) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

## Met en évidence la carte gagnante d'un pli : réutilise la surbrillance à
## crochets de coin existante (`CardView.set_selected`) et ajoute un léger
## agrandissement.
static func highlight_winning_card(host: Node, card_view: Control) -> void:
	card_view.set_selected(true)
	var tween: Tween = host.create_tween()
	tween.tween_property(card_view, "scale", card_view.scale * WINNER_HIGHLIGHT_SCALE_FACTOR, WINNER_HIGHLIGHT_DURATION_SEC) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

## Ramasse les cartes du pli (`card_views`) en les faisant glisser ensemble
## vers `target_global_center` (siège du vainqueur), puis les fait disparaître
## d'un coup à l'arrivée (comportement "ramassage de pli").
static func collect_trick(host: Node, card_views: Array, target_global_center: Vector2) -> void:
	var tween: Tween = host.create_tween()
	tween.set_parallel(true)
	for card_view in card_views:
		var control: Control = card_view as Control
		var visual_half_size: Vector2 = control.size * control.scale / 2.0
		tween.tween_property(control, "global_position", target_global_center - visual_half_size, TRICK_COLLECT_DURATION_SEC) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	for card_view in card_views:
		(card_view as Control).queue_free()
