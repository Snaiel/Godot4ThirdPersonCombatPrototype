class_name RootMotionLocomotionStrategy
extends LocomotionStrategy


@export var character: CharacterAnimations


func handle_movement(delta: float, context: LocomotionComponent) -> void:
	var desired_y: float = context.desired_velocity.y
	
	context.desired_velocity = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, context.entity.rotation.y + PI)
	) / delta
	
	context.desired_velocity.y = desired_y
