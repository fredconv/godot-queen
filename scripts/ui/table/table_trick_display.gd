class_name TableTrickDisplay
extends RefCounted
## Repositionnement visuel des cartes du pli en cours (rotation hot seat).


static func sync_card_positions(ctx: TableContext) -> void:
	if ctx.trick_card_views.is_empty():
		return
	for logical_seat: Variant in ctx.trick_card_views.keys():
		var card_view: Control = ctx.trick_card_views[logical_seat] as Control
		if not is_instance_valid(card_view):
			continue
		_move_card_to_trick_slot(ctx, logical_seat as int, card_view)


static func _move_card_to_trick_slot(ctx: TableContext, logical_seat: int, card_view: Control) -> void:
	var target_slot: Control = TableSeatDisplayMap.get_trick_slot(ctx, logical_seat)
	var target_center: Vector2 = target_slot.get_global_transform_with_canvas() * (target_slot.size / 2.0)
	var visual_half_size: Vector2 = TableConstants.CARD_BASE_SIZE * TableConstants.TRICK_CARD_SCALE / 2.0
	card_view.global_position = target_center - visual_half_size
