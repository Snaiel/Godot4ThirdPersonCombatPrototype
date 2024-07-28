class_name RotationComponent
extends Node

@export var entity: CharacterBody3D

var target: Node3D
var can_rotate: bool = true
var rotate_towards_target: bool = false:
	set = set_rotate_towards_target
var move_direction: Vector3 = Vector3.ZERO
var looking_direction: Vector3 = Vector3.FORWARD
var target_look: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	entity.rotation_degrees.y = wrapf(entity.rotation_degrees.y, -180, 180.0)


func set_rotate_towards_target(value: bool) -> void:
	if value == rotate_towards_target: return
	rotate_towards_target = value
