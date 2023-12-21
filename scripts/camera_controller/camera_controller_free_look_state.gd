class_name CameraControllerFreeLookState
extends CameraControllerStateMachine


func process_camera() -> void:
	var controller_look: Vector2 = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)

	if controller_look.length() > camera_controller.controller_deadzone:

		var new_rotation_x: float = camera_controller.rotation.x \
			- controller_look.y \
			* camera_controller.controller_sensitivity
		
		camera_controller.rotation.x = lerp(
			camera_controller.rotation.x, 
			new_rotation_x, 
			0.8
		)
		
		camera_controller.rotation_degrees.x = clamp(
			camera_controller.rotation_degrees.x, 
			-90.0, 
			30.0
		)

		var new_rotation_y: float = camera_controller.rotation.y \
			- controller_look.x \
			* camera_controller.controller_sensitivity
		
		camera_controller.rotation.y = lerp(
			camera_controller.rotation.y, 
			new_rotation_y, 
			0.8
		)
		
		camera_controller.rotation_degrees.y = wrapf(
			camera_controller.rotation_degrees.y, 
			0.0, 
			360.0
		)


func process_unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	var new_rotation_x: float = camera_controller.rotation.x \
		- event.relative.y * camera_controller.mouse_sensitivity
	
	camera_controller.rotation.x = lerp(
		camera_controller.rotation.x, 
		new_rotation_x, 
		0.8
	)
	
	camera_controller.rotation_degrees.x = clamp(
		camera_controller.rotation_degrees.x, 
		-90.0, 
		30.0
	)

	var new_rotation_y: float = camera_controller.rotation.y \
		- event.relative.x * camera_controller.mouse_sensitivity
	
	camera_controller.rotation.y = lerp(
		camera_controller.rotation.y, 
		new_rotation_y, 
		0.8
	)
	
	camera_controller.rotation_degrees.y = wrapf(
		camera_controller.rotation_degrees.y, 
		0.0, 
		360.0
	)
