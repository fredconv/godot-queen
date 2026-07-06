class_name LocalPlayerProfileTest
extends GdUnitTestSuite


const __source = "res://scripts/core/player/local_player_profile.gd"


#region needs_setup
func test_needs_setup_when_display_name_empty() -> void:
	var profile := LocalPlayerProfile.create_new()
	assert_bool(LocalPlayerProfile.needs_setup(profile)).is_true()


func test_needs_setup_false_after_display_name_set() -> void:
	var profile := LocalPlayerProfile.set_display_name(LocalPlayerProfile.create_new(), "Hero")
	assert_bool(LocalPlayerProfile.needs_setup(profile)).is_false()
#endregion


#region get_display_name
func test_get_display_name_fallback_when_empty() -> void:
	assert_str(LocalPlayerProfile.get_display_name(LocalPlayerProfile.create_new())).is_equal("Joueur")
#endregion
