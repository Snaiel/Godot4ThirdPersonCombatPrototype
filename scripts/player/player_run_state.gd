class_name PlayerRunState
extends PlayerStateMachine


func enter() -> void:
	player.movement_component.speed = 5
