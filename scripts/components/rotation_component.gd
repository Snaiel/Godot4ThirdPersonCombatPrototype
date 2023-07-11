class_name RotationComponent
extends Node3D

@export var player: Player

var looking_direction: Vector3
var move_direction: Vector3


var _camera_controller: CameraController

var _lock_on_enemy
var _running: bool
var _jumping: bool

var _input_direction: Vector3

var _can_move: bool
var _can_rotate: bool

var _velocity: Vector3

var _target_look: float
var _turning = true


# Called when the node enters the scene tree for the first time.
func _ready():
	_camera_controller = player.camera_controller
	_target_look = _camera_controller.rotation.y


func handle_rotation(delta):
	_lock_on_enemy = player.lock_on_enemy
	_running = player.running
	_jumping = player.jumping
	_input_direction = player.input_direction
	move_direction = player.move_direction
	_can_move = player.can_move
	_can_rotate = player.can_rotate
	_velocity = player.desired_velocity
	
	# handles rotating the player.
	# we want to rotate the player towards the target lock on entity if we are locked on (obviously).
	# We also want to rotate the player based on the where the character is moving.
	# So when it isn't locked on, it is handled by the elif block.
	# But we also want to have this behaviour at certain times while also
	# locked on. For example, when _running away from the target or when _jumping
	if _lock_on_enemy and not (_running and _input_direction.z > 0) and not (_running and _jumping):
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		looking_direction = -global_position.direction_to(_lock_on_enemy.global_position)
		_target_look = atan2(looking_direction.x, looking_direction.z)
		
		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight
		if abs(player.rotation.y - _target_look) > PI/4:
			rotation_weight = 0.03
		else:
			rotation_weight = 0.2
		player.rotation.y = lerp_angle(player.rotation.y, _target_look, rotation_weight)
			
		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP, 
				_target_look + sign(move_direction.x) * 0.02
			).normalized()
			
	elif move_direction.length() > 0.2:
		# get the rotation based on the current velocity direction
		_turning = true
		
		if _can_move and _velocity.length() > 0:
			looking_direction = -Vector3(_velocity.x, 0, _velocity.z)				
		elif _can_rotate:
			looking_direction = -Vector3(move_direction.x, 0, move_direction.z)
			looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
		
		_target_look = atan2(looking_direction.x, looking_direction.z)
		
		# swivel the camera in the opposite direction so
		# it tries to position itself back behind the player
		# (needs playtesting idk if it's actually good behaviour)
		if delta and !_lock_on_enemy:
			_camera_controller.player_moving(move_direction, delta)
	
		# change move direction so it is relative to where
		# the camera is facing
		move_direction = move_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
		
	# Makes sure the player is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _turning:
		if abs(player.rotation.y - _target_look) < 0.01:
			_turning = false
		player.rotation.y = lerp_angle(player.rotation.y, _target_look, 0.1)
