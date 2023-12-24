class_name PlayerBlockState
extends PlayerStateMachine


func _ready():
	super._ready()


func enter():
	player.block_component.blocking = true


func process_player():
	if Input.is_action_just_released("block"):
		parent_state.transition_to_default_state()


func exit():
	player.block_component.blocking = false
