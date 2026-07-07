class_name ModalOverlayScreen
extends Control
## Base des écrans modaux plein écran (menu overlays). Gère visibilité, fermeture et Échap.


signal closed


func _ready() -> void:
	visible = false


func open() -> void:
	_before_open()
	show()
	call_deferred("_on_overlay_opened")


func close() -> void:
	hide()
	closed.emit()


func _before_open() -> void:
	pass


func _on_overlay_opened() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if UiFocusNav.is_cancel_pressed(event):
		close()
		get_viewport().set_input_as_handled()
