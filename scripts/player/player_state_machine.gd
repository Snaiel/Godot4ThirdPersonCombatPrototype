class_name PlayerStateMachine
extends Node


var current_state: PlayerStateMachine
var parent_state: PlayerStateMachine
var has_sub_states: bool = false


func change_state(new_state: PlayerStateMachine) -> void:
	if not has_sub_states:
		return
	
	new_state.enter_state_machine()
	current_state.exit_state_machine()
	current_state = new_state


func enter_state_machine() -> void:
	enter()
	
	if not has_sub_states:
		return
	
	current_state.enter_state_machine()


func process_player_state_machine() -> void:
	process_player()
	
	if not has_sub_states:
		return
	
	current_state.process_player_state_machine()


func exit_state_machine() -> void:
	exit()
	
	if not has_sub_states:
		return
	
	current_state.exit_state_machine()


func enter() -> void:
	pass


func process_player() -> void:
	pass


func exit() -> void:
	pass
