class_name CameraController
extends SpringArm3D


@export var player: Player

@export_category("Camera Settings")
@export var camera_distance: float = 2.0
@export var vertical_offset: float = 0.5
@export var camera_angle: float = 0.0
@export var camera_fov: float = 75.0

@export_category("Mouse Settings")
@export var mouse_sensitivity: float = 5.0

@export_category("Spin Around Speed")
## The speed the camera tries to spin around
## to be behind the player when their are not running
@export var not_running_spin_speed: float = 4.0
## The speed the camera tries to spin around 
## to be behind the player when their are running
@export var running_spin_speed: float = 5.0

@export_category("Controller Settings")
@export var controller_sensitivity: float = 14.0
@export var controller_deadzone: float = 0.2

@export_category("Lock On Settings")
@export var desired_unproject_pos: float = 175.0

var _lock_on_target: LockOnComponent = null
var _player_looking_around: bool = false

var _saved_dizzy_victim: DizzyComponent
var _dizzy_behaviour: bool = false
var _recently_had_dizzy_victim: bool = false

var locked_on: bool

@onready var dizzy_system: DizzySystem = Globals.dizzy_system
@onready var cam: Camera3D = $NormalCam


func _ready() -> void:
	
	global_position = player.global_position + Vector3(0, vertical_offset, 0)
	spring_length = camera_distance
	
	cam.fov = camera_fov
	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sensitivity = mouse_sensitivity * pow(10, -3)
	controller_sensitivity = controller_sensitivity * pow(10, -2) / 2


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("ui_text_backspace"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("attack"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	locked_on = _lock_on_target != null
	
	
	var dizzy_victim: DizzyComponent = dizzy_system.dizzy_victim
	
	if dizzy_victim and dizzy_victim.instability_component.full_instability_from_parry:
		_dizzy_behaviour = true
		_saved_dizzy_victim = dizzy_victim
		_recently_had_dizzy_victim = true
	elif not dizzy_system.dizzy_victim_killed:
		_dizzy_behaviour = false
	elif _recently_had_dizzy_victim:
		_recently_had_dizzy_victim = false
		var dizzy_timer: SceneTreeTimer = get_tree().create_timer(0.5)
		dizzy_timer.timeout.connect(
			func():
				_dizzy_behaviour = false
				_saved_dizzy_victim = null
		)
	
	if _dizzy_behaviour:
		
		cam.fov = 60
		global_position = global_position.lerp(
			player.global_position + Vector3(0, -0.5, 0), 
			0.1
		)
		
		cam.look_at(_saved_dizzy_victim.global_position)
		cam.global_rotation_degrees.y += 15
		cam.global_rotation_degrees.x -= 10
		
		var _looking_direction: Vector3 = -global_position.direction_to(_saved_dizzy_victim.global_position)
		var _target_look: float = atan2(_looking_direction.x, _looking_direction.z)
		_target_look += deg_to_rad(80)
		
		var desired_rotation_y: float = lerp_angle(rotation.y, _target_look, 0.2)
		rotation.y = desired_rotation_y
		
	else:
		cam.fov = move_toward(
			cam.fov,
			camera_fov,
			2
		)
		
		global_position = global_position.lerp(
			player.global_position + Vector3(0, vertical_offset, 0),
			 0.1
		)
		
		cam.rotation = cam.rotation.lerp(Vector3.ZERO, 0.05)
	
	
	if _lock_on_target:
		var _looking_direction: Vector3 = -global_position.direction_to(_lock_on_target.global_position)
		var _target_look: float = atan2(_looking_direction.x, _looking_direction.z)
		var desired_rotation_y: float = lerp_angle(rotation.y, _target_look, 0.05)
		rotation.y = lerp(rotation.y, desired_rotation_y, 0.8)

		var dist_to_target: float = cam.global_position.distance_to(_lock_on_target.global_position)
		var project_desired_pos: Vector3 = cam.project_position(
			Vector2(
				get_viewport().size.x/2,
				get_viewport().size.y/4
			),
			dist_to_target
		)
		var desired_rotation_x: float = rotation.x + atan2(_lock_on_target.global_position.y - project_desired_pos.y, dist_to_target)
		desired_rotation_x = rad_to_deg(desired_rotation_x)
		
		var lock_on_min_angle: float = -4.5 * (player.global_position.y - _lock_on_target.global_position.y) - 35
		var lock_on_max_angle: float = 60.0
		
		desired_rotation_x = clamp(desired_rotation_x, lock_on_min_angle, lock_on_max_angle)
		rotation_degrees.x = lerp(rotation_degrees.x, desired_rotation_x, 0.1)

	else:
		var controller_look: Vector2 = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		)

		if controller_look.length() > controller_deadzone:

			var new_rotation_x: float = rotation.x - controller_look.y * controller_sensitivity
			rotation.x = lerp(rotation.x, new_rotation_x, 0.8)
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)

			var new_rotation_y: float = rotation.y - controller_look.x * controller_sensitivity
			rotation.y = lerp(rotation.y, new_rotation_y, 0.8)
			rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _lock_on_target:
		_player_looking_around = true

		var new_rotation_x: float = rotation.x - event.relative.y * mouse_sensitivity
		rotation.x = lerp(rotation.x, new_rotation_x, 0.8)
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)

		var new_rotation_y: float = rotation.y - event.relative.x * mouse_sensitivity
		rotation.y = lerp(rotation.y, new_rotation_y, 0.8)
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	else:
		_player_looking_around = false


func player_moving(move_direction: Vector3, running: bool, delta: float) -> void:
	if not _player_looking_around:
		var new_rotation: float
		if running:
			new_rotation = rotation.y - sign(move_direction.x) * delta * running_spin_speed		
		else:
			new_rotation = rotation.y - sign(move_direction.x) * delta * not_running_spin_speed		
		rotation.y = lerp(rotation.y, new_rotation, 0.3)


func get_lock_on_position(target: Node3D) -> Vector2:
	var pos = cam.unproject_position(target.global_position)
	return pos


func lock_on(target: LockOnComponent) -> void:
	_lock_on_target = target
