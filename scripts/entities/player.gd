class_name Player
extends CharacterBody3D

@export_category("Properties")
@export var walk_speed = 3.0
@export var run_speed = 6
@export var jump_strength = 8
@export var gravity = 20

@export_category("Mechanisms")
@export var rotation_component: RotationComponent
@export var character: PlayerAnimations
@export var camera_controller: CameraController
@export var attack_component: AttackComponent

var input_direction = Vector3.ZERO

var move_direction = Vector3.ZERO
var desired_velocity = Vector3.ZERO

var can_move = true
var running = false

var can_rotate = true

var can_jump = false
var jumping = false

var can_dodge = true
var dodging = false
var _intent_to_dodge = false
var _can_set_intent_to_dodge = true

var lock_on_enemy: Enemy = null



var _speed: float = 0.0
var _holding_down_run = false
var _holding_down_run_timer: Timer

var _looking_direction = Vector3.BACK
var _impulse = 0.0



func _ready():
	Globals.player = self
	
	character.jump_animations.jumped.connect(_jump)
	character.jump_animations.jump_landed.connect(_jump_landed)
	
	attack_component.attacking.connect(_attacking)
	attack_component.can_rotate.connect(_can_rotate)
	
	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(_handle_hold_down_run_timer)
	add_child(_holding_down_run_timer)

func _physics_process(delta):
	rotation_degrees.y = wrapf(rotation_degrees.y, -180, 180.0)
	
	# player inputs
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	# retrieve the input direction to send to the animation script
	input_direction = move_direction
	
	character.movement_animations.move(input_direction, lock_on_enemy != null, running)	
	
	############################
	# player rotation
	############################
	
	# handle rotation of the player based on camera, movement, or lock on
	rotation_component.handle_rotation(delta)
	move_direction = rotation_component.move_direction
	_looking_direction = rotation_component.looking_direction
	
	############################
	# secondary movement actions
	############################
	
	# make sure the user is actually holding down
	# the run key to make the player run 
	if Input.is_action_just_pressed("run"):
		if _can_set_intent_to_dodge:
			_intent_to_dodge = true
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		_holding_down_run = false
	
	
	if can_dodge and _intent_to_dodge:
		_dodge()
	
	# start the jump animation when the jump key is pressed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		character.jump_animations.start_jump()
		
	# can_jump is true when the jump animation reaches the point
	# where the character actually jumps. When this happens,
	# apply the jumping force
	if can_jump:
		desired_velocity.y = jump_strength
		can_jump = false
	
		
		
		
	# after doing a running jump and landing on the floor, go back to walking speed for the moment
	# OR when we jump while running, slow down to walk speed to 'prepare' for the leap
	if (jumping and is_on_floor() and _speed == run_speed) or (jumping and is_on_floor() and not can_jump):
		_speed = walk_speed
	elif (_holding_down_run and is_on_floor() and not dodging) or (jumping and running):
		# change to running speed if pressing the run button
		# or keep running speed in the air
		_speed = run_speed
		running = true
	else:
		# walking speed for everything else
		_speed = walk_speed
		running = false
		
		
	
	
	################################
	# applying velocity calculations
	################################
	
	if _impulse:
		desired_velocity = -_looking_direction * _impulse
	
	if can_move:
		desired_velocity.x = lerp(desired_velocity.x, move_direction.x * _speed, 0.1)
		desired_velocity.z = lerp(desired_velocity.z, move_direction.z * _speed, 0.1)
		
	if !is_on_floor():
		desired_velocity.y -= gravity * delta
	elif !jumping:
		desired_velocity.y = 0
		
	velocity = desired_velocity
	move_and_slide()
	
	
func _on_lock_on_system_lock_on(enemy):
	lock_on_enemy = enemy
	camera_controller.lock_on(enemy)
	
func _can_rotate(flag: bool):
	can_rotate = flag
	
func _handle_hold_down_run_timer():
	_holding_down_run = true

func _dodge():
	if is_on_floor():
		_intent_to_dodge = false
		_can_set_intent_to_dodge = false
		can_dodge = false
		dodging = true
		desired_velocity += move_direction * 8
		
		# how long the dodge status lasts
		var dodge_timer = get_tree().create_timer(0.2) 
		# after this time, presing dodge again will dodge as soon as possible
		var register_next_dodge_timer = get_tree().create_timer(0.3)
		# this is the time it takes for the next dodge to actually occur
		var can_dodge_timer = get_tree().create_timer(0.8)	
		
		dodge_timer.connect("timeout", _finish_dodging)
		register_next_dodge_timer.connect("timeout", _register_next_dodge_input)		
		can_dodge_timer.connect("timeout", _can_dodge_again)	
	
func _finish_dodging():
	dodging = false
	
func _register_next_dodge_input():
	_can_set_intent_to_dodge = true
	
func _can_dodge_again():
	can_dodge = true

func _jump():
	can_jump = true

func _jump_landed():
	jumping = false

func _attacking(active):
	if active:
		can_move = false
		_impulse = 0.4
	else:
		can_move = true
		_impulse = 0.0
