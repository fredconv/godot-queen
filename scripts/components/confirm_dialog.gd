extends Control
## ConfirmDialog
## Boîte de dialogue générique de confirmation (Oui/Non), utilisée pour
## confirmer une action destructrice (ex. quitter une partie en cours, voir
## `scripts/ui/table.gd`). Masquée par défaut, affichée via `open()`.
## Purement visuel : aucune règle de jeu, aucune décision métier ici.

signal confirmed
signal cancelled

@onready var _panel: PanelContainer = $Panel
@onready var _message_label: Label = $Panel/Content/MessageLabel
@onready var _btn_yes: NinePatchButton = $Panel/Content/Buttons/BtnConfirmYes
@onready var _btn_no: NinePatchButton = $Panel/Content/Buttons/BtnConfirmNo

var _entrance_tween: Tween = null


func _ready() -> void:
	LocaleAware.bind(self, refresh_locale)
	UiFocusNav.chain_horizontal([_btn_yes, _btn_no])
	UiStyleFactory.apply_pixel_panel(_panel, UiStyleFactory.pixel_overlay_panel_style(Vector4(20, 16, 20, 16)))
	refresh_locale()


func open(message: String = "") -> void:
	if message != "":
		_message_label.text = message
	visible = true
	_play_entrance()
	UiFocusNav.grab_first([_btn_no, _btn_yes])


func close() -> void:
	UiOffsetAnim.kill_tween(_entrance_tween)
	_entrance_tween = null
	visible = false
	_panel.scale = Vector2.ONE
	_panel.modulate = Color.WHITE


func _play_entrance() -> void:
	UiOffsetAnim.kill_tween(_entrance_tween)
	_entrance_tween = UiOffsetAnim.play_dialog_entrance(self, _panel)


func refresh_locale() -> void:
	_btn_yes.set_button_text(tr(CommonKeys.YES))
	_btn_no.set_button_text(tr(CommonKeys.NO))
	NinePatchButton.uniform_fit_group([_btn_yes, _btn_no])


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
