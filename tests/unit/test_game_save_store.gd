class_name GameSaveStoreTest
extends GdUnitTestSuite


const __source = "res://scripts/core/save/game_save_store.gd"


#region default_document
func test_default_document_has_version_one() -> void:
	var doc := GameSaveStore.default_document()
	assert_int(doc[GameSaveStore.KEY_VERSION]).is_equal(GameSaveStore.CURRENT_VERSION)
	assert_dict(doc[GameSaveStore.KEY_PLAYER_PROFILE]).is_not_empty()
	assert_dict(doc[GameSaveStore.KEY_SETTINGS]).is_not_empty()
	assert_dict(doc[GameSaveStore.KEY_STATS]).is_not_empty()
#endregion


#region migrate_legacy
func test_migrate_legacy_config_to_settings() -> void:
	var legacy := {
		"config": {
			"language": "en",
			"sfx_volume": 0.5,
		},
		"stats": {"matches_played": 2},
	}
	var doc := GameSaveStore.normalize(legacy)
	assert_int(doc[GameSaveStore.KEY_VERSION]).is_equal(1)
	assert_str(doc[GameSaveStore.KEY_SETTINGS]["language"]).is_equal("en")
	assert_int(doc[GameSaveStore.KEY_STATS][StatsStore.KEY_MATCHES_PLAYED]).is_equal(2)
#endregion


#region missing_keys
func test_normalize_fills_missing_keys() -> void:
	var doc := GameSaveStore.normalize({"version": 1})
	assert_array(doc[GameSaveStore.KEY_SCORE_HISTORY]).has_size(0)
#endregion
