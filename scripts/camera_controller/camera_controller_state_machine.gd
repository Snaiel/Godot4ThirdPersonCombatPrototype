class_name CameraControllerStateMachine
extends Node


@export var camera_controller: CameraController
@export var camera: Camera3D

var current_state: CameraControllerStateMachine
var has_sub_states: bool = false

@onready var player: Player =  Globals.player


func _ready():
	if get_child_count() > 0:
		has_sub_states = true
	else:
		return
	
	var default_state: CameraControllerStateMachine = get_child(0)
	default_state.enter_state_machine()
	current_state = default_state


func change_state(new_state: CameraControllerStateMachine) -> void:
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


func process_camera_state_machine() -> void:
	process_camera()
	
	if not has_sub_states:
		return
	
	current_state.process_camera_state_machine()


func process_unhandled_input_state_machine(event: InputEvent) -> void:
	process_unhandled_input(event)
	
	if not has_sub_states:
		return
	
	current_state.process_unhandled_input_state_machine(event)


func exit_state_machine() -> void:
	exit()
	
	if not has_sub_states:
		return
	
	current_state.exit_state_machine()


func enter() -> void:
	pass


func process_camera() -> void:
	pass


func process_unhandled_input(_event: InputEvent) -> void:
	pass


func exit() -> void:
	pass
