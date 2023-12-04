class_name HealthComponent
extends Node3D


signal zero_health

@export var hitbox: HitboxComponent
@export var health: float = 100.0
@export var blood_scene: PackedScene

var deal_max_damage: bool = false


# Called when the node nters the scene tree for the first time.
func _ready() -> void:
	hitbox.weapon_hit.connect(decrement_health)


func is_alive() -> bool:
	return health > 0


func decrement_health(weapon: Sword) -> void:
	if blood_scene:
		var blood_particle: GPUParticles3D = blood_scene.instantiate()
		add_child(blood_particle)
		blood_particle.look_at(weapon.global_position)
		blood_particle.rotate_y(PI)
		blood_particle.restart()
	
	if deal_max_damage:
		health = 0
		deal_max_damage = false
	else:
		health -= weapon.get_damage()
	
	if health <= 0:
		zero_health.emit()
