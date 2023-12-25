class_name PlayerBackstabState
extends PlayerStateMachine


@export var dodge_state: PlayerDodgeState
@export var jump_state: PlayerJumpState
@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState


func _ready():
	super._ready()


func enter():
	pass


func process_player():
	var victim: = Globals.backstab_system.backstab_victim
	if victim:
		player.rotation_component.target = victim
	else:
		player.set_rotation_target_to_lock_on_target()
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		player.rotation_component.rotate_towards_target = true
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
	
	if not Globals.backstab_system.backstab_victim:
		parent_state.transition_to_previous_state()


func exit():
	pass
