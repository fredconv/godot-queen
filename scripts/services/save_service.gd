extends Node
## SaveService (autoload)
## Persistance locale versionnée (`user://savegame.json`). Migration automatique,
## valeurs par défaut pour clés manquantes, backup si JSON corrompu.

const SAVE_PATH: String = "user://savegame.json"
const BACKUP_SUFFIX: String = ".corrupt.bak"

var _document: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_ensure_loaded()


func load_document() -> Dictionary:
	_ensure_loaded()
	return _document.duplicate(true)


func save_document(data: Dictionary) -> bool:
	_document = GameSaveStore.normalize(data)
	_loaded = true
	return _write_file(_document)


func load_data() -> Dictionary:
	return load_document()


func save_data(data: Dictionary) -> bool:
	return save_document(data)


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_document = _read_and_normalize()


func _read_and_normalize() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return GameSaveStore.default_document()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		DebugService.log_warning("SaveService: impossible d'ouvrir %s en lecture" % SAVE_PATH)
		return GameSaveStore.default_document()
	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		return GameSaveStore.normalize(parsed)
	_backup_corrupt_file(content)
	DebugService.log_warning("SaveService: JSON corrompu, backup créé et config par défaut utilisée")
	return GameSaveStore.default_document()


func _write_file(data: Dictionary) -> bool:
	var normalized := GameSaveStore.normalize(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		DebugService.log_error("SaveService: impossible d'ouvrir %s en écriture" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(normalized, "\t"))
	file.close()
	return true


func _backup_corrupt_file(content: String) -> void:
	var backup_path := SAVE_PATH + BACKUP_SUFFIX
	var backup := FileAccess.open(backup_path, FileAccess.WRITE)
	if backup == null:
		DebugService.log_warning("SaveService: impossible de créer le backup %s" % backup_path)
		return
	backup.store_string(content)
	backup.close()
