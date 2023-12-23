class_name PlayerWalkState
extends PlayerStateMachine


@export var idle_state: PlayerIdleState


func enter() -> void:
	player.movement_component.speed = 3


func process_player() -> void:
	if player.input_direction.length() < 0.2:
		parent_state.change_state(idle_state)
	
	player.character.movement_animations.move(
		player.input_direction, 
		player.lock_on_target != null, 
		false
	)