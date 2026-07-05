class_name VictoryPetals
extends Control
## Pluie discrète de pétales pour célébrer une victoire en fin de partie.
## Purement visuel : activé par `table.gd` si le joueur humain gagne.

const PLAY_DURATION_SEC: float = 5.0

var _particles: CPUParticles2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build_particles()


func _build_particles() -> void:
	_particles = CPUParticles2D.new()
	_particles.emitting = false
	_particles.one_shot = false
	_particles.amount = 48
	_particles.lifetime = 3.2
	_particles.preprocess = 0.4
	_particles.explosiveness = 0.05
	_particles.direction = Vector2(0.0, 1.0)
	_particles.spread = 28.0
	_particles.gravity = Vector2(0.0, 90.0)
	_particles.initial_velocity_min = 40.0
	_particles.initial_velocity_max = 110.0
	_particles.angular_velocity_min = -90.0
	_particles.angular_velocity_max = 90.0
	_particles.scale_amount_min = 0.35
	_particles.scale_amount_max = 0.85
	_particles.color = Color(1.0, 0.55, 0.65, 0.85)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.7, 0.78, 0.0))
	gradient.set_color(1, Color(1.0, 0.45, 0.55, 0.9))
	_particles.color_ramp = gradient
	add_child(_particles)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_emission_area()


func _update_emission_area() -> void:
	if _particles == null:
		return
	_particles.position = Vector2(size.x * 0.5, -8.0)
	_particles.emission_rect_extents = Vector2(size.x * 0.55, 8.0)


## Lance la pluie de pétales pendant `PLAY_DURATION_SEC` puis s'arrête.
func play() -> void:
	if _particles == null:
		return
	_update_emission_area()
	visible = true
	_particles.restart()
	_particles.emitting = true
	await get_tree().create_timer(PLAY_DURATION_SEC).timeout
	if is_instance_valid(_particles):
		_particles.emitting = false
	visible = false
