extends ModalOverlayScreen
## Écran Crédits : attributions (sons, assets…). Overlay modal du menu principal.

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _body_label: RichTextLabel = $Panel/Margin/VBox/ScrollContainer/BodyLabel
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	_ensure_title_emblem()
	_body_label.add_theme_color_override("default_color", Color(0.961, 0.941, 0.902, 1.0))
	_body_label.add_theme_color_override("font_link_color", Color(0.55, 0.82, 1.0, 1.0))
	_body_label.meta_clicked.connect(_on_meta_clicked)
	UiFocusNav.chain_vertical([_btn_back])
	_btn_back.set_button_icon(UiIconCatalog.texture(UiIconCatalog.Icon.EXIT), 30)
	LocaleAware.bind(self, _refresh_locale)


func _ensure_title_emblem() -> void:
	var vbox := $Panel/Margin/VBox as VBoxContainer
	var emblem := UiIconCatalog.make_icon_rect(UiIconCatalog.Icon.CREDITS, Vector2i(52, 52))
	emblem.name = "CreditsEmblem"
	vbox.add_child(emblem)
	vbox.move_child(emblem, _title_label.get_index())


func _before_open() -> void:
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_back.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.CREDITS_TITLE)
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	_body_label.text = MenuCopy.credits_sfx_attribution_bbcode()


func _on_meta_clicked(meta: Variant) -> void:
	var url: String = str(meta)
	if url.begins_with("http://") or url.begins_with("https://"):
		OS.shell_open(url)


func _on_btn_back_pressed() -> void:
	close()
