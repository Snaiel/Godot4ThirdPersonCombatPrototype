class_name CameraController
extends SpringArm3D

@export var player: Player

@export var event_label: Label

@export_category("Camera Settings")
@export var camera_distance = 2
@export var vertical_offset = 0.5
@export var camera_angle = 0
@export var camera_fov = 75
@export var autonomous_speed = 3

@export_category("Mouse Settings")
@export var mouse_sensitivity = 10

@export_category("Controller Settings")
@export var controller_sensitivity = 10
@export var controller_deadzone = 0.2

@export_category("Lock On Settings")
@export var lock_on_min_angle = 20.0
@export var lock_on_max_angle = 35.0
@export var lock_on_min_distance = 1
@export var lock_on_max_distance = 10

var _lock_on_target: LockOnComponent = null
var _player_looking_around = false
var _temp_lock_on_min_angle: float
var _temp_lock_on_max_angle: float

var locked_on: bool

@onready var cam = $NormalCam



# Called when the node enters the scene tree for the first time.
func _ready():
	position = player.position + Vector3(0, vertical_offset, 0)
	spring_length = camera_distance
	
	Globals.camera_controller = self
	cam.rotation_degrees.x = camera_angle
	cam.fov = camera_fov
	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sensitivity = mouse_sensitivity * pow(10, -3)
	controller_sensitivity = controller_sensitivity * pow(10, -2) / 2
	
	_temp_lock_on_min_angle = lock_on_min_angle
	_temp_lock_on_max_angle = lock_on_max_angle	
	
func _physics_process(_delta):
	locked_on = _lock_on_target != null
	position = position.lerp(player.position + Vector3(0, vertical_offset, 0), 0.1)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	var dist = cam.global_position.distance_to(player.global_position)
		
	if dist < 1.5 or (locked_on and dist < 1.5):
		lock_on_max_angle = lerp(lock_on_max_angle, 10.0, 0.1)
		lock_on_min_angle = lerp(lock_on_min_angle, 10.0, 0.1)		
	else:
		lock_on_max_angle = lerp(lock_on_max_angle, _temp_lock_on_max_angle, 0.1)
		lock_on_min_angle = lerp(lock_on_min_angle, _temp_lock_on_min_angle, 0.1)				
		
	if _lock_on_target:
		var _looking_direction = -global_position.direction_to(_lock_on_target.global_position)
		var _target_look = atan2(_looking_direction.x, _looking_direction.z)
		var desired_rotation_y = lerp_angle(rotation.y, _target_look, 0.05)

		var clamped_distance = clamp(position.distance_to(_lock_on_target.global_position), lock_on_min_distance, lock_on_max_distance)
		var normalized_distance = (clamped_distance - lock_on_min_distance) / (lock_on_max_distance - lock_on_min_distance)
		normalized_distance = smoothstep(0.0, 1.0, normalized_distance)
		var angle = lerp(lock_on_max_angle, lock_on_min_angle, normalized_distance)
		var desired_rotation_x = deg_to_rad(-angle)
		
		rotation.y = lerp(rotation.y, desired_rotation_y, 0.8)
		rotation.x = lerp(rotation.x, desired_rotation_x, 0.05)
	else:
		var controller_look = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		)	
		
		if controller_look.length() > controller_deadzone:
			event_label.text = str(controller_look)
			
			var new_rotation_x = rotation.x - controller_look.y * controller_sensitivity
			rotation.x = lerp(rotation.x, new_rotation_x, 0.8)
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
			
			var new_rotation_y = rotation.y - controller_look.x * controller_sensitivity
			rotation.y = lerp(rotation.y, new_rotation_y, 0.8)
			rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
			
			event_label.text = event_label.text + "\n" + str(new_rotation_x)
			event_label.text = event_label.text + "\n" + str(new_rotation_y)			
		
func _unhandled_input(event):
	if event is InputEventMouseMotion and not _lock_on_target:
		_player_looking_around = true

		var new_rotation_x = rotation.x - event.relative.y * mouse_sensitivity
		rotation.x = lerp(rotation.x, new_rotation_x, 0.8)
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		var new_rotation_y = rotation.y - event.relative.x * mouse_sensitivity
		rotation.y = lerp(rotation.y, new_rotation_y, 0.8)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
		event_label.text = str(new_rotation_x)
		event_label.text = event_label.text + "\n" + str(new_rotation_y)
	else:
		_player_looking_around = false
		
func player_moving(move_direction: Vector3, delta):
	if not _player_looking_around:
		var new_rotation = rotation.y - sign(move_direction.x) * delta * autonomous_speed
		rotation.y = lerp(rotation.y, new_rotation, 0.2)

func get_lock_on_position(target: LockOnComponent) -> Vector2:
	var pos = cam.unproject_position(target.global_position)
	return pos

func lock_on(target: LockOnComponent):
	_lock_on_target = target
