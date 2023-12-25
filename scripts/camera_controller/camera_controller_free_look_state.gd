class_name CameraControllerFreeLookState
extends CameraControllerStateMachine


@export var lock_on_state: CameraControllerLockedOnState

var _mouse_moving: bool = false
var _joystick_moving: bool = false


func _ready():
	super._ready()
	
	lock_on_system.lock_on.connect(
		func(target: LockOnComponent):
			if not target:
				return
			
			parent_state.change_state(
				lock_on_state
			)
	)


func process_camera() -> void:
	var controller_look: Vector2 = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)

	if controller_look.length() > camera_controller.controller_deadzone:
		
		_joystick_moving = true
		
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
		
	else:
		
		_joystick_moving = false
	
	if _mouse_moving or _joystick_moving:
		camera_controller.looking_around = true
	else:
		camera_controller.looking_around = false


func process_unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		_mouse_moving = false
		return
	
	_mouse_moving = true
	
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
