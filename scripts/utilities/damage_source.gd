class_name DamageSource
extends Node3D


signal parried


@export var entity: CharacterBody3D
@export var debug: bool = false

@export var damage: float = 25.0
@export var knockback: float = 3.0
@export var can_damage: bool = false

# Used to make sure an entity is only hit
# once in a single instance. For example
# this may come in and out of a hitbox
# multiple times but it should only count
# as one hit if its the same instance.
var instance: int = 0


func _process(_delta):
	if debug: print(can_damage)


func get_parried() -> void:
	parried.emit()
