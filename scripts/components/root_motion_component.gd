class_name RootMotionComponent
extends Node3D


@export var enabled: bool = false
@export var entity: CharacterBody3D
@export var character: CharacterAnimations
@export var movement_component: MovementComponent


func _physics_process(delta):
	if enabled:
		movement_component.enabled = false
	else:
		movement_component.enabled = true
		return
	
#	var _desired_velocity = character.anim_tree.get_root_motion_position() / delta * 5
	
	
#	var current_rotation: Quaternion = entity\
#		.transform\
#		.basis\
#		.get_rotation_quaternion()\
#		.normalized()
	
#	var _desired_velocity = (
#		current_rotation * \
#		character.anim_tree.get_root_motion_position()
#	) / delta * 5
	
	
	var _desired_velocity = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, entity.rotation.y + PI)
	) / delta
	
	
	prints(
		_desired_velocity,
		character.anim_tree.get_root_motion_position()
	)
	
	entity.velocity = _desired_velocity
	entity.move_and_slide()
