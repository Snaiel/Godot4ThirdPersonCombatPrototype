class_name Weapon
extends BoneAttachment3D


signal parried

@export var entity: CharacterBody3D
@export var melee_component: MeleeComponent
@export var debug: bool = false

@export var damage: float = 25.0
@export var knockback: float = 3.0
@export var can_damage: bool = false


func _process(_delta):
	if debug: print(can_damage)


func parry_weapon() -> void:
	parried.emit()
