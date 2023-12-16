class_name InstabilityComponent
extends Node3D


signal instability_increased
signal full_instability

@export_category("Configuration")
@export var active: bool = true
@export var hitbox: HitboxComponent

@export_category("Health")
@export var max_instability: float = 100.0


var _instability: float = 0.0:
	set(value):
		_instability = clamp(value, 0.0, max_instability)


func get_instability() -> float:
	return _instability


func increment_instability(value: float):
	_instability += value
	instability_increased.emit()


func _on_hitbox_component_weapon_hit(_weapon: Sword):
	increment_instability(8.0)


func _on_sword_parried():
	increment_instability(35.0)
