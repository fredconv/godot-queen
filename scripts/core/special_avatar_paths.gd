class_name SpecialAvatarPaths
extends RefCounted
## Mapping `character_id` (0-3) → avatar « super attaque » :
## 0 = joueur (magenta), 1 = adversaire 1 (bleu), 2 = adversaire 2 (or),
## 3 = adversaire 3 (vert). Aligné sur `PlayerSeat.character_id` / `table.tscn`.

const AVATAR_PATHS: Array[String] = [
	"res://assets/sprites/avatar_joueur_magenta.png",
	"res://assets/sprites/avatar_adv1_bleu.png",
	"res://assets/sprites/avatar_adv2_or.png",
	"res://assets/sprites/avatar_adv3_vert.png",
]


static func get_avatar_path(character_id: int) -> String:
	var index: int = clampi(character_id, 0, AVATAR_PATHS.size() - 1)
	return AVATAR_PATHS[index]


static func get_texture(character_id: int) -> Texture2D:
	return load(get_avatar_path(character_id)) as Texture2D
