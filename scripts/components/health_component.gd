class_name HealthComponent
extends Node3D

signal zero_health

@export var hitbox: HitboxComponent
@export var health: float = 100.0
@export var blood: GPUParticles3D

# Called when the node nters the scene tree for the first time.
func _ready() -> void:
	hitbox.weapon_hit.connect(decrement_health)

func decrement_health(weapon: Sword) -> void:
	health -= weapon.damage
	if blood:
		blood.look_at(weapon.global_position)
		blood.rotate_y(PI)
		blood.restart()
	if health <= 0:
		zero_health.emit()
