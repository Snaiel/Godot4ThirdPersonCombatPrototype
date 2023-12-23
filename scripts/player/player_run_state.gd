class_name PlayerRunState
extends PlayerStateMachine


func enter() -> void:
	player.movement_component.speed = 5


func process_player() -> void:
	if player.lock_on_target and player.input_direction.z <= 0:
		player.rotation_component.rotate_towards_target = true
	else:
		player.rotation_component.rotate_towards_target = false
