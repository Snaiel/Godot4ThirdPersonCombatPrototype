class_name RotationComponent
extends Node3D

@export var entity: CharacterBody3D

var target: Node3D
var can_rotate: bool = true
var rotate_towards_target: bool = false
var move_direction: Vector3 = Vector3.ZERO
var looking_direction: Vector3 = Vector3.FORWARD
var target_look: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	entity.rotation_degrees.y = wrapf(entity.rotation_degrees.y, -180, 180.0)
