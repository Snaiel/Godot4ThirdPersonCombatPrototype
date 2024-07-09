class_name RootMotionLocomotionStrategy
extends LocomotionStrategy


@export var character: CharacterAnimations

# read only variable of the speed as a result
# of the root motion movement.
var root_motion_speed: float


func handle_movement(delta: float, context: LocomotionComponent) -> void:
	var desired_y: float = context.desired_velocity.y
	var v: Vector3 = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, context.entity.rotation.y + PI)
	) / delta
	
	if debug: prints(v, root_motion_speed)
	
	root_motion_speed = v.length()
	
	context.desired_velocity = v
	context.desired_velocity.y = desired_y
