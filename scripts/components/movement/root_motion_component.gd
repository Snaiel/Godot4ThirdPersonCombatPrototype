class_name RootMotionComponent
extends MotionComponent


@export var character: CharacterAnimations


func handle_movement(delta):
	var desired_y: float = desired_velocity.y
	
	desired_velocity = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, entity.rotation.y + PI)
	) / delta
	
	desired_velocity.y = desired_y
