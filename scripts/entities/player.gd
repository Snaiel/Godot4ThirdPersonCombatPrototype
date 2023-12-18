class_name Player
extends CharacterBody3D


@export_category("Mechanisms")
@export var character: CharacterAnimations
@export var camera_controller: CameraController
@export var movement_component: MovementComponent
@export var hitbox_component: HitboxComponent
@export var jump_component: JumpComponent
@export var block_component: BlockComponent
@export var dodge_component: DodgeComponent
@export var rotation_component: PlayerRotationComponent
@export var attack_component: AttackComponent
@export var parry_component: ParryComponent
@export var fade_component: FadeComponent

var input_direction: Vector3 = Vector3.ZERO
var last_input_on_ground: Vector3 = Vector3.ZERO

var can_move: bool = true
var running: bool = false

var can_rotate: bool = true

var lock_on_target: LockOnComponent = null

var _holding_down_run: bool = false
var _holding_down_run_timer: Timer

var _locked_on_turning_in_place: bool = false

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready() -> void:
	Globals.backstab_system.attack_component = attack_component

	attack_component.can_move.connect(_receive_can_move)
	attack_component.can_rotate.connect(_receive_can_rotate)

	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(_handle_hold_down_run_timer)
	add_child(_holding_down_run_timer)


func _physics_process(_delta: float) -> void:
	# player inputs
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	last_input_on_ground = input_direction if is_on_floor() else last_input_on_ground

	# handle rotation of the player based on camera, movement, or lock on
	var rotate_towards_target: bool = false
	# we want to rotate the player towards the target lock on entity if we are locked on (obviously).
	# We also want to rotate the player based on the where the character is moving.
	# So when it isn't locked on, it is handled by the elif block.
	# But we also want to have this behaviour at certain times while also
	# locked on. For example, when _running away from the target or when _jumping
	if lock_on_target and \
		not (running and input_direction.z > 0) and \
		not (running and jump_component.jumping):
			
		rotate_towards_target = true
	
	var backstab_victim: BackstabComponent = Globals.backstab_system.backstab_victim
	if backstab_victim:
		rotation_component.target = backstab_victim
		if attack_component.attacking:
			rotate_towards_target = true
	else:
		rotation_component.target = lock_on_target
	
	rotation_component.rotate_towards_target = rotate_towards_target
	movement_component.move_direction = rotation_component.move_direction
	
	
	fade_component.enabled = true
	
	
	var _animation_input_dir: Vector3 = input_direction
	if _locked_on_turning_in_place or (dodge_component.dodging and input_direction.length() < 0.1):
		_animation_input_dir = Vector3.FORWARD * 0.4
	
	character.movement_animations.move(_animation_input_dir, lock_on_target != null, running)
	
	var dizzy_victim: DizzyComponent = dizzy_system.dizzy_victim
	if dizzy_victim and dizzy_victim.instability_component.full_instability_from_parry:
		can_move = false
		fade_component.enabled = false
		character.parry_animations.receive_parry_finished()
		character.dizzy_animations.set_dizzy_finisher(
			true, 
			attack_component.attacking
		)
	elif not attack_component.attacking:
		can_move = true
		character.dizzy_animations.set_dizzy_finisher(
			false, 
			attack_component.attacking
		)
	
	
	if backstab_victim or dizzy_victim:
		hitbox_component.enabled = false
	else:
		hitbox_component.enabled = true
	
	
	if Input.is_action_just_pressed("block"):
		if not attack_component.attacking:
			parry_component.parry()
		elif attack_component.stop_attacking():
			parry_component.parry()
	elif Input.is_action_pressed("block"):
		if not attack_component.attacking:
			block_component.blocking = true
		elif attack_component.stop_attacking():
			block_component.blocking = true
	elif Input.is_action_just_released("block"):
		block_component.blocking = false


	if Input.is_action_just_pressed("attack"):
		if Globals.backstab_system.backstab_victim or \
			Globals.dizzy_system.dizzy_victim:
			attack_component.thrust()
		elif block_component.blocking:
			attack_component.attack(false)
		else:
			attack_component.attack()


	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		if dodge_component.can_set_intent_to_dodge and not attack_component.attacking:
			dodge_component.intent_to_dodge = true
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		_holding_down_run = false


	# start the jump animation when the jump key is pressed
	if Input.is_action_just_pressed("jump") and is_on_floor() and not attack_component.attacking:
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


func _on_hitbox_component_weapon_hit(weapon: Sword):
#	prints('bruh', weapon, weapon.get_entity())
	if parry_component.in_parry_window:
		character.parry_animations.parry()
		block_component.anim.play("parried")
		weapon.get_parried()
		print("PARRIED")
	elif block_component.blocking or parry_component.is_spamming():
		block_component.blocked()
	else:
		character.hit_and_death_animations.hit()
		movement_component.got_hit()
		
		# knockback
		var opponent_position: Vector3 = weapon.get_entity().global_position
		var direction: Vector3 = global_position.direction_to(opponent_position)
		movement_component.set_secondary_movement(weapon.get_knockback(), 5, 5, -direction)
