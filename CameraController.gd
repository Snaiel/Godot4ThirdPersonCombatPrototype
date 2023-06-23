class_name CameraController
extends SpringArm3D

@export var mouse_sensitivity = 10
@export var camera_angle = 10
@export var camera_fov = 75

@onready var _cam = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.camera_controller = self
	_cam.rotation_degrees.x = camera_angle
	_cam.fov = camera_fov
	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sensitivity = mouse_sensitivity * pow(10, -3)
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
func get_lock_on_position(enemy: Enemy) -> Vector2:
	var pos = _cam.unproject_position(enemy.global_position)
	return pos

func _on_player_lock_on(enemy: Enemy):
	if enemy:
		look_at(enemy.position)
