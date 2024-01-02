class_name Player
extends CharacterBody3D


@export_category("Mechanisms")
@export var state_machine: PlayerStateMachine
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
@export var weapon: Sword

var input_direction: Vector3 = Vector3.ZERO
var last_input_on_ground: Vector3 = Vector3.ZERO

var lock_on_target: LockOnComponent = null
var locked_on_turning_in_place: bool = false

var holding_down_run: bool = false
var _holding_down_run_timer: Timer

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready() -> void:
	Globals.backstab_system.attack_component = attack_component

	attack_component.can_rotate.connect(
		func(flag: bool):
			rotation_component.can_rotate = flag
	)

	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(
		func():
			holding_down_run = true
	)
	add_child(_holding_down_run_timer)
	
	state_machine.enter_state_machine()


func _physics_process(_delta: float) -> void:
	state_machine.process_player_state_machine()
	state_machine.process_movement_animations_state_machine()
	
	# player inputs
	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")

	last_input_on_ground = input_direction if is_on_floor() else last_input_on_ground
	
	movement_component.move_direction = rotation_component.move_direction
	
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_just_pressed("run"):
		_holding_down_run_timer.start(0.1)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		holding_down_run = false


func set_rotation_target_to_lock_on_target() -> void:
	rotation_component.target = lock_on_target


func process_default_movement_animations() -> void:
	var dir: Vector3 = input_direction
	var lock_on: bool = lock_on_target != null
	
	if movement_component.has_secondary_movement():
		dir = Vector3.ZERO
		lock_on = true
	
	character.movement_animations.move(
		dir,
		lock_on, 
		false
	)


func _on_lock_on_system_lock_on(target: LockOnComponent) -> void:
	lock_on_target = target
