class_name HealthComponent
extends Node3D

signal zero_health

@export var hitbox: HitboxComponent
@export var health: float = 100.0
@export var blood_scene: PackedScene

# Called when the node nters the scene tree for the first time.
func _ready() -> void:
	hitbox.weapon_hit.connect(decrement_health)

func decrement_health(weapon: Sword) -> void:
	health -= weapon.get_damage()
	if blood_scene:
		var blood_particle: GPUParticles3D = blood_scene.instantiate()
		add_child(blood_particle)
		blood_particle.look_at(weapon.global_position)
		blood_particle.rotate_y(PI)
		blood_particle.restart()
	if health <= 0:
		zero_health.emit()



