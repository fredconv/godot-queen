extends ModalOverlayScreen
## Choix du mode de jeu : solo, hot seat ou en ligne.


signal solo_selected
signal hot_seat_selected
signal online_selected

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _btn_solo: NinePatchButton = $Panel/Margin/VBox/BtnSolo
@onready var _btn_hot_seat: NinePatchButton = $Panel/Margin/VBox/BtnHotSeat
@onready var _btn_online: NinePatchButton = $Panel/Margin/VBox/BtnOnline
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	UiFocusNav.chain_vertical([_btn_solo, _btn_hot_seat, _btn_online, _btn_back])
	LocaleAware.bind(self, _refresh_locale)


func _before_open() -> void:
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_solo.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.GAME_MODE_TITLE)
	_btn_solo.set_button_text(tr(MenuKeys.GAME_MODE_SOLO))
	_btn_hot_seat.set_button_text(tr(MenuKeys.GAME_MODE_HOT_SEAT))
	_btn_online.set_button_text(tr(MenuKeys.GAME_MODE_ONLINE))
	_btn_back.set_button_text(tr(CommonKeys.BACK))


func _on_btn_solo_pressed() -> void:
	close()
	solo_selected.emit()


func _on_btn_hot_seat_pressed() -> void:
	close()
	hot_seat_selected.emit()


func _on_btn_online_pressed() -> void:
	close()
	online_selected.emit()


func _on_btn_back_pressed() -> void:
	close()
