class_name HealthComponent
extends Node3D


signal took_damage
signal zero_health

@export_category("Configuration")
@export var active: bool = true
@export var hitbox: HitboxComponent

@export_category("Health")
@export var max_health: float = 100.0

@export_category("Particles")
@export var blood_scene: PackedScene

var deal_max_damage: bool = false

var _health: float:
	set(value):
		_health = clamp(value, 0.0, max_health)


func _ready() -> void:
	hitbox.weapon_hit.connect(decrement_health)
	_health = max_health


func get_health() -> float:
	return _health


func is_alive() -> bool:
	return _health > 0


func decrement_health(weapon: Sword) -> void:
	if not active:
		return
	
	if blood_scene:
		var blood_particle: GPUParticles3D = blood_scene.instantiate()
		add_child(blood_particle)
		blood_particle.look_at(weapon.global_position)
		blood_particle.rotate_y(PI)
		blood_particle.restart()
	
	if deal_max_damage:
		_health = 0
		deal_max_damage = false
	else:
		_health -= weapon.get_damage()
	
	took_damage.emit()
	
	if _health <= 0:
		zero_health.emit()
	
