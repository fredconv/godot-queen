extends Control
## PlayerAvatar
## Avatar animé d'un joueur : boucle d'idle (4 frames) tirée de la première
## ligne d'une feuille de sprites `Char_00X.png` (grille 4x4, frames 48x48).
## Les lignes 1 à 3 de la feuille (autres animations) ne sont pas utilisées
## pour l'instant (voir docs/DECISIONS.md).

const FRAME_SIZE: int = 48
const FRAME_COUNT: int = 4
const IDLE_ANIMATION: StringName = &"idle"
const IDLE_FPS: float = 8.0

## Feuilles de sprites disponibles, indexées par `character_index` (0-3).
const CHARACTER_SHEETS: Array[String] = [
	"res://assets/sprites/Char_001.png",
	"res://assets/sprites/Char_002.png",
	"res://assets/sprites/Char_003.png",
	"res://assets/sprites/Char_004.png",
]

## Index du personnage (0-3) déterminant quelle feuille de sprites utiliser.
@export_range(0, 3, 1) var character_index: int = 0:
	set(value):
		character_index = clampi(value, 0, CHARACTER_SHEETS.size() - 1)
		_refresh_sprite()

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_refresh_sprite()

## Permet de définir directement le chemin de la feuille de sprites, sans
## passer par `character_index` (utile pour un personnage hors de
## `CHARACTER_SHEETS`).
func set_character_sheet(sheet_path: String) -> void:
	var texture: Texture2D = load(sheet_path) as Texture2D
	if not texture:
		DebugService.log_error("PlayerAvatar: impossible de charger la feuille de sprites '%s'" % sheet_path)
		return
	_sprite.sprite_frames = _build_idle_sprite_frames(texture)
	_sprite.play(IDLE_ANIMATION)

func _refresh_sprite() -> void:
	if not _sprite:
		return
	set_character_sheet(CHARACTER_SHEETS[character_index])

## Construit une ressource `SpriteFrames` avec une seule animation "idle" en
## boucle, à partir des 4 frames (48x48) de la première ligne de la feuille.
func _build_idle_sprite_frames(sheet_texture: Texture2D) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(IDLE_ANIMATION)
	frames.set_animation_loop(IDLE_ANIMATION, true)
	frames.set_animation_speed(IDLE_ANIMATION, IDLE_FPS)
	for column in FRAME_COUNT:
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = sheet_texture
		atlas.region = Rect2(column * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
		frames.add_frame(IDLE_ANIMATION, atlas)
	return frames
