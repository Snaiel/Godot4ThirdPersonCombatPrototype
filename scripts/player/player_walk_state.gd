class_name PlayerWalkState
extends PlayerStateMachine


@export var locomotion_component: LocomotionComponent

@export var idle_state: PlayerIdleState
@export var dodge_state: PlayerDodgeState
@export var run_state: PlayerRunState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var backstab_state: PlayerBackstabState


func enter() -> void:
	player.locomotion_component.can_move = true
	locomotion_component.speed = 3


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
	
	if Globals.backstab_system.backstab_victim:
		parent_state.change_state(backstab_state)
		return
	
	if player.input_direction.length() < 0.2:
		parent_state.change_state(idle_state)
		return
	
	if run_state.holding_down_run:
		parent_state.change_state(run_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	player.rotation_component.rotate_towards_target = \
		true if player.lock_on_target else false
