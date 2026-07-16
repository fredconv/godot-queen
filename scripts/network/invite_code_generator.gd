class_name InviteCodeGenerator
extends RefCounted
## Génère des codes d'invitation lisibles (format XXXX-XXXX).


const CHARSET: String = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const CODE_LENGTH: int = 8


static func generate() -> String:
	var raw: String = ""
	for _index in CODE_LENGTH:
		raw += CHARSET[randi() % CHARSET.length()]
	return format_code(raw)


static func format_code(raw: String) -> String:
	var cleaned: String = normalize_raw(raw)
	if cleaned.length() != CODE_LENGTH:
		return cleaned
	return "%s-%s" % [cleaned.substr(0, 4), cleaned.substr(4, 4)]


static func normalize_input(raw: String) -> String:
	var cleaned: String = normalize_raw(raw)
	if cleaned.length() != CODE_LENGTH:
		return ""
	return format_code(cleaned)


static func is_valid(raw: String) -> bool:
	return normalize_raw(raw).length() == CODE_LENGTH


static func normalize_raw(raw: String) -> String:
	var cleaned: String = ""
	for character: String in raw.strip_edges().to_upper():
		if character == "-":
			continue
		if CHARSET.find(character) >= 0:
			cleaned += character
	return cleaned
