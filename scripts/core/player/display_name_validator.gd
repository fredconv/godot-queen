class_name DisplayNameValidator
extends RefCounted
## Validation et assainissement du pseudo affiché (solo et futur multijoueur).

const MIN_LENGTH: int = 2
const MAX_LENGTH: int = 16
const FALLBACK_NAME: String = "Joueur"

const _FORBIDDEN_CHARS: Array[String] = [
	"<", ">", "&", "\"", "'", "\\", "/", "{", "}", "[", "]", "|", "`", "\n", "\r", "\t",
]


static func sanitize(raw: String) -> String:
	return raw.strip_edges()


static func is_valid(raw: String) -> bool:
	var name := sanitize(raw)
	if name.length() < MIN_LENGTH or name.length() > MAX_LENGTH:
		return false
	for forbidden in _FORBIDDEN_CHARS:
		if name.contains(forbidden):
			return false
	return true


## Retourne le pseudo validé ou le fallback si invalide.
static func validate_or_fallback(raw: String) -> String:
	var name := sanitize(raw)
	if is_valid(name):
		return name
	return FALLBACK_NAME
