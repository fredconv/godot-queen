class_name LocaleCatalog
extends RefCounted
## Catalogue des langues supportées. Ordre = affichage dans le sélecteur
## Configuration (voir `settings_screen.gd`).

const FALLBACK_LOCALE: String = "fr"

const LOCALES: Array[String] = ["fr", "en", "de", "es", "pt", "zh"]


static func is_supported(locale: String) -> bool:
	return locale in LOCALES


static func normalize(locale: String) -> String:
	return locale if is_supported(locale) else FALLBACK_LOCALE


static func label_key_for(locale: String) -> String:
	match locale:
		"en":
			return MenuKeys.SETTINGS_LANG_EN
		"de":
			return MenuKeys.SETTINGS_LANG_DE
		"es":
			return MenuKeys.SETTINGS_LANG_ES
		"pt":
			return MenuKeys.SETTINGS_LANG_PT
		"zh":
			return MenuKeys.SETTINGS_LANG_ZH
		_:
			return MenuKeys.SETTINGS_LANG_FR
