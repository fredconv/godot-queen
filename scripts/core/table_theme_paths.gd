class_name TableThemePaths
extends RefCounted
## Thèmes visuels de la table de jeu. Point de vérité unique pour les ids et
## chemins de texture (voir `ConfigService.get_table_theme()`).

const THEME_CLASSIC: StringName = &"classic"
const THEME_TAPIS: StringName = &"tapis"

const CLASSIC_COLOR: Color = Color(0.028, 0.26, 0.12, 1.0)
const TAPIS_TEXTURE_PATH: String = "res://assets/sprites/texture_tapis.jpg"
## Assombrit la texture tapis pour améliorer le contraste avec les cartes.
const TAPIS_TEXTURE_MODULATE: Color = Color(0.52, 0.56, 0.52, 1.0)

const THEME_IDS: Array[StringName] = [THEME_CLASSIC, THEME_TAPIS]


static func normalize_theme_id(theme_id: Variant) -> StringName:
	if str(theme_id) == str(THEME_TAPIS):
		return THEME_TAPIS
	return THEME_CLASSIC


static func get_label(theme_id: StringName) -> String:
	return TableCopy.theme_label(theme_id)


static func apply_to_nodes(color_rect: ColorRect, texture_rect: TextureRect, theme_id: StringName) -> void:
	var normalized: StringName = normalize_theme_id(theme_id)
	if normalized == THEME_TAPIS:
		var texture: Texture2D = load(TAPIS_TEXTURE_PATH) as Texture2D
		if texture == null:
			DebugService.log_warning("TableThemePaths: texture tapis introuvable, repli sur le feutre vert")
			_apply_classic(color_rect, texture_rect)
			return
		texture_rect.texture = texture
		texture_rect.modulate = TAPIS_TEXTURE_MODULATE
		texture_rect.visible = true
		color_rect.visible = false
	else:
		_apply_classic(color_rect, texture_rect)


static func _apply_classic(color_rect: ColorRect, texture_rect: TextureRect) -> void:
	color_rect.color = CLASSIC_COLOR
	color_rect.visible = true
	texture_rect.visible = false
	texture_rect.modulate = Color.WHITE
