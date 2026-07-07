extends ModalOverlayScreen
## Écran Scores : statistiques persistées du joueur humain.
## Overlay modal réutilisable depuis le menu principal et la table.

@onready var _title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var _summary_label: Label = $Panel/Margin/VBox/SummaryLabel
@onready var _empty_label: Label = $Panel/Margin/VBox/EmptyLabel
@onready var _btn_back: NinePatchButton = $Panel/Margin/VBox/BtnBack


func _ready() -> void:
	super._ready()
	UiFocusNav.chain_vertical([_btn_back])
	LocaleAware.bind(self, _refresh_locale)


func _before_open() -> void:
	_refresh_locale()


func _on_overlay_opened() -> void:
	_btn_back.grab_focus()


func _refresh_locale() -> void:
	_title_label.text = tr(MenuKeys.SCORES_TITLE)
	_btn_back.set_button_text(tr(CommonKeys.BACK))
	_empty_label.text = tr(MenuKeys.SCORES_EMPTY)
	_refresh_display()


func _refresh_display() -> void:
	var stats: Dictionary = StatsService.get_stats()
	var played: int = stats[StatsStore.KEY_MATCHES_PLAYED]
	var won: int = stats[StatsStore.KEY_MATCHES_WON]
	var lost: int = stats[StatsStore.KEY_MATCHES_LOST]
	var win_rate: int = StatsService.get_win_rate_percent()

	_empty_label.visible = played == 0
	_summary_label.visible = played > 0
	if played == 0:
		return

	_summary_label.text = (
		tr(MenuKeys.SCORES_MATCHES) % played
		+ "\n"
		+ tr(MenuKeys.SCORES_WINS) % won
		+ "\n"
		+ tr(MenuKeys.SCORES_LOSSES) % lost
		+ "\n"
		+ tr(MenuKeys.SCORES_WIN_RATE) % win_rate
	)


func _on_btn_back_pressed() -> void:
	close()
