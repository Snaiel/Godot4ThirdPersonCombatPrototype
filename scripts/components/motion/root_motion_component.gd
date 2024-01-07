class_name RootMotionComponent
extends MotionComponent


@export var character: CharacterAnimations


func handle_movement(delta):
	
	var _desired_velocity = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, entity.rotation.y + PI)
	) / delta
	
	entity.velocity = _desired_velocity
	entity.move_and_slide()
