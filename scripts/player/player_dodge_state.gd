class_name PlayerDodgeState
extends PlayerStateMachine


@export var run_state: PlayerRunState
@export var jump_state: PlayerJumpState


func _ready():
	super._ready()


func enter():
	player.dodge_component.intent_to_dodge = true


func process_player():
	if player.holding_down_run:
		parent_state.change_state(run_state)
		return
	elif not player.dodge_component.dodging:
		parent_state.transition_to_previous_state()
		return
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
		return


func exit():
	pass

