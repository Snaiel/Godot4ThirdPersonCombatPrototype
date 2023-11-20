class_name PlayerRotationComponent
extends RotationComponent

var player: Player
var rotate_towards_target: bool = false

var _camera_controller: CameraController

var _target_look: float
var _freelook_turn: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = entity as Player
	_camera_controller = player.camera_controller
	_target_look = _camera_controller.rotation.y
	
	looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()


func _physics_process(delta: float) -> void:
	target = player.lock_on_target
	
	var _input_direction: Vector3 = player.input_direction
	var _last_input_on_ground: Vector3 = player.last_input_on_ground
	var _can_move: bool = player.movement_component.can_move
	var _can_rotate: bool = player.can_rotate
	var _velocity: Vector3 = player.movement_component.desired_velocity
	
	move_direction = _input_direction

	if rotate_towards_target:
		_freelook_turn = false
		
		# get the angle towards the lock on target and
		# smoothly rotate the player towards it
		looking_direction = player.global_position.direction_to(target.global_position)
		_target_look = atan2(-looking_direction.x, -looking_direction.z)

		var rotation_difference: float = abs(player.rotation.y - _target_look)

		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight: float
		if rotation_difference < 0.05:
			rotation_weight = 0.2
		else:
			rotation_weight = 0.1

		player.rotation.y = lerp_angle(player.rotation.y, _target_look, rotation_weight)

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
			# normal behaviour: player rotating towards where
			# they are going
			looking_direction = Vector3(_velocity.x, 0, _velocity.z)
		elif _can_rotate:
			# if player can't move but they can rotate,
			# rotate the player based on input instead
			looking_direction = Vector3(_input_direction.x, 0, _input_direction.z)
			looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
		
		# retrieve desired angle from looking direction
		_target_look = atan2(-looking_direction.x, -looking_direction.z)


		# swivel the camera in the opposite direction so
		# it tries to position itself back behind the player
		# (needs playtesting idk if it's actually good behaviour)
		if delta and not target:
			
			_camera_controller.player_moving(move_direction, player.running, delta)

			if not player.is_on_floor():
				# reduce side to side movement mid air
				move_direction.x = move_direction.x * 0.5
				# reduce 'backwards' movement mid air
				if is_equal_approx(_input_direction.z, -_last_input_on_ground.z) and abs(_input_direction.z) > 0.2:
					move_direction.z = move_direction.z * 0.3
					
		# change move direction so it is relative to where
		# the camera is facing
		move_direction = move_direction.rotated(Vector3.UP, _camera_controller.rotation.y)


	# the massive not condition ensures that the player does not rotate
	# the opposite way if mid air and the player is inputting to go in
	# the opposite direction from their original momentum on the ground
	if _freelook_turn and \
		not (
			not player.is_on_floor() and \
			is_equal_approx(_input_direction.z, -_last_input_on_ground.z) and \
			abs(_input_direction.z) > 0.2
			):
		
		# Makes sure the player is rotated fully to the desired direction
		# even if pressed for a short period of time
		if abs(player.rotation.y - _target_look) < 0.01:
			_freelook_turn = false
		player.rotation.y = lerp_angle(player.rotation.y, _target_look, 0.1)


func get_lock_on_rotation_difference() -> float:
	var _looking_direction: Vector3 = -player.global_position.direction_to(
		player.lock_on_target.global_position
	)
	_target_look = atan2(_looking_direction.x, _looking_direction.z)
	return abs(player.rotation.y - _target_look)
