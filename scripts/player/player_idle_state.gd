class_name PlayerIdleState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var dodge_state: PlayerDodgeState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState


func process_player() -> void:
	if player.input_direction.length() > 0:
		parent_state.change_state(walk_state)
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	if Input.is_action_just_pressed("block") and (
		not player.attack_component.attacking or \
		player.attack_component.stop_attacking()
	):
		parent_state.change_state(parry_state)
		return
	
	if Input.is_action_pressed("block") and (
		not player.attack_component.attacking or \
		player.attack_component.stop_attacking()
	):
		parent_state.change_state(block_state)
		return
	
	
	if player.lock_on_target:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false
