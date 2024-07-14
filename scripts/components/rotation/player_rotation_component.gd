class_name PlayerRotationComponent
extends RotationComponent


var player: Player

var _freelook_turn: bool = true
var _turn_all_the_way: bool = false

@onready var _camera_controller: CameraController = Globals.camera_controller


func _ready() -> void:
	player = entity as Player
	target_look = _camera_controller.rotation.y
	
	looking_direction = looking_direction.rotated(
		Vector3.UP,
		_camera_controller.rotation.y
	).normalized()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not can_rotate: return
	
	var _input_direction: Vector3 = player.input_direction
	var _last_input_on_ground: Vector3 = player.last_input_on_ground
	var _can_move: bool = player.locomotion_component.can_move
	var _velocity: Vector3 = player.velocity
	
	move_direction = _input_direction.normalized()
	
	if rotate_towards_target and target:
		_freelook_turn = false
		
		# get the angle towards the lock on target and
		# smoothly rotate the player towards it
		looking_direction = player.global_position.direction_to(
			target.global_position
		)
		target_look = atan2(-looking_direction.x, -looking_direction.z)
		
		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_difference: float = abs(player.rotation.y - target_look)
		var rotation_weight: float
		if rotation_difference > 0.05 and \
		player.state_machine.current_state is PlayerRunState:
			rotation_weight = 0.1
		else:
			rotation_weight = 0.2
		
		player.rotation.y = lerp_angle(
			player.rotation.y, target_look, rotation_weight
		)
		
		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP, target_look + sign(move_direction.x) * 0.13
			).normalized()
		
	elif _input_direction.length() > 0.2:
		# get the rotation based on the current velocity direction
		_freelook_turn = true
		_turn_all_the_way = true

		if _can_move and _velocity.length() > 0 and player.is_on_floor():
			# normal behaviour: player rotating towards where they are going
			looking_direction = Vector3(_velocity.x, 0, _velocity.z)
		elif can_rotate:
			# if player can't move but they can rotate,
			# rotate the player based on input instead
			looking_direction = Vector3(
				_input_direction.x, 0, _input_direction.z
			)
			looking_direction = looking_direction.rotated(
				Vector3.UP, _camera_controller.rotation.y
			).normalized()
		
		# retrieve desired angle from looking direction
		target_look = atan2(-looking_direction.x, -looking_direction.z)
		
		# swivel the camera in the opposite direction so
		# it tries to position itself back behind the player
		# (needs playtesting idk if it's actually good behaviour)
		if delta and not target:
			if player.is_on_floor():
				_camera_controller.player_moving(
					move_direction,
					player.state_machine.current_state is PlayerRunState,
					delta
				)
			else:
				# artifically keeps the input from the ground
				# whilst mid air to simulate keeping momentum
				if abs(_last_input_on_ground.z) > 0.2:
					move_direction.z = sign(_last_input_on_ground.z)
					
				if abs(_last_input_on_ground.x) > 0.2 and \
				abs(_last_input_on_ground.z) < 0.2:
					# if moving left or right relative to camera before
					# jumping, slow down opposite sidewards movement mid air
					if is_equal_approx(
						_input_direction.x, -_last_input_on_ground.x
					):
						move_direction.x = \
							_input_direction.normalized().x * 0.2
				else:
					# reduce side to side movement mid air
					move_direction.x = move_direction.x * 0.6
					# if moving forwards or backwards relative to camera
					# before jumping, slow down opposite movement mid air
					if is_equal_approx(
						_input_direction.z, -_last_input_on_ground.z
					) and \
					abs(_input_direction.z) > 0.2:
						move_direction.z = \
							_input_direction.normalized().z * 0.2
				
				# if coming from a jump standing still
				if _last_input_on_ground.length() < 0.1:
					_turn_all_the_way = false
					move_direction = move_direction * 0.8
		
		# change move direction so it is relative to where
		# the camera is facing
		move_direction = move_direction.rotated(
			Vector3.UP, _camera_controller.rotation.y
		)
	
	
	# the massive not condition ensures that the player does not rotate
	# the opposite way if mid air and the player is inputting to go in
	# the opposite direction from their original momentum on the ground
	if _freelook_turn and _turn_all_the_way and \
		not (
			not player.is_on_floor() and \
			is_equal_approx(_input_direction.z, -_last_input_on_ground.z) and \
			abs(_input_direction.z) > 0.2
		) and \
		not (
			not player.is_on_floor() and \
			is_equal_approx(_input_direction.x, -_last_input_on_ground.x) and \
			abs(_input_direction.x) > 0.2
		) and \
		not (
			not player.is_on_floor() and _last_input_on_ground.length() < 0.1
		):
		
		# Makes sure the player is rotated fully to the desired direction
		# even if pressed for a short period of time
		if abs(player.rotation.y - target_look) < 0.01:
			_freelook_turn = false
		player.rotation.y = lerp_angle(player.rotation.y, target_look, 0.1)
	
	# if coming from a jump standing still,
	# rotate slowly during input. don't turn all the way
	if _freelook_turn and not _turn_all_the_way:
		_freelook_turn = false
		player.rotation.y = lerp_angle(player.rotation.y, target_look, 0.03)


func get_rotation_difference(t: Node3D) -> float:
	var _looking_direction: Vector3 = -player.global_position.direction_to(
		t.global_position
	)
	var r: float = atan2(_looking_direction.x, _looking_direction.z)
	return abs(player.rotation.y - r)
