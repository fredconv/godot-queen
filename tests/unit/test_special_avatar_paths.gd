class_name SpecialAvatarPathsTest
extends GdUnitTestSuite


const __source = "res://scripts/core/special_avatar_paths.gd"


#region get_avatar_path
func test_get_avatar_path_maps_character_ids() -> void:
	assert_str(SpecialAvatarPaths.get_avatar_path(0)).contains("avatar_joueur_magenta")
	assert_str(SpecialAvatarPaths.get_avatar_path(1)).contains("avatar_adv1_bleu")
	assert_str(SpecialAvatarPaths.get_avatar_path(2)).contains("avatar_adv2_or")
	assert_str(SpecialAvatarPaths.get_avatar_path(3)).contains("avatar_adv3_vert")


func test_get_avatar_path_clamps_out_of_range_ids() -> void:
	assert_str(SpecialAvatarPaths.get_avatar_path(-2)).is_equal(SpecialAvatarPaths.get_avatar_path(0))
	assert_str(SpecialAvatarPaths.get_avatar_path(99)).is_equal(SpecialAvatarPaths.get_avatar_path(3))
#endregion
