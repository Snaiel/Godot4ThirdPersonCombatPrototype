class_name CameraController
extends SpringArm3D


@export var enabled: bool = true

@export_category("Camera Settings")
@export var camera_distance: float = 2.0
@export var vertical_offset: float = 1.5
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

var looking_around: bool

@onready var player: Player = Globals.player
@onready var dizzy_system: DizzySystem = Globals.dizzy_system
@onready var cam: Camera3D = $Camera3D
@onready var state_machine: CameraControllerStateMachine = $StateMachine


func _ready() -> void:
	top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	global_position = player.global_position + Vector3(
		0,
		vertical_offset,
		0
	)
	
	spring_length = camera_distance
	
	cam.fov = camera_fov
	
	mouse_sensitivity = mouse_sensitivity * pow(10, -3)
	controller_sensitivity = controller_sensitivity * pow(10, -2) / 2
	
	state_machine.enter_state_machine()


func _physics_process(_delta: float) -> void:
#	print(state_machine.current_state)
	
	if not enabled:
		return
	
	state_machine.process_camera_state_machine()


func _unhandled_input(event: InputEvent) -> void:
	
	if not enabled:
		return
	
	state_machine.process_unhandled_input_state_machine(event)


func player_moving(move_direction: Vector3, running: bool, delta: float) -> void:
	if not looking_around:
		var new_rotation: float
		if running:
			new_rotation = rotation.y - sign(move_direction.x) * delta * running_spin_speed		
		else:
			new_rotation = rotation.y - sign(move_direction.x) * delta * not_running_spin_speed		
		rotation.y = lerp(rotation.y, new_rotation, 0.3)


func get_lock_on_position(target: Node3D) -> Vector2:
	var pos = cam.unproject_position(target.global_position)
	return pos
