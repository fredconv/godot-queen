class_name UiOffsetAnim
extends RefCounted
## Animations UI via offset_transform (Godot 4.7) — ne casse pas le layout des containers.


static func enable_on(control: Control, visual_only: bool = true) -> void:
	control.offset_transform_enabled = true
	control.offset_transform_visual_only = visual_only
	control.offset_transform_pivot_ratio = Vector2(0.5, 0.5)


static func prepare_hidden(control: Control) -> void:
	enable_on(control)
	control.offset_transform_scale = Vector2.ZERO


static func tween_scale(
	control: Control,
	target: Vector2,
	duration: float = 0.15,
	trans: Tween.TransitionType = Tween.TRANS_BACK,
	ease_type: Tween.EaseType = Tween.EASE_OUT
) -> Tween:
	enable_on(control)
	var tween := control.create_tween()
	tween.set_ease(ease_type).set_trans(trans)
	tween.tween_property(control, "offset_transform_scale", target, duration)
	return tween


static func stagger_scale_in(
	controls: Array,
	duration: float = 0.15,
	stagger: float = 0.05,
	trans: Tween.TransitionType = Tween.TRANS_BACK
) -> Tween:
	if controls.is_empty():
		return null
	var host := controls[0] as Control
	if host == null:
		return null
	var tween := host.create_tween()
	tween.set_parallel(true)
	for idx: int in controls.size():
		var ctrl := controls[idx] as Control
		if ctrl == null:
			continue
		enable_on(ctrl)
		ctrl.offset_transform_scale = Vector2.ZERO
		tween.tween_property(ctrl, "offset_transform_scale", Vector2.ONE, duration) \
			.set_delay(float(idx) * stagger) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(trans)
	return tween


static func stagger_scale_out(
	controls: Array,
	duration: float = 0.15,
	stagger: float = 0.05,
	trans: Tween.TransitionType = Tween.TRANS_CUBIC
) -> Tween:
	if controls.is_empty():
		return null
	var host := controls[0] as Control
	if host == null:
		return null
	var tween := host.create_tween()
	tween.set_parallel(true)
	for idx: int in controls.size():
		var ctrl := controls[idx] as Control
		if ctrl == null:
			continue
		enable_on(ctrl)
		tween.tween_property(ctrl, "offset_transform_scale", Vector2.ZERO, duration) \
			.set_delay(float(idx) * stagger) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(trans)
	return tween
