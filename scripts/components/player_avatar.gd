class_name PlayerAvatar
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

var _turn_active: bool = false
var _fx_tween: Tween

func _ready() -> void:
	_refresh_sprite()
	set_turn_active(false)


## Active l'animation idle uniquement quand c'est le tour de ce joueur.
func set_turn_active(active: bool) -> void:
	_turn_active = active
	_apply_turn_animation_state()

## Permet de définir directement le chemin de la feuille de sprites, sans
## passer par `character_index` (utile pour un personnage hors de
## `CHARACTER_SHEETS`).
func set_character_sheet(sheet_path: String) -> void:
	var texture: Texture2D = load(sheet_path) as Texture2D
	if not texture:
		DebugService.log_error("PlayerAvatar: impossible de charger la feuille de sprites '%s'" % sheet_path)
		return
	_sprite.sprite_frames = _build_idle_sprite_frames(texture)
	_apply_turn_animation_state()


func _apply_turn_animation_state() -> void:
	if not _sprite or _sprite.sprite_frames == null:
		return
	if _turn_active:
		_sprite.play(IDLE_ANIMATION)
	else:
		_sprite.stop()
		_sprite.animation = IDLE_ANIMATION
		_sprite.frame = 0


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


func _kill_fx_tween() -> void:
	if _fx_tween != null and _fx_tween.is_valid():
		_fx_tween.kill()
	_fx_tween = null


## Secousse légère (défaite de manche).
func play_hand_loss_shake() -> void:
	if not is_inside_tree():
		return
	_kill_fx_tween()
	var base_x: float = position.x
	_fx_tween = create_tween()
	for _i in 3:
		_fx_tween.tween_property(self, "position:x", base_x + 5.0, 0.04)
		_fx_tween.tween_property(self, "position:x", base_x - 5.0, 0.04)
	_fx_tween.tween_property(self, "position:x", base_x, 0.04)


## Petits sauts de joie (victoire de manche).
func play_hand_win_bounce(bounce_count: int = 3) -> void:
	if not is_inside_tree():
		return
	_kill_fx_tween()
	var base_y: float = position.y
	_fx_tween = create_tween()
	for _i in bounce_count:
		_fx_tween.tween_property(self, "position:y", base_y - 14.0, 0.09) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_fx_tween.tween_property(self, "position:y", base_y, 0.11) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
