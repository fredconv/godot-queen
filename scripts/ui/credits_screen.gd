extends Control
## Écran Crédits : attributions (sons, assets…). Overlay modal du menu principal.

signal closed

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _body_label: RichTextLabel = $Panel/Margin/VBox/ScrollContainer/BodyLabel
@onready var _btn_back: Button = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	visible = false
	_body_label.add_theme_color_override("default_color", Color(0.961, 0.941, 0.902, 1.0))
	_body_label.add_theme_color_override("font_link_color", Color(0.55, 0.82, 1.0, 1.0))
	_body_label.meta_clicked.connect(_on_meta_clicked)
	UiFocusNav.chain_vertical([_btn_back])
	LocaleAware.bind(self, _refresh_locale)


func open() -> void:
	_refresh_locale()
	show()
	call_deferred("_btn_back.grab_focus")


func close() -> void:
	hide()
	closed.emit()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.CREDITS_TITLE)
	_btn_back.text = tr(CommonKeys.BACK)
	_body_label.text = MenuCopy.credits_sfx_attribution_bbcode()


func _on_meta_clicked(meta: Variant) -> void:
	var url: String = str(meta)
	if url.begins_with("http://") or url.begins_with("https://"):
		OS.shell_open(url)


func _on_btn_back_pressed() -> void:
	close()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if UiFocusNav.is_cancel_pressed(event):
		close()
		get_viewport().set_input_as_handled()
