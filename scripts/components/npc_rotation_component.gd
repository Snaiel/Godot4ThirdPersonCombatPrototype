class_name NPCRotationComponent
extends RotationComponent

@export var debug: bool = false
@export var movement_component: MovementComponent
@export var _blackboard: Blackboard

var _target_look: float
var _freelook_turn: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	player = entity as Player
#	_camera_controller = player.camera_controller
#	_target_look = _camera_controller.rotation.y
#
	looking_direction = looking_direction.rotated(Vector3.UP, entity.rotation.y).normalized()

func _physics_process(delta: float) -> void:
#	target = player.lock_on_target
	var _input_direction: Vector3 = _blackboard.get_value("input_direction", Vector3.ZERO)
	var _can_move: bool = movement_component.can_move
#	var _can_rotate: bool = player.can_rotate
	var _velocity: Vector3 = movement_component.desired_velocity

#	print(_blackboard.has_value("look_at_target"))
	move_direction = _input_direction
	
	if debug:
#		print(look_at_target, _input_direction)
#		print(entity.rotation.y)
		pass

	if look_at_target:
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		looking_direction = entity.global_position.direction_to(target.global_position)
		_target_look = atan2(-looking_direction.x, -looking_direction.z)
		

		var rotation_difference: float = abs(entity.rotation.y - _target_look)

		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight: float
		if rotation_difference < 0.05:
			rotation_weight = 0.2
		else:
			rotation_weight = 0.1

		entity.rotation.y = lerp_angle(entity.rotation.y, _target_look, rotation_weight)

		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP,
				_target_look + sign(move_direction.x) * 0.02
			).normalized()


	elif _input_direction.length() > 0.2:
		# get the rotation based on the current velocity direction
		_freelook_turn = true


		if _can_move and _velocity.length() > 0:
			looking_direction = Vector3(_velocity.x, 0, _velocity.z)
#		elif _can_rotate:
#			looking_direction = Vector3(move_direction.x, 0, move_direction.z)
#			looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()

		_target_look = atan2(-looking_direction.x, -looking_direction.z)
		
		move_direction = move_direction.rotated(Vector3.UP, _target_look).normalized()				
		

	# Makes sure the entity is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _freelook_turn:
		if abs(entity.rotation.y - _target_look) < 0.01:
			_freelook_turn = false
		entity.rotation.y = lerp_angle(entity.rotation.y, _target_look, 0.1)
