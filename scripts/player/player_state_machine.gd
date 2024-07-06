class_name PlayerStateMachine
extends Node


@export var player: Player

var current_state: PlayerStateMachine
var previous_state: PlayerStateMachine
var parent_state: PlayerStateMachine
var default_state: PlayerStateMachine
var has_sub_states: bool = false


func _ready() -> void:
	if get_child_count() > 0:
		has_sub_states = true
	else:
		return
	
	default_state = get_child(0)
	current_state = default_state
	
	for child in get_children():
		var sub_state: PlayerStateMachine = child
		sub_state.parent_state = self


func change_state(new_state: PlayerStateMachine) -> void:
#	prints(current_state, new_state)
	if not has_sub_states:
		return
	
	current_state.exit_state_machine()
	previous_state = current_state
	new_state.enter_state_machine()
	current_state = new_state


func transition_to_default_state() -> void:
	if not default_state:
		return
	
	change_state(default_state)


func transition_to_previous_state() -> void:
	if not previous_state:
		return
	
	change_state(previous_state)


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


func process_movement_animations_state_machine() -> void:
	if has_sub_states:
		current_state.process_movement_animations_state_machine()
	else:
		process_movement_animations()


func exit_state_machine() -> void:
	exit()
	
	if not has_sub_states:
		return
	
	current_state.exit_state_machine()


func enter() -> void:
	pass


func process_player() -> void:
	pass


func process_movement_animations() -> void:
	player.process_default_movement_animations()


func exit() -> void:
	pass
