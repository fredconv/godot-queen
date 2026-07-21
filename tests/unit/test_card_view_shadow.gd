extends GdUnitTestSuite
## CardView — ombre éventail (pas de step au repos).


const _CARD_SCENE: PackedScene = preload("res://scenes/components/card_view.tscn")


func test_resting_shadow_hidden_by_default() -> void:
	var card: Control = auto_free(_CARD_SCENE.instantiate()) as Control
	add_child(card)
	await get_tree().process_frame
	var shadow: ColorRect = card.get_node("Shadow") as ColorRect
	assert_bool(shadow.visible).is_false()


func test_lift_shows_soft_shadow() -> void:
	var card: Control = auto_free(_CARD_SCENE.instantiate()) as Control
	add_child(card)
	await get_tree().process_frame
	card.set("hovered", true)
	var shadow: ColorRect = card.get_node("Shadow") as ColorRect
	assert_bool(shadow.visible).is_true()
	assert_float(shadow.modulate.a).is_less(0.35)


func test_resting_drop_shadow_flag() -> void:
	var card: Control = auto_free(_CARD_SCENE.instantiate()) as Control
	add_child(card)
	await get_tree().process_frame
	card.call("set_resting_drop_shadow", true)
	var shadow: ColorRect = card.get_node("Shadow") as ColorRect
	assert_bool(shadow.visible).is_true()
	assert_float(shadow.modulate.a).is_less_equal(0.15)
