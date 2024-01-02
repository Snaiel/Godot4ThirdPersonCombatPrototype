class_name CameraControllerBackstabState
extends CameraControllerStateMachine


@export var normal_state: CameraControllerNormalState

# used because backstab victim becomes null
# immediately after being killed
var _saved_backstab_victim: BackstabComponent

# whether to do the offset zoom in thing
var _backstab_behaviour: bool = false

# 1 offsets the camera right
# -1 offset the camera left
var _cam_right_or_left: int = 1

var _before_transition_out_timer: Timer
var _before_transition_out_length: float = 0.5

var _late_transition_timer: Timer
var _late_transition_length: float = 0.5

@onready var backstab_system: BackstabSystem = Globals.backstab_system


func _ready():
	super._ready()
	
	_before_transition_out_timer = Timer.new()
	_before_transition_out_timer.autostart = false
	_before_transition_out_timer.one_shot = true
	_before_transition_out_timer.wait_time = _before_transition_out_length
	_before_transition_out_timer.timeout.connect(
		func():
			_backstab_behaviour = false
	)
	add_child(_before_transition_out_timer)
	
	_late_transition_timer = Timer.new()
	_late_transition_timer.autostart = false
	_late_transition_timer.one_shot = true
	_late_transition_timer.wait_time = _late_transition_length
	_late_transition_timer.timeout.connect(
		func():
			_saved_backstab_victim = null
	)
	add_child(_late_transition_timer)


func enter() -> void:
	var diff_in_rotation: float = wrapf(
		camera_controller.rotation_degrees.y - player.rotation_degrees.y, 
		0.0, 
		360.0
	)
	
	if 182 < diff_in_rotation and diff_in_rotation < 345:
		_cam_right_or_left = -1
	else:
		_cam_right_or_left = 1
	
	_before_transition_out_timer.stop()
	_late_transition_timer.stop()


func process_camera() -> void:
	var backstab_victim: BackstabComponent = backstab_system.backstab_victim
	
	if backstab_victim:
		_backstab_behaviour = true
		_saved_backstab_victim = backstab_victim
	elif _before_transition_out_timer.is_stopped():
		_before_transition_out_timer.start()
	
	if not _saved_backstab_victim:
		parent_state.change_state(
			normal_state
		)
		return
	
	if _backstab_behaviour:
		
		camera.fov = move_toward(
			camera.fov,
			65,
			1
		)
		
		camera_controller.global_position = camera_controller.global_position.lerp(
			player.global_position + Vector3(0, -0.5, 0), 
			0.05
		)
		
		camera.look_at(_saved_backstab_victim.global_position)
		camera.global_rotation_degrees.y += _cam_right_or_left * 20
		camera.global_rotation_degrees.x -= 10
		
		camera_controller.rotation_degrees.x = lerp_angle(
			camera_controller.rotation_degrees.x,
			-35.0,
			0.05
		)
		
		var _looking_direction: Vector3 = camera_controller\
			.global_position\
			.direction_to(_saved_backstab_victim.global_position)
		_looking_direction = -_looking_direction
		
		var _target_look: float = atan2(
			_looking_direction.x,
			_looking_direction.z
		
		)
		_target_look += _cam_right_or_left * deg_to_rad(90)
		
		var desired_rotation_y: float = lerp_angle(
			camera_controller.rotation.y, 
			_target_look, 
			0.1
		)
		
		camera_controller.rotation.y = desired_rotation_y
		
	else:
		
		if _late_transition_timer.is_stopped():
			_late_transition_timer.start()
		
		camera.fov = move_toward(
			camera.fov,
			camera_controller.camera_fov,
			0.5
		)
		
		camera_controller.global_position = camera_controller\
			.global_position\
			.lerp(
				player.global_position + Vector3(
					0,
					camera_controller.vertical_offset,
					0
				),
				0.1
			)
		
		camera.rotation = camera.rotation.lerp(Vector3.ZERO, 0.1)
		
		camera_controller.rotation.y = lerp_angle(
			camera_controller.rotation.y,
			player.rotation.y,
			0.1
		)
		
		if abs(
			camera_controller.rotation.y \
				- player.rotation.y
		) < 0.05:
			_saved_backstab_victim = null
