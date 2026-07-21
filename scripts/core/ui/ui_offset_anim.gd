class_name UiOffsetAnim
extends RefCounted
## Animations UI via offset_transform (Godot 4.7) — ne casse pas le layout des containers.


const MODAL_OPEN_SEC: float = 0.18
const MODAL_CLOSE_SEC: float = 0.12
const DIALOG_ENTRANCE_SEC: float = 0.32


static func enable_on(control: Control, visual_only: bool = true) -> void:
	control.offset_transform_enabled = true
	control.offset_transform_visual_only = visual_only
	control.offset_transform_pivot_ratio = Vector2(0.5, 0.5)


static func prepare_hidden(control: Control) -> void:
	enable_on(control)
	control.offset_transform_scale = Vector2.ZERO


static func reset_scale(control: Control) -> void:
	enable_on(control)
	control.offset_transform_scale = Vector2.ONE


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


static func kill_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()


## Entrée modale : fade backdrop + scale panel (offset_transform).
static func play_modal_open(
	host: Node,
	backdrop: Control,
	panel: Control,
	duration: float = MODAL_OPEN_SEC
) -> Tween:
	var tween: Tween = host.create_tween()
	tween.set_parallel(true)
	if backdrop != null and is_instance_valid(backdrop):
		backdrop.modulate.a = 0.0
		tween.tween_property(backdrop, "modulate:a", 1.0, duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if panel != null and is_instance_valid(panel):
		prepare_hidden(panel)
		tween.tween_property(panel, "offset_transform_scale", Vector2.ONE, duration) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


## Sortie modale : fade + scale down. Appeler `finished` pour hide.
static func play_modal_close(
	host: Node,
	backdrop: Control,
	panel: Control,
	duration: float = MODAL_CLOSE_SEC
) -> Tween:
	var tween: Tween = host.create_tween()
	tween.set_parallel(true)
	if backdrop != null and is_instance_valid(backdrop):
		tween.tween_property(backdrop, "modulate:a", 0.0, duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if panel != null and is_instance_valid(panel):
		enable_on(panel)
		tween.tween_property(panel, "offset_transform_scale", Vector2(0.92, 0.92), duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(panel, "modulate:a", 0.0, duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween


## Entrée dialog table (MatchEnd / HandEnd / Confirm) — scale + fade panel.
static func play_dialog_entrance(
	host: Node,
	panel: Control,
	duration: float = DIALOG_ENTRANCE_SEC
) -> Tween:
	if panel == null or not is_instance_valid(panel):
		return null
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.86, 0.86)
	panel.modulate.a = 0.0
	var tween: Tween = host.create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, duration * 0.75) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
