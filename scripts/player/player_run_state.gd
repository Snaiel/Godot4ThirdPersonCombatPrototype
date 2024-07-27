class_name PlayerRunState
extends PlayerStateMachine


@export var locomotion_component: LocomotionComponent

@export var idle_state: PlayerIdleState
@export var walk_state: PlayerWalkState
@export var jump_state: PlayerJumpState
@export var dodge_state: PlayerDodgeState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var backstab_state: PlayerBackstabState

var holding_down_run: bool = false
var _holding_down_run_timer: Timer


func _ready() -> void:
	_holding_down_run_timer = Timer.new()
	_holding_down_run_timer.timeout.connect(
		func():
			if not Input.is_action_pressed("run"): return
			holding_down_run = true
	)
	add_child(_holding_down_run_timer)


func _process(_delta: float) -> void:
	# make sure the user is actually holding down
	# the run key to make the player run
	if Input.is_action_pressed("run") and \
	_holding_down_run_timer.is_stopped():
		_holding_down_run_timer.start(0.25)
	if Input.is_action_just_released("run"):
		_holding_down_run_timer.stop()
		holding_down_run = false


func enter() -> void:
	locomotion_component.speed = 5


func process_player() -> void:
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block"):
		parent_state.change_state(block_state)
		return
	
	if Globals.backstab_system.backstab_victim:
		parent_state.change_state(backstab_state)
		return
	
	if not holding_down_run:
		parent_state.change_state(walk_state)
		return
	
	if player.input_direction.length() < 0.2:
		parent_state.change_state(idle_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	player.rotation_component.rotate_towards_target = true if (
		player.lock_on_target and player.input_direction.z <= 0
	) else false


func process_movement_animations() -> void:
	player.character.idle_animations.active = player.lock_on_target != null
	player.character.movement_animations.dir = \
		player.input_direction if player.lock_on_target else Vector3.FORWARD
	player.character.movement_animations.set_state("run")
