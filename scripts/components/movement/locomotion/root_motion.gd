class_name RootMotionLocomotionStrategy
extends LocomotionStrategy


@export var character: CharacterAnimations

# read only variable of the speed as a result
# of the root motion movement.
var root_motion_speed: float

var _v: Vector3


func _process(delta: float) -> void:
	if context.active_strategy != self: return
	_v = (
		character\
			.anim_tree\
			.get_root_motion_position()\
			.rotated(Vector3.UP, context.entity.rotation.y + PI)
	) / delta


func handle_movement(_delta: float) -> void:
	var desired_y: float = context.desired_velocity.y
	
	if debug: prints(
		character.anim_tree.get_root_motion_position().length(),
		_v,
		root_motion_speed
	)
	
	root_motion_speed = _v.length()
	
	context.desired_velocity = _v
	context.desired_velocity.y = desired_y
