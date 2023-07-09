class_name Player
extends CharacterBody3D

@export_category("Properties")
@export var walk_speed = 3.0
@export var run_speed = 6
@export var jump_strength = 8
@export var gravity = 20

@export_category("Flags")
@export var can_move = true
@export var can_rotate = true
@export var jumping = false
@export var running = false
@export var dodging = false

@export_category("Mechanisms")
@export var character: PlayerAnimations
@export var camera_controller: CameraController
@export var attack_component: AttackComponent

var input_direction = Vector3.ZERO

var _speed: float = 0.0
var _move_direction = Vector3.ZERO
var _velocity = Vector3.ZERO
var _can_jump = false
var _can_dodge = true
var _holding_down_run = false

var _turning = false
var _looking_direction
var _target_look

var _lock_on_enemy: Enemy = null
var _last_physics_pos = null

var angle = 0.0

func _ready():
	Globals.player = self
	_target_look = camera_controller.rotation.y
	_looking_direction = Vector3.FORWARD
	_last_physics_pos = global_position
	
	character.jumped.connect(_jump)
	character.jump_landed.connect(_jump_landed)
	
	attack_component.attacking.connect(_attacking)
	attack_component.can_rotate.connect(_can_rotate)

func _physics_process(delta):
	rotation_degrees.y = wrapf(rotation_degrees.y, -180, 180.0)
	
	# player inputs
	_move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	_move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	# retrieve the input direction to send to the animation script
	input_direction = _move_direction
	
	# handles rotating the player.
	# we want to rotate the player towards the target lock on entity if we are locked on (obviously).
	# We also want to rotate the player based on the where the character is moving.
	# So when it isn't locked on, it is handled by the elif block.
	# But we also want to have this behaviour at certain times while also
	# locked on. For example, when running away from the target or when jumping
	if _lock_on_enemy and not (running and input_direction.z > 0) and not (running and jumping):
		# get the angle towards the lock on target and
		# smoothyl rotate the player towards it
		_looking_direction = -global_position.direction_to(_lock_on_enemy.global_position)
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
		
		# This makes the rotation smoother when the player is locked
		# on and transitions from sprinting to walking
		var rotation_weight
		if abs(rotation.y - _target_look) > PI/4:
			rotation_weight = 0.03
		else:
			rotation_weight = 0.2
		rotation.y = lerp_angle(rotation.y, _target_look, rotation_weight)
			
		# change move direction so it orbits the locked on target
		# (not a perfect orbit, needs tuning but not unplayable)
		if _move_direction.length() > 0.2:
			_move_direction = _move_direction.rotated(
				Vector3.UP, 
				_target_look + sign(_move_direction.x) * 0.02
			).normalized()
			
	elif _move_direction.length() > 0.2:
		# get the rotation based on the current velocity direction
		_turning = true
		
		if can_move:
			_looking_direction = -Vector3(_velocity.x, 0, _velocity.z)				
		elif can_rotate:
			_looking_direction = -Vector3(_move_direction.x, 0, _move_direction.z)
			_looking_direction = _looking_direction.rotated(Vector3.UP, camera_controller.rotation.y).normalized()
			
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
		
		# swivel the camera in the opposite direction so
		# it tries to position itself back behind the player
		# (needs playtesting idk if it's actually good behaviour)
		if delta and !_lock_on_enemy:
			camera_controller.player_moving(_move_direction, delta)
	
		# change move direction so it is relative to where
		# the camera is facing
		_move_direction = _move_direction.rotated(Vector3.UP, camera_controller.rotation.y).normalized()
		
	# Makes sure the player is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _turning:
		if abs(rotation.y - _target_look) < 0.01:
			_turning = false
		rotation.y = lerp_angle(rotation.y, _target_look, 0.1)
	
	
	
	
	############################
	# secondary movement actions
	############################
	
	if Input.is_action_just_pressed("run") and _can_dodge:
		_dodge()
		_holding_down_run = true
	if Input.is_action_just_released("run"):
		_holding_down_run = false
	
	# start the jump animation when the jump key is pressed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		character.start_jump()
		
	# _can_jump is true when the jump animation reaches the point
	# where the character actually jumps. When this happens,
	# apply the jumping force
	if _can_jump:
		jumping = true
		_velocity.y = jump_strength
		_can_jump = false
		
	# after doing a running jump and landing on the floor,
	# go back to walking speed for the moment
	if jumping and is_on_floor() and _speed == run_speed:
		_speed = walk_speed
	elif (Input.is_action_pressed("run") and not dodging) or (jumping and _speed == run_speed):
		# change to running speed if pressing the run button
		# or keep running speed in the air
		if _holding_down_run || _can_dodge:
			_speed = run_speed
			running = true
	else:
		# walking speed for everything else
		_speed = walk_speed
		running = false
	
	################################
	# applying velocity calculations
	################################
	
	if can_move:
		_velocity.x = lerp(_velocity.x, _move_direction.x * _speed, 0.1)
		_velocity.z = lerp(_velocity.z, _move_direction.z * _speed, 0.1)
		
	if !is_on_floor():
		_velocity.y -= gravity * delta
	elif !jumping:
		_velocity.y = 0
		
	velocity = _velocity
	move_and_slide()
	_last_physics_pos = global_position
	
	
func _process(_delta):
	character.update_anim_parameters(input_direction, _lock_on_enemy != null, running)
	
func _on_lock_on_system_lock_on(enemy):
	_lock_on_enemy = enemy
	camera_controller.lock_on(enemy)
	
func _can_rotate(flag: bool):
	can_rotate = flag

func _dodge():
	_can_dodge = false
	dodging = true
	_velocity += _move_direction * 8
	var timer = get_tree().create_timer(0.2)
	var can_dodge_timer = get_tree().create_timer(0.6)	
	timer.connect("timeout", _finish_dodging)
	can_dodge_timer.connect("timeout", _can_dodge_again)	
	
func _finish_dodging():
	dodging = false
	
func _can_dodge_again():
	_can_dodge = true

func _jump():
	_can_jump = true

func _jump_landed():
	jumping = false

func _attacking(active):
	if active:
		can_move = false
		_velocity.x = 0
		_velocity.z = 0
	else:
		can_move = true
