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

var _desc_solo: Label
var _desc_hot_seat: Label
var _desc_online: Label
var _back_separator: ColorRect


func _ready() -> void:
	super._ready()
	_ensure_mode_descriptions()
	_ensure_back_separator()
	_apply_mode_button_chrome()
	UiFocusNav.chain_vertical([_btn_solo, _btn_hot_seat, _btn_online, _btn_back])
	LocaleAware.bind(self, _refresh_locale)
	UiThemeCatalog.apply_variation(_title_label, UiThemeCatalog.V_TITLE_LABEL)


func _apply_mode_button_chrome() -> void:
	const FILL := Color(0.05, 0.16, 0.09, 1.0)
	for button: NinePatchButton in [_btn_solo, _btn_hot_seat, _btn_online, _btn_back]:
		if button == null:
			continue
		button.ensure_opaque_background(FILL, UiPalette.GOLD, 0)
	if _btn_back != null:
		_btn_back.ensure_opaque_background(Color(0.07, 0.09, 0.1, 1.0), UiPalette.GOLD, 0)


func _ensure_mode_descriptions() -> void:
	var vbox: VBoxContainer = $Panel/Margin/VBox as VBoxContainer
	if vbox == null:
		return
	_desc_solo = _insert_desc_after(_btn_solo, "DescSolo")
	_desc_hot_seat = _insert_desc_after(_btn_hot_seat, "DescHotSeat")
	_desc_online = _insert_desc_after(_btn_online, "DescOnline")
	vbox.add_theme_constant_override("separation", 10)
	## Panel un peu plus haut pour descriptions.
	var panel: Control = $Panel as Control
	if panel != null:
		panel.offset_top = -200.0
		panel.offset_bottom = 200.0
	_ensure_title_rules(vbox)


func _ensure_title_rules(vbox: VBoxContainer) -> void:
	if vbox.get_node_or_null("TitleRuleTop") != null:
		return
	var rule_top := ColorRect.new()
	rule_top.name = "TitleRuleTop"
	rule_top.custom_minimum_size = Vector2(0, 2)
	rule_top.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.6)
	rule_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rule_bottom := ColorRect.new()
	rule_bottom.name = "TitleRuleBottom"
	rule_bottom.custom_minimum_size = Vector2(0, 2)
	rule_bottom.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.6)
	rule_bottom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(rule_top)
	vbox.move_child(rule_top, _title_label.get_index())
	vbox.add_child(rule_bottom)
	vbox.move_child(rule_bottom, _title_label.get_index() + 1)


func _insert_desc_after(button: Control, node_name: String) -> Label:
	var parent: Node = button.get_parent()
	var existing: Node = parent.get_node_or_null(node_name)
	if existing is Label:
		return existing as Label
	var label := Label.new()
	label.name = node_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeCatalog.apply_variation(label, UiThemeCatalog.V_MUTED_LABEL)
	label.add_theme_font_size_override("font_size", UiPalette.MENU_SUBTITLE_SIZE)
	label.add_theme_color_override("font_color", UiPalette.MUTED)
	parent.add_child(label)
	parent.move_child(label, button.get_index() + 1)
	return label


func _ensure_back_separator() -> void:
	var parent: Node = _btn_back.get_parent()
	if parent.get_node_or_null("BackSeparator") != null:
		_back_separator = parent.get_node("BackSeparator") as ColorRect
		return
	_back_separator = ColorRect.new()
	_back_separator.name = "BackSeparator"
	_back_separator.custom_minimum_size = Vector2(0, 2)
	_back_separator.color = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.45)
	_back_separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(_back_separator)
	parent.move_child(_back_separator, _btn_back.get_index())


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
	var mode_buttons: Array = [_btn_solo, _btn_hot_seat, _btn_online, _btn_back]
	NinePatchButton.uniform_fit_group(mode_buttons)
	NinePatchButton.sync_centered_panel_half_width($Panel as Control, mode_buttons, 48.0, 240.0)
	if _desc_solo != null:
		_desc_solo.text = tr(MenuKeys.GAME_MODE_SOLO_DESC)
	if _desc_hot_seat != null:
		_desc_hot_seat.text = tr(MenuKeys.GAME_MODE_HOT_SEAT_DESC)
	if _desc_online != null:
		_desc_online.text = tr(MenuKeys.GAME_MODE_ONLINE_DESC)


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
