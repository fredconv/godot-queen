extends GdUnitTestSuite
## IDEA-00021 Lot L1 — type variations Theme.


func test_enrich_theme_registers_primary_button() -> void:
	var theme := Theme.new()
	UiThemeCatalog.enrich_theme(theme)
	assert_bool(theme.has_stylebox("normal", UiThemeCatalog.V_PRIMARY_BUTTON)).is_true()
	assert_str(theme.get_type_variation_base(UiThemeCatalog.V_PRIMARY_BUTTON)).is_equal("Button")


func test_enrich_theme_idempotent() -> void:
	var theme := Theme.new()
	UiThemeCatalog.enrich_theme(theme)
	UiThemeCatalog.enrich_theme(theme)
	assert_bool(theme.has_meta(&"_ddp_theme_enriched")).is_true()


func test_apply_variation_sets_theme_type() -> void:
	var label := Label.new()
	auto_free(label)
	UiThemeCatalog.apply_variation(label, UiThemeCatalog.V_TITLE_LABEL)
	assert_str(label.theme_type_variation).is_equal("TitleLabel")


func test_danger_and_notification_variations_exist() -> void:
	var theme := Theme.new()
	UiThemeCatalog.enrich_theme(theme)
	assert_bool(theme.has_stylebox("normal", UiThemeCatalog.V_DANGER_BUTTON)).is_true()
	assert_bool(theme.has_stylebox("panel", UiThemeCatalog.V_NOTIFICATION_PANEL)).is_true()
	assert_bool(theme.has_stylebox("slider", UiThemeCatalog.V_PIXEL_SLIDER)).is_true()
