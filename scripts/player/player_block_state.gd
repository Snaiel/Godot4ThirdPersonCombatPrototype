class_name PlayerBlockState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var attack_state: PlayerAttackState

func _ready():
	super._ready()


func enter():
	player.block_component.blocking = true


func process_player():
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if not Input.is_action_pressed("block") and \
	not player.parry_component.is_spamming():
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	player.set_rotation_target_to_lock_on_target()


func exit():
	player.block_component.blocking = false
