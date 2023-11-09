class_name Player
extends CharacterBody3D

@export_category("Mechanisms")
@export var character: PlayerAnimations
@export var camera_controller: CameraController
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var block_component: BlockComponent
@export var dodge_component: DodgeComponent
@export var rotation_component: PlayerRotationComponent
@export var attack_component: AttackComponent

var input_direction: Vector3 = Vector3.ZERO

var can_move: bool = true
var running: bool = false

var can_rotate: bool = true

var lock_on_target: LockOnComponent = null

var _holding_down_run: bool = false
var _holding_down_run_timer: Timer

var _locked_on_turning_in_place: bool = false

func _ready() -> void:
	Globals.player = self

	attack_component.can_move.connect(_receive_can_move)
	attack_component.can_rotate.connect(_receive_can_rotate)

	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(_handle_hold_down_run_timer)
	add_child(_holding_down_run_timer)

func _physics_process(_delta: float) -> void:
	# player inputs
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")




	# handle rotation of the player based on camera, movement, or lock on
	var rotate_towards_target: bool = false
	# we want to rotate the player towards the target lock on entity if we are locked on (obviously).
	# We also want to rotate the player based on the where the character is moving.
	# So when it isn't locked on, it is handled by the elif block.
	# But we also want to have this behaviour at certain times while also
	# locked on. For example, when _running away from the target or when _jumping
	if lock_on_target and not (running and input_direction.z > 0) and not (running and jump_component.jumping):
		rotate_towards_target = true

	rotation_component.rotate_towards_target = rotate_towards_target
	movement_component.move_direction = rotation_component.move_direction

	if _locked_on_turning_in_place or (dodge_component.dodging and input_direction.length() < 0.1):
		input_direction = Vector3.FORWARD * 0.4

	character.movement_animations.move(input_direction, lock_on_target != null, running)


	if Input.is_action_pressed("block"):
		if attack_component.attacking:
			block_component.blocking = attack_component.stop_attacking()
		else:
			block_component.blocking = true
	elif Input.is_action_just_released("block"):
		block_component.blocking = false


	if Input.is_action_just_pressed("attack"):
		if block_component.blocking:
			attack_component.attack(false)
		else:
			attack_component.attack()


	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		if dodge_component.can_set_intent_to_dodge:
			dodge_component.intent_to_dodge = true
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		_holding_down_run = false


	# start the jump animation when the jump key is pressed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_component.start_jump()

	if not block_component.blocking:
		if (_holding_down_run and is_on_floor() and not dodge_component.dodging) or (jump_component.jumping and not is_on_floor() and movement_component.speed == 5):
			# change to running speed if pressing the run button
			# or keep running speed in the air
			movement_component.speed = 5
			running = true
		else:
			# walking speed for everything else
			if jump_component.jumping and not is_on_floor():
				movement_component.speed = 3.5
			else:
				movement_component.speed = 3
			running = false
	else:
		running = false

	movement_component.can_move = can_move


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	lock_on_target = target
	camera_controller.lock_on(target)
	if input_direction.length() < 0.1 and target and rotation_component.get_lock_on_rotation_difference() > 0.1:
		var diff: float = rotation_component.get_lock_on_rotation_difference()
		_locked_on_turning_in_place = true
		character.movement_animations.locked_on_turning_in_place = true
		var duration: float = clamp(diff / PI * 0.18, 0.1, 0.18)
		var pressed_lock_on_timer: SceneTreeTimer = get_tree().create_timer(duration)
		pressed_lock_on_timer.timeout.connect(_handle_pressed_lock_on_timer)


func _handle_pressed_lock_on_timer() -> void:
	character.movement_animations.locked_on_turning_in_place = false
	_locked_on_turning_in_place = false


func _receive_can_move(flag: bool) -> void:
	can_move = flag


func _receive_can_rotate(flag: bool) -> void:
	can_rotate = flag


func _handle_hold_down_run_timer():
	_holding_down_run = true
