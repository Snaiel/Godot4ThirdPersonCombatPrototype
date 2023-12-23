class_name PlayerIdleState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var dodge_state: PlayerDodgeState
@export var jump_state: PlayerJumpState

func process_player() -> void:
	if player.input_direction.length() > 0:
		parent_state.change_state(walk_state)
	
	if player.dodge_component.intent_to_dodge:
		parent_state.change_state(dodge_state)
	
	if Input.is_action_just_pressed("jump") and \
	player.is_on_floor():
		parent_state.change_state(jump_state)
	
	if player.lock_on_target:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false
