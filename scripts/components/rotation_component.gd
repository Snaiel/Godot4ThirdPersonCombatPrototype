class_name RotationComponent
extends Node3D

@export var player: Player

var looking_direction: Vector3 = Vector3.BACK
var move_direction: Vector3
var rotate_towards_target = false

var _camera_controller: CameraController

var _target_look: float
var _freelook_turn = true


# Called when the node enters the scene tree for the first time.
func _ready():
	_camera_controller = player.camera_controller
	_target_look = _camera_controller.rotation.y
	
	looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()

func handle_rotation(delta):
	player.rotation_degrees.y = wrapf(player.rotation_degrees.y, -180, 180.0)
	
	
	var _lock_on_target = player.lock_on_target
	var _input_direction = player.input_direction
	var _can_move = player.movement_component.can_move
	var _can_rotate = player.can_rotate
	var _velocity = player.movement_component.desired_velocity
	
	move_direction = _input_direction
	
	if rotate_towards_target:
		_freelook_turn = false
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		looking_direction = -global_position.direction_to(_lock_on_target.global_position)
		_target_look = atan2(looking_direction.x, looking_direction.z)
		
		var rotation_difference = abs(player.rotation.y - _target_look)
		
		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight
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
			looking_direction = -Vector3(_velocity.x, 0, _velocity.z)				
		elif _can_rotate:
			looking_direction = -Vector3(move_direction.x, 0, move_direction.z)
			looking_direction = looking_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
		
		
		_target_look = atan2(looking_direction.x, looking_direction.z)
		
		
		# swivel the camera in the opposite direction so
		# it tries to position itself back behind the player
		# (needs playtesting idk if it's actually good behaviour)
		if delta and not _lock_on_target:
			_camera_controller.player_moving(move_direction, delta)
	
	
		# change move direction so it is relative to where
		# the camera is facing
		move_direction = move_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
	
		
	# Makes sure the player is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _freelook_turn:
		if abs(player.rotation.y - _target_look) < 0.01:
			_freelook_turn = false
		player.rotation.y = lerp_angle(player.rotation.y, _target_look, 0.1)


func get_lock_on_rotation_difference():
	var looking_direction = -global_position.direction_to(player.lock_on_target.global_position)
	_target_look = atan2(looking_direction.x, looking_direction.z)
	return abs(player.rotation.y - _target_look)
