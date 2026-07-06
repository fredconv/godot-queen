extends Node
## PlayerProfileService (autoload)
## Identité locale du joueur humain : pseudo, player_id stable, avatar.
## Le pseudo est proposé par défaut en solo et futur lobby multijoueur.

signal profile_changed

var _profile: Dictionary = LocalPlayerProfile.create_new()
var _loaded: bool = false


func _ready() -> void:
	_ensure_loaded()


func needs_setup() -> bool:
	_ensure_loaded()
	return LocalPlayerProfile.needs_setup(_profile)


func get_player_id() -> String:
	_ensure_loaded()
	return str(_profile[LocalPlayerProfile.KEY_PLAYER_ID])


func get_display_name() -> String:
	_ensure_loaded()
	return LocalPlayerProfile.get_display_name(_profile)


func get_avatar_id() -> String:
	_ensure_loaded()
	return str(_profile[LocalPlayerProfile.KEY_AVATAR_ID])


func get_profile() -> Dictionary:
	_ensure_loaded()
	return _profile.duplicate()


func set_display_name(raw_name: String) -> String:
	_ensure_loaded()
	_profile = LocalPlayerProfile.set_display_name(_profile, raw_name)
	_save_profile()
	profile_changed.emit()
	return get_display_name()


func touch_last_used() -> void:
	_ensure_loaded()
	_profile = LocalPlayerProfile.touch_last_used(_profile)
	_save_profile()


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var data: Dictionary = SaveService.load_document()
	_profile = LocalPlayerProfile.normalize(data.get(GameSaveStore.KEY_PLAYER_PROFILE, {}))


func _save_profile() -> void:
	var data: Dictionary = SaveService.load_document()
	data[GameSaveStore.KEY_PLAYER_PROFILE] = _profile.duplicate()
	if not SaveService.save_document(data):
		DebugService.log_warning("PlayerProfileService: échec de sauvegarde du profil")
