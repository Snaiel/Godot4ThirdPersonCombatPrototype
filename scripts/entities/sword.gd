class_name Sword
extends BoneAttachment3D


signal parried

@export var _entity: CharacterBody3D

@export var _damage: float = 10.0
@export var _knockback: float = 3.0
@export var can_damage: bool = false


func get_entity() -> CharacterBody3D:
	return _entity
	

func get_damage() -> float:
	return _damage


func get_knockback() -> float:
	return _knockback


func get_parried() -> void:
	parried.emit()


func _on_enemy_death(_enemy: Enemy):
	can_damage = false
