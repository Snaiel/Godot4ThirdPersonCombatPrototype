class_name CameraControllerLockedOnState
extends CameraControllerStateMachine


@export var free_look_state: CameraControllerFreeLookState


func _ready():
	lock_on_system.lock_on.connect(
		func(target: LockOnComponent):
			if target:
				return
			
			parent_state.change_state(
				free_look_state
			)
	)


func process_camera() -> void:
	var _lock_on_target: LockOnComponent = Globals.lock_on_system.target
	
	if not _lock_on_target:
		return
	
	var _looking_direction: Vector3 = camera_controller\
		.global_position\
		.direction_to(
			_lock_on_target.global_position
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
			_lock_on_target.global_position
		)
	
	var project_desired_pos: Vector3 = camera.project_position(
		Vector2(
			get_viewport().size.x/2,
			get_viewport().size.y/4
		),
		dist_to_target
	)
	
	var desired_rotation_x: float = camera_controller.rotation.x \
		+ atan2(
			_lock_on_target.global_position.y - project_desired_pos.y,
			dist_to_target
		)
	desired_rotation_x = rad_to_deg(desired_rotation_x)

	var lock_on_min_angle: float = -4.5 \
		* (player.global_position.y - _lock_on_target.global_position.y) - 35
	var lock_on_max_angle: float = 60.0

	desired_rotation_x = clamp(
		desired_rotation_x,
		lock_on_min_angle,
		lock_on_max_angle
	)
	
	camera_controller.rotation_degrees.x = lerp(
		camera_controller.rotation_degrees.x,
		desired_rotation_x,
		0.1
	)
