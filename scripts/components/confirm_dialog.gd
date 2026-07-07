extends Control
## ConfirmDialog
## Boîte de dialogue générique de confirmation (Oui/Non), utilisée pour
## confirmer une action destructrice (ex. quitter une partie en cours, voir
## `scripts/ui/table.gd`). Masquée par défaut, affichée via `open()`.
## Purement visuel : aucune règle de jeu, aucune décision métier ici.

signal confirmed
signal cancelled

@onready var _message_label: Label = $Panel/Content/MessageLabel
@onready var _btn_yes: Button = $Panel/Content/Buttons/BtnConfirmYes
@onready var _btn_no: Button = $Panel/Content/Buttons/BtnConfirmNo


func _ready() -> void:
	LocaleAware.bind(self, refresh_locale)
	UiFocusNav.chain_horizontal([_btn_yes, _btn_no])
	refresh_locale()


func open(message: String = "") -> void:
	if message != "":
		_message_label.text = message
	visible = true
	UiFocusNav.grab_first([_btn_no, _btn_yes])


func close() -> void:
	visible = false


func refresh_locale() -> void:
	_btn_yes.text = tr(CommonKeys.YES)
	_btn_no.text = tr(CommonKeys.NO)


func _on_btn_confirm_yes_pressed() -> void:
	close()
	confirmed.emit()


func _on_btn_confirm_no_pressed() -> void:
	close()
	cancelled.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if UiFocusNav.is_cancel_pressed(event):
		_on_btn_confirm_no_pressed()
		get_viewport().set_input_as_handled()
