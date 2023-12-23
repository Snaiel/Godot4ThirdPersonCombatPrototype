class_name PlayerWalkState
extends PlayerStateMachine


@export var idle_state: PlayerIdleState
@export var dodge_state: PlayerDodgeState
@export var run_state: PlayerRunState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState


func enter() -> void:
	player.movement_component.speed = 3


func process_player() -> void:
	if player.input_direction.length() < 0.2:
		parent_state.change_state(idle_state)
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if player.holding_down_run:
		parent_state.change_state(run_state)
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	
	if player.lock_on_target:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false
