class_name MultiplayerLobbyInviteCode
extends RefCounted
## Formatage live du champ code d'invitation (IDEA-00010).


const _InviteCodeGenerator = preload("res://scripts/network/invite_code_generator.gd")


static func apply_live_format(invite_code_edit: LineEdit, new_text: String) -> void:
	if invite_code_edit == null:
		return
	var cursor: int = invite_code_edit.caret_column
	var normalized: String = _InviteCodeGenerator.normalize_raw(new_text)
	if normalized.length() <= 4:
		invite_code_edit.text = normalized
	elif normalized.length() <= 8:
		invite_code_edit.text = "%s-%s" % [normalized.substr(0, 4), normalized.substr(4)]
	else:
		invite_code_edit.text = _InviteCodeGenerator.format_code(normalized.substr(0, 8))
	invite_code_edit.caret_column = mini(cursor + 1, invite_code_edit.text.length())


static func normalize_input(raw: String) -> String:
	return _InviteCodeGenerator.normalize_input(raw)
