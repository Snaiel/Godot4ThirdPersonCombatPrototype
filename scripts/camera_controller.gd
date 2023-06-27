class_name CameraController
extends SpringArm3D

@export_category("Camera Settings")
@export var autonomous_speed = 5
@export var mouse_sensitivity = 10
@export var camera_angle = 10
@export var camera_fov = 75

@export_category("Lock On Settings")
@export var lock_on_min_angle = 35
@export var lock_on_max_angle = 50
@export var lock_on_min_distance = 1
@export var lock_on_max_distance = 10

var _lock_on_enemy: Enemy = null
var _player_looking_around = false

@onready var _cam = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.camera_controller = self
	_cam.rotation_degrees.x = camera_angle
	_cam.fov = camera_fov
	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sensitivity = mouse_sensitivity * pow(10, -3)
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	if _lock_on_enemy:
		var _looking_direction = -global_position.direction_to(_lock_on_enemy.position)
		var _target_look = atan2(_looking_direction.x, _looking_direction.z)
		var desired_rotation_y = lerp_angle(rotation.y, _target_look, 0.05)

		var clamped_distance = clamp(position.distance_to(_lock_on_enemy.position), lock_on_min_distance, lock_on_max_distance)
		var normalized_distance = (clamped_distance - lock_on_min_distance) / (lock_on_max_distance - lock_on_min_distance)
		normalized_distance = smoothstep(0.0, 1.0, normalized_distance)
		var angle = lerp(lock_on_max_angle, lock_on_min_angle, normalized_distance)
		var desired_rotation_x = deg_to_rad(-angle)
		
		rotation.y = lerp(rotation.y, desired_rotation_y, 0.8)
		rotation.x = lerp(rotation.x, desired_rotation_x, 0.05)
		
func _unhandled_input(event):
	if event is InputEventMouseMotion and not _lock_on_enemy:
		_player_looking_around = true
		var new_rotation_x = rotation.x - event.relative.y * mouse_sensitivity
		rotation.x = lerp(rotation.x, new_rotation_x, 0.8)
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		var new_rotation_y = rotation.y - event.relative.x * mouse_sensitivity
		rotation.y = lerp(rotation.y, new_rotation_y, 0.8)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	else:
		_player_looking_around = false
		
func player_moving(move_direction: Vector3, delta):
	if not _player_looking_around:
		var new_rotation = rotation.y - sign(move_direction.x) * delta * autonomous_speed
		rotation.y = lerp(rotation.y, new_rotation, 0.2)

func get_lock_on_position(enemy: Enemy) -> Vector2:
	var pos = _cam.unproject_position(enemy.global_position)
	return pos

func lock_on(enemy: Enemy):
	_lock_on_enemy = enemy
