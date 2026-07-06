class_name GameSaveStore
extends RefCounted
## Format versionné de sauvegarde locale et migrations depuis l'ancien format.

const CURRENT_VERSION: int = 1
const KEY_VERSION: String = "version"
const KEY_PLAYER_PROFILE: String = "player_profile"
const KEY_SETTINGS: String = "settings"
const KEY_STATS: String = "stats"
const KEY_SCORE_HISTORY: String = "score_history"

## Clé historique (v0) encore lue lors de la migration.
const LEGACY_CONFIG_KEY: String = "config"


static func default_document() -> Dictionary:
	return normalize({})


static func normalize(raw: Variant) -> Dictionary:
	var data: Dictionary = {}
	if raw is Dictionary:
		data = _migrate_legacy(raw.duplicate())
	else:
		data = {}

	var version: int = int(data.get(KEY_VERSION, 0))
	if version < CURRENT_VERSION:
		data = _migrate_to_current(data, version)

	data[KEY_VERSION] = CURRENT_VERSION
	data[KEY_PLAYER_PROFILE] = LocalPlayerProfile.normalize(data.get(KEY_PLAYER_PROFILE, {}))
	data[KEY_SETTINGS] = _normalize_settings(data.get(KEY_SETTINGS, {}))
	data[KEY_STATS] = StatsStore.normalize(data.get(KEY_STATS, {}))
	data[KEY_SCORE_HISTORY] = _normalize_score_history(data.get(KEY_SCORE_HISTORY, []))
	return data


static func _migrate_legacy(raw: Dictionary) -> Dictionary:
	if raw.has(KEY_VERSION):
		return raw
	var migrated := raw.duplicate()
	if raw.has(LEGACY_CONFIG_KEY) and not raw.has(KEY_SETTINGS):
		migrated[KEY_SETTINGS] = raw[LEGACY_CONFIG_KEY].duplicate()
		migrated.erase(LEGACY_CONFIG_KEY)
	if not migrated.has(KEY_PLAYER_PROFILE):
		migrated[KEY_PLAYER_PROFILE] = LocalPlayerProfile.create_new()
	if not migrated.has(KEY_SCORE_HISTORY):
		migrated[KEY_SCORE_HISTORY] = []
	migrated[KEY_VERSION] = 0
	return migrated


static func _migrate_to_current(data: Dictionary, from_version: int) -> Dictionary:
	var next := data.duplicate()
	if from_version < 1:
		next[KEY_STATS] = StatsStore.normalize(next.get(KEY_STATS, {}))
		if not next.has(KEY_PLAYER_PROFILE):
			next[KEY_PLAYER_PROFILE] = LocalPlayerProfile.create_new()
		if not next.has(KEY_SCORE_HISTORY):
			next[KEY_SCORE_HISTORY] = []
	next[KEY_VERSION] = CURRENT_VERSION
	return next


static func _normalize_settings(raw: Variant) -> Dictionary:
	if raw is not Dictionary:
		raw = {}
	return {
		"sfx_volume": clampf(float(raw.get("sfx_volume", ConfigService.DEFAULT_SFX_VOLUME)), 0.0, 1.0),
		"music_volume": clampf(float(raw.get("music_volume", ConfigService.DEFAULT_MUSIC_VOLUME)), 0.0, 1.0),
		"music_enabled": bool(raw.get("music_enabled", ConfigService.DEFAULT_MUSIC_ENABLED)),
		"language": ConfigService.normalize_language(str(raw.get("language", ConfigService.DEFAULT_LANGUAGE))),
		"table_theme": str(TableThemePaths.normalize_theme_id(raw.get("table_theme", ConfigService.DEFAULT_TABLE_THEME))),
	}


static func _normalize_score_history(raw: Variant) -> Array:
	if raw is not Array:
		return []
	var history: Array = []
	for entry in raw:
		if entry is Dictionary:
			history.append(entry.duplicate())
	return history
