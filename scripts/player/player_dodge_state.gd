class_name PlayerDodgeState
extends PlayerStateMachine


@export var movement_state: PlayerMovementState
@export var run_state: PlayerRunState
@export var jump_state: PlayerJumpState


func _ready():
	super._ready()
	


func enter():
	pass


func process_player():
	if movement_state.holding_down_run:
		parent_state.change_state(run_state)
	elif not player.dodge_component.dodging:
		parent_state.transition_to_previous_state()
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)


func exit():
	pass

