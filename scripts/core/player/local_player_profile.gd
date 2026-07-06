class_name LocalPlayerProfile
extends RefCounted
## Profil joueur local persisté (identité stable + pseudo affiché).

const KEY_PLAYER_ID: String = "player_id"
const KEY_DISPLAY_NAME: String = "display_name"
const KEY_AVATAR_ID: String = "avatar_id"
const KEY_CREATED_AT: String = "created_at"
const KEY_LAST_USED_AT: String = "last_used_at"
const KEY_AUTH_PROVIDER: String = "auth_provider"
const KEY_EXTERNAL_ACCOUNT_ID: String = "external_account_id"
const KEY_EMAIL: String = "email"
const KEY_EMAIL_VERIFIED: String = "email_verified"
const KEY_NEWSLETTER_OPT_IN: String = "newsletter_opt_in"
const KEY_MARKETING_CONSENT_AT: String = "marketing_consent_at"
const KEY_PRIVACY_POLICY_VERSION: String = "privacy_policy_version"
const KEY_TERMS_VERSION: String = "terms_version"

const DEFAULT_AVATAR_ID: String = "default"
const DEFAULT_AUTH_PROVIDER: StringName = &"local"


static func create_new(player_id: String = "") -> Dictionary:
	var now := _iso_timestamp()
	return normalize({
		KEY_PLAYER_ID: player_id if not player_id.is_empty() else generate_player_id(),
		KEY_DISPLAY_NAME: "",
		KEY_AVATAR_ID: DEFAULT_AVATAR_ID,
		KEY_CREATED_AT: now,
		KEY_LAST_USED_AT: now,
		KEY_AUTH_PROVIDER: DEFAULT_AUTH_PROVIDER,
		KEY_EXTERNAL_ACCOUNT_ID: "",
		KEY_EMAIL: "",
		KEY_EMAIL_VERIFIED: false,
		KEY_NEWSLETTER_OPT_IN: false,
		KEY_MARKETING_CONSENT_AT: "",
		KEY_PRIVACY_POLICY_VERSION: "",
		KEY_TERMS_VERSION: "",
	})


static func normalize(raw: Variant) -> Dictionary:
	if raw is not Dictionary:
		return create_new()
	var profile: Dictionary = raw.duplicate()
	if not profile.has(KEY_PLAYER_ID) or str(profile.get(KEY_PLAYER_ID, "")).is_empty():
		profile[KEY_PLAYER_ID] = generate_player_id()
	profile[KEY_DISPLAY_NAME] = str(profile.get(KEY_DISPLAY_NAME, ""))
	profile[KEY_AVATAR_ID] = str(profile.get(KEY_AVATAR_ID, DEFAULT_AVATAR_ID))
	if profile[KEY_AVATAR_ID].is_empty():
		profile[KEY_AVATAR_ID] = DEFAULT_AVATAR_ID
	profile[KEY_CREATED_AT] = str(profile.get(KEY_CREATED_AT, _iso_timestamp()))
	profile[KEY_LAST_USED_AT] = str(profile.get(KEY_LAST_USED_AT, profile[KEY_CREATED_AT]))
	profile[KEY_AUTH_PROVIDER] = StringName(str(profile.get(KEY_AUTH_PROVIDER, DEFAULT_AUTH_PROVIDER)))
	profile[KEY_EXTERNAL_ACCOUNT_ID] = str(profile.get(KEY_EXTERNAL_ACCOUNT_ID, ""))
	profile[KEY_EMAIL] = str(profile.get(KEY_EMAIL, ""))
	profile[KEY_EMAIL_VERIFIED] = bool(profile.get(KEY_EMAIL_VERIFIED, false))
	profile[KEY_NEWSLETTER_OPT_IN] = bool(profile.get(KEY_NEWSLETTER_OPT_IN, false))
	profile[KEY_MARKETING_CONSENT_AT] = str(profile.get(KEY_MARKETING_CONSENT_AT, ""))
	profile[KEY_PRIVACY_POLICY_VERSION] = str(profile.get(KEY_PRIVACY_POLICY_VERSION, ""))
	profile[KEY_TERMS_VERSION] = str(profile.get(KEY_TERMS_VERSION, ""))
	return profile


static func needs_setup(profile: Dictionary) -> bool:
	return normalize(profile).get(KEY_DISPLAY_NAME, "").is_empty()


static func get_display_name(profile: Dictionary) -> String:
	var name: String = normalize(profile).get(KEY_DISPLAY_NAME, "")
	if name.is_empty():
		return DisplayNameValidator.FALLBACK_NAME
	return name


static func set_display_name(profile: Dictionary, raw_name: String) -> Dictionary:
	var next := normalize(profile).duplicate()
	next[KEY_DISPLAY_NAME] = DisplayNameValidator.validate_or_fallback(raw_name)
	next[KEY_LAST_USED_AT] = _iso_timestamp()
	return next


static func touch_last_used(profile: Dictionary) -> Dictionary:
	var next := normalize(profile).duplicate()
	next[KEY_LAST_USED_AT] = _iso_timestamp()
	return next


static func generate_player_id() -> String:
	return "local_%d_%d" % [Time.get_unix_time_from_system(), randi()]


static func _iso_timestamp() -> String:
	return Time.get_datetime_string_from_system(true)
