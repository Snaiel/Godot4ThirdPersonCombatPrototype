extends Node3D

signal zero_health

@export var hitbox: HitboxComponent
@export var health = 100

# Called when the node nters the scene tree for the first time.
func _ready():
	hitbox.weapon_hit.connect(decrement_health)

func decrement_health(damage, _knockback):
	health -= damage
	if health <= 0:
		zero_health.emit()
