class_name CameraControllerNormalState
extends CameraControllerStateMachine


@export var dizzy_finisher_state: CameraControllerDizzyFinisherState
@export var backstab_state: CameraControllerBackstabState


func process_camera() -> void:
	var dizzy_victim: DizzyComponent = Globals.dizzy_system.dizzy_victim
	if player.state_machine.current_state is PlayerDizzyFinisherState and \
	dizzy_victim != null:
		parent_state.change_state(
			dizzy_finisher_state
		)
	
	if Globals.backstab_system.backstab_victim != null and \
	player.state_machine.current_state is PlayerBackstabState and \
	player.state_machine.current_state.current_state is PlayerBackstabAttackState:
		parent_state.change_state(
			backstab_state
		)
	
	camera.fov = move_toward(
		camera.fov,
		camera_controller.camera_fov,
		2
	)
	
	camera_controller.global_position = camera_controller.global_position.lerp(
		player.global_position + Vector3(
			0, 
			camera_controller.vertical_offset, 
			0
		),
		0.1
	)
	
	camera.rotation = camera.rotation.lerp(Vector3.ZERO, 0.05)
