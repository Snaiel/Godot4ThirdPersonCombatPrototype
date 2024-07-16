class_name DamageSource
extends Node3D


signal parried


@export var entity: CharacterBody3D
@export var debug: bool = false

@export var can_damage: bool = false
@export var damage_attributes: DamageAttributes = \
	preload("res://resources/DefaultDamageAttributes.tres")

# Used to make sure an entity is only hit
# once in a single instance. For example
# this may come in and out of a hitbox
# multiple times but it should only count
# as one hit if its the same instance.
var instance: int = 0


func _process(_delta):
	if debug: print(can_damage)


## this damage source got parried by an entity
func get_parried() -> void:
	parried.emit()


## Logic when this damage source successfully hits an entity
## Returns whether its going to free itsself
func hit_considered() -> bool:
	# meant to be overridden
	return false
