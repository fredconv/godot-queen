extends ModalOverlayScreen
## Lobby multijoueur en ligne (stub phase C : ENet à venir).


@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _info_label: Label = $Panel/Margin/VBox/InfoLabel
@onready var _btn_host: NinePatchButton = $Panel/Margin/VBox/BtnHost
@onready var _btn_join: NinePatchButton = $Panel/Margin/VBox/BtnJoin
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	UiFocusNav.chain_vertical([_btn_host, _btn_join, _btn_back])
	LocaleAware.bind(self, _refresh_locale)


func _before_open() -> void:
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_back.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.MP_TITLE)
	_info_label.text = tr(MenuKeys.MP_COMING_SOON)
	_btn_host.set_button_text(tr(MenuKeys.MP_HOST))
	_btn_join.set_button_text(tr(MenuKeys.MP_JOIN))
	_btn_back.set_button_text(tr(CommonKeys.BACK))


func _on_btn_back_pressed() -> void:
	close()
