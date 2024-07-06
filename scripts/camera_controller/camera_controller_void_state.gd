class_name CameraControllersVoidState
extends CameraControllerStateMachine


func _ready():
	super._ready()
	
	Globals.void_death_system.fallen_into_the_void.connect(
		func(body: Node3D):
			if body is Player:
				parent_state.change_state(self)
	)


func enter() -> void:
	pass


func process_camera() -> void:
	camera.fov = move_toward(
		camera.fov,
		camera_controller.camera_fov,
		2
	)
	
	var _player: Player = Globals.player
	
	var _looking_direction: Vector3 = camera_controller\
		.global_position\
		.direction_to(
			_player.global_position
		)
	_looking_direction = -_looking_direction
	
	var _target_look: float = atan2(
		_looking_direction.x,
		_looking_direction.z
	)
	
	var desired_rotation_y: float = lerp_angle(
		camera_controller.rotation.y,
		_target_look,
		0.05
	)
	
	camera_controller.rotation.y = lerp(
		camera_controller.rotation.y,
		desired_rotation_y,
		0.8
	)

	var dist_to_target: float = camera\
		.global_position\
		.distance_to(
			_player.global_position
		)
	
	var project_desired_pos: Vector3 = camera.project_position(
		Vector2(
			get_viewport().size.x / 2,
			get_viewport().size.y / 2
		),
		dist_to_target
	)
	
	var desired_rotation_x: float = camera_controller.rotation.x \
		+ atan2(
			_player.global_position.y - project_desired_pos.y,
			dist_to_target
		)
	desired_rotation_x = rad_to_deg(desired_rotation_x)
	
	camera_controller.rotation_degrees.x = lerp(
		camera_controller.rotation_degrees.x,
		desired_rotation_x,
		0.1
	)


func process_unhandled_input(_event: InputEvent) -> void:
	pass


func exit() -> void:
	pass

