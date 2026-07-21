class_name TableTrickDisplay
extends RefCounted
## Cartes du pli ancrées dans les emplacements (suivent TrickArea / Context Shell).


static func sync_card_positions(ctx: TableContext) -> void:
	if ctx.trick_card_views.is_empty():
		return
	for logical_seat: Variant in ctx.trick_card_views.keys():
		var card_view: Control = ctx.trick_card_views[logical_seat] as Control
		if not is_instance_valid(card_view):
			continue
		dock_card_in_slot(ctx, logical_seat as int, card_view)


## Après l’anim de vol : rattache la carte au slot pour qu’elle suive le layout.
static func dock_card_in_slot(ctx: TableContext, logical_seat: int, card_view: Control) -> void:
	if ctx == null or not is_instance_valid(card_view):
		return
	var target_slot: Control = TableSeatDisplayMap.get_trick_slot(ctx, logical_seat)
	if target_slot == null or not is_instance_valid(target_slot):
		return
	if card_view.get_parent() != target_slot:
		card_view.reparent(target_slot)
	_center_card_in_slot(card_view, target_slot)
	## Au-dessus du SlotMarker.
	target_slot.move_child(card_view, target_slot.get_child_count() - 1)


static func _center_card_in_slot(card_view: Control, slot: Control) -> void:
	card_view.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card_view.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	card_view.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var visual_half_size: Vector2 = card_view.size * card_view.scale * 0.5
	card_view.position = slot.size * 0.5 - visual_half_size


## Avant une anim globale (collecte) : remonte sur AnimationLayer en gardant le centre.
static func undock_to_animation_layer(ctx: TableContext, card_view: Control) -> void:
	if ctx == null or ctx.animation_layer == null or not is_instance_valid(card_view):
		return
	if card_view.get_parent() == ctx.animation_layer:
		return
	var center: Vector2 = card_view.get_global_rect().get_center()
	card_view.reparent(ctx.animation_layer)
	var visual_half_size: Vector2 = card_view.size * card_view.scale * 0.5
	card_view.global_position = center - visual_half_size
