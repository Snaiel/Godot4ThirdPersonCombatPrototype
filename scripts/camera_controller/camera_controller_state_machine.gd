class_name CameraControllerStateMachine
extends Node


var current_state: CameraControllerStateMachine

@export var camera_controller: CameraController
@export var camera: Camera3D


func change_state(new_state: CameraControllerStateMachine) -> void:
	current_state.enter_state_machine()
	new_state.exit_state_machine()
	current_state = new_state


func enter_state_machine() -> void:
	_enter()
	current_state.enter_state_machine()


func process_camera_state() -> void:
	_process_camera_state()
	current_state.process_camera_state()


func process_unhandled_input(event: InputEvent) -> void:
	_process_unhandled_input(event)
	current_state.process_unhandled_input(event)


func exit_state_machine() -> void:
	_exit()
	current_state.exit_state_machine()


func _enter() -> void:
	pass


func _process_camera_state() -> void:
	pass


func _process_unhandled_input(_event: InputEvent) -> void:
	pass


func _exit() -> void:
	pass
