class_name TestMainMenuScene
extends GdUnitTestSuite
## Smoke test de la scène menu principal : structure UI et boutons NinePatch.


const MAIN_MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"


#region structure
func test_main_menu_loads_with_five_nine_patch_buttons() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	await runner.simulate_frames(2)

	var buttons: Array[Node] = [
		runner.find_child("BtnNewGame", true, false),
		runner.find_child("BtnScores", true, false),
		runner.find_child("BtnSettings", true, false),
		runner.find_child("BtnCredits", true, false),
		runner.find_child("BtnQuit", true, false),
	]
	for button in buttons:
		assert_object(button).is_not_null()
		assert_that(button).is_instanceof(NinePatchButton)
#endregion


#region overlays
func test_settings_overlay_opens_and_closes() -> void:
	var runner := scene_runner(MAIN_MENU_SCENE)
	await runner.simulate_frames(2)

	var settings: Node = runner.find_child("SettingsScreen", true, false)
	assert_object(settings).is_not_null()

	settings.call("open")
	await runner.simulate_frames(1)
	assert_bool(settings.visible).is_true()

	var btn_back: Node = runner.find_child("BtnBack", true, false)
	assert_object(btn_back).is_not_null()
	(btn_back as BaseButton).pressed.emit()
	await runner.simulate_frames(1)
	assert_bool(settings.visible).is_false()
#endregion
