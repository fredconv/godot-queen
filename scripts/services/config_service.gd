extends Node
## ConfigService (autoload)
## Configuration utilisateur : volume des effets sonores, volume et activation
## de la musique d'ambiance, langue. Persistée via `SaveService` (fichier
## `user://savegame.json`, sous la clé `"config"`) et chargée paresseusement
## (voir `_ensure_loaded()`). `ConfigService` est déclaré avant `AudioService`
## dans l'ordre des autoloads (`project.godot`), qui lit `ConfigService` dès
## son propre `_ready()` ; le chargement paresseux reste conservé en filet de
## sécurité, pour ne pas dépendre strictement de cet ordre
## (voir docs/DECISIONS.md ADR-013).

## Volume par défaut des effets sonores (0-1) : pleine puissance, ce sont des
## sons courts et peu fréquents.
const DEFAULT_SFX_VOLUME: float = 1.0
## Volume par défaut de la musique d'ambiance (0-1) : nettement plus bas que
## les SFX pour que les sons de carte restent audibles par-dessus (ADR-013).
const DEFAULT_MUSIC_VOLUME: float = 0.35
const DEFAULT_MUSIC_ENABLED: bool = true
const DEFAULT_LANGUAGE: String = "fr"
const DEFAULT_TABLE_THEME: StringName = TableThemePaths.THEME_CLASSIC
const SUPPORTED_LANGUAGES: Array[String] = ["fr", "en"]

signal locale_changed(locale: String)

var _sfx_volume: float = DEFAULT_SFX_VOLUME
var _music_volume: float = DEFAULT_MUSIC_VOLUME
var _music_enabled: bool = DEFAULT_MUSIC_ENABLED
var _language: String = DEFAULT_LANGUAGE
var _table_theme: StringName = DEFAULT_TABLE_THEME
var _loaded: bool = false

func _ready() -> void:
	_ensure_loaded()

## --- Volume des effets sonores (nom historique `volume` conservé pour compatibilité) ---

func get_volume() -> float:
	_ensure_loaded()
	return _sfx_volume

func set_volume(value: float) -> void:
	_ensure_loaded()
	_sfx_volume = clampf(value, 0.0, 1.0)
	_save_config()

## --- Volume de la musique d'ambiance ---

func get_music_volume() -> float:
	_ensure_loaded()
	return _music_volume

func set_music_volume(value: float) -> void:
	_ensure_loaded()
	_music_volume = clampf(value, 0.0, 1.0)
	_save_config()

## --- Activation de la musique d'ambiance ---

func get_music_enabled() -> bool:
	_ensure_loaded()
	return _music_enabled

func set_music_enabled(value: bool) -> void:
	_ensure_loaded()
	_music_enabled = value
	_save_config()

## --- Langue ---

func get_language() -> String:
	_ensure_loaded()
	return _language

func set_language(value: String) -> void:
	_ensure_loaded()
	var normalized: String = normalize_language(value)
	if _language == normalized:
		return
	_language = normalized
	_save_config()
	_apply_locale()


static func normalize_language(value: String) -> String:
	return "en" if value == "en" else "fr"

## --- Thème visuel de la table ---

func get_table_theme() -> StringName:
	_ensure_loaded()
	return _table_theme


func set_table_theme(value: StringName) -> void:
	_ensure_loaded()
	_table_theme = TableThemePaths.normalize_theme_id(value)
	_save_config()

## --- Persistance ---

## Charge la configuration une seule fois, à la première utilisation (getter,
## setter ou `_ready()`, selon ce qui arrive en premier).
func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var data: Dictionary = SaveService.load_data()
	var config: Dictionary = data.get("config", {})
	_sfx_volume = config.get("sfx_volume", DEFAULT_SFX_VOLUME)
	_music_volume = config.get("music_volume", DEFAULT_MUSIC_VOLUME)
	_music_enabled = config.get("music_enabled", DEFAULT_MUSIC_ENABLED)
	_language = normalize_language(config.get("language", DEFAULT_LANGUAGE))
	_table_theme = TableThemePaths.normalize_theme_id(config.get("table_theme", DEFAULT_TABLE_THEME))
	_apply_locale()


func _apply_locale() -> void:
	TranslationServer.set_locale(_language)
	locale_changed.emit(_language)

func _save_config() -> void:
	var data: Dictionary = SaveService.load_data()
	data["config"] = {
		"sfx_volume": _sfx_volume,
		"music_volume": _music_volume,
		"music_enabled": _music_enabled,
		"language": _language,
		"table_theme": _table_theme,
	}
	SaveService.save_data(data)
