class_name TableHandStart
extends RefCounted
## Bandeau « la partie / la manche commence » après la distribution des cartes.


static func play(ctx: TableContext, is_first_hand_of_match: bool) -> void:
	if not ctx.is_active():
		return

	var message_key: String = (
		TableKeys.MATCH_START_BANNER if is_first_hand_of_match else TableKeys.HAND_START_BANNER
	)
	var notif := PixelNotification.new()
	notif.name = "HandStartBanner"
	ctx.animation_layer.add_child(notif)
	await notif.show_message(
		TranslationServer.translate(message_key),
		PixelNotification.Kind.INFO,
		TableAnimations.HAND_START_BANNER_VISIBLE_SEC
	)
	if is_instance_valid(notif):
		notif.queue_free()
