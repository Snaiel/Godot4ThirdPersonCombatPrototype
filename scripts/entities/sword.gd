class_name Weapon
extends BoneAttachment3D


signal parried

@export var _entity: CharacterBody3D
@export var debug: bool = false

@export var _damage: float = 25.0
@export var _knockback: float = 3.0
@export var can_damage: bool = false


func _process(_delta):
	if debug: print(can_damage)


func get_entity() -> CharacterBody3D:
	return _entity
	

func get_damage() -> float:
	return _damage


func get_knockback() -> float:
	return _knockback


func get_parried() -> void:
	parried.emit()
