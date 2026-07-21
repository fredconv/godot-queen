extends ModalOverlayScreen
## Écran Aide : règles essentielles du jeu. Overlay modal réutilisable.

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _body_label: RichTextLabel = $Panel/Margin/VBox/ScrollContainer/BodyLabel
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	_ensure_title_emblem()
	_body_label.bbcode_enabled = true
	_body_label.add_theme_color_override("default_color", Color(0.961, 0.941, 0.902, 1.0))
	UiFocusNav.chain_vertical([_btn_back])
	_btn_back.set_button_icon(UiIconCatalog.texture(UiIconCatalog.Icon.EXIT), 30)
	LocaleAware.bind(self, _refresh_locale)


func _ensure_title_emblem() -> void:
	var vbox := $Panel/Margin/VBox as VBoxContainer
	var emblem := UiIconCatalog.make_icon_rect(UiIconCatalog.Icon.RULES, Vector2i(52, 52))
	emblem.name = "RulesEmblem"
	vbox.add_child(emblem)
	vbox.move_child(emblem, _title_label.get_index())


func _before_open() -> void:
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_back.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(TableKeys.HELP_TITLE)
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	var body: String = TableCopy.help_rules_body()
	# Les traductions utilisent déjà [b] pour les sections : leur ajouter la
	# couleur d'accent renforce la hiérarchie sans dupliquer le contenu.
	body = body.replace("[b]", "[color=#D4AF37][b]")
	body = body.replace("[/b]", "[/b][/color]")
	_body_label.text = body


func _on_btn_back_pressed() -> void:
	close()
