class_name RotationComponent
extends Node3D

@export var look_at_target: bool = false
@export var entity: CharacterBody3D
@export var target: Node3D

var move_direction: Vector3 = Vector3.ZERO
var looking_direction: Vector3 = Vector3.FORWARD
var target_look: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if target and look_at_target:
		looking_direction = entity.global_position.direction_to(target.global_position)
		target_look = atan2(looking_direction.x, looking_direction.z)
		entity.rotation.y = lerp_angle(entity.rotation.y, target_look, 0.05)
