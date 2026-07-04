extends Node
## SaveService (autoload)
## Stub de persistance locale (user://). La sérialisation réelle sera ajoutée
## quand le format de sauvegarde (profil, options, stats) sera défini.

const SAVE_PATH: String = "user://savegame.json"

func save_data(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveService: impossible d'ouvrir %s en écriture" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveService: impossible d'ouvrir %s en lecture" % SAVE_PATH)
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	return parsed if parsed is Dictionary else {}
