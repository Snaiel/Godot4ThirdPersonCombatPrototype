class_name PlayerIdleState
extends PlayerStateMachine


@export var walk_state: PlayerWalkState
@export var dodge_state: PlayerDodgeState


func process_player() -> void:
	if player.input_direction.length() > 0:
		parent_state.change_state(walk_state)
	
	if player.dodge_component.intent_to_dodge:
		parent_state.change_state(dodge_state)
	
	if player.lock_on_target:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false
