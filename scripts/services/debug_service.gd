extends Node
## DebugService (autoload)
## Point d'entrée unique pour le logging (au lieu de print()). Permet
## d'activer/désactiver les logs de debug sans toucher au reste du code.

@export var debug_enabled: bool = OS.is_debug_build()

func is_debug_enabled() -> bool:
	return debug_enabled

func log_info(message: String) -> void:
	if debug_enabled:
		push_warning("[INFO] %s" % message)

func log_warning(message: String) -> void:
	push_warning("[WARN] %s" % message)

func log_error(message: String) -> void:
	push_error("[ERROR] %s" % message)
