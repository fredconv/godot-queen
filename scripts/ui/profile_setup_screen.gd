extends Control
## Écran de saisie du pseudo au premier lancement.

signal completed

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _hint_label: Label = $Panel/Margin/VBox/HintLabel
@onready var _name_edit: LineEdit = $Panel/Margin/VBox/NameEdit
@onready var _error_label: Label = $Panel/Margin/VBox/ErrorLabel
@onready var _btn_confirm: Button = $Panel/Margin/VBox/BtnConfirm


func _ready() -> void:
	visible = false
	_error_label.visible = false
	LocaleAware.bind(self, _refresh_locale)


func open() -> void:
	_name_edit.text = ""
	_error_label.visible = false
	_refresh_locale()
	show()
	_name_edit.call_deferred("grab_focus")


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.PROFILE_SETUP_TITLE)
	_hint_label.text = tr(MenuKeys.PROFILE_SETUP_HINT)
	_name_edit.placeholder_text = tr(MenuKeys.PROFILE_SETUP_PLACEHOLDER)
	_btn_confirm.text = tr(MenuKeys.PROFILE_SETUP_CONFIRM)


func _on_btn_confirm_pressed() -> void:
	var raw_name: String = _name_edit.text
	if not DisplayNameValidator.is_valid(raw_name):
		_error_label.text = tr(MenuKeys.PROFILE_SETUP_INVALID)
		_error_label.visible = true
		return
	PlayerProfileService.set_display_name(raw_name)
	hide()
	completed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_btn_confirm_pressed()
		get_viewport().set_input_as_handled()
