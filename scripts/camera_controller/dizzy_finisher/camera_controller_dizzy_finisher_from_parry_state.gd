class_name CameraControllerDizzyFinisherFromParryState
extends CameraControllerStateMachine


@export var normal_state: CameraControllerNormalState

# used because dizzy victim becomes null
# immediately after being killed
var _saved_dizzy_victim: DizzyComponent

# whether to do the offset zoom in thing
var _dizzy_behaviour: bool = false

# used for if victim not killed
var _recently_had_dizzy_victim: bool = false

# used for if victim was killed
var _recently_killed_dizzy_victim: bool = false

# 1 offsets the camera right
# -1 offset the camera left
var _cam_right_or_left: int = 1

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


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


func process_camera() -> void:
	var dizzy_victim: DizzyComponent = dizzy_system.dizzy_victim
	
	if not dizzy_victim and (
		not _saved_dizzy_victim or \
		not _recently_had_dizzy_victim
	):
		parent_state.parent_state.change_state(
			normal_state
		)
	
	
	if dizzy_victim:
		_dizzy_behaviour = true
		_saved_dizzy_victim = dizzy_victim
		_recently_had_dizzy_victim = true
		_recently_killed_dizzy_victim = true
		
	elif not dizzy_system.victim_being_killed:
		_dizzy_behaviour = false
		
	elif _recently_killed_dizzy_victim:
		_recently_killed_dizzy_victim = false
		
		var dizzy_timer: SceneTreeTimer = get_tree().create_timer(0.5)
		dizzy_timer.timeout.connect(
			func():
				_dizzy_behaviour = false
				_saved_dizzy_victim = null
		)
	
	if _dizzy_behaviour:
		
		camera.fov = move_toward(
			camera.fov,
			65,
			2
		)
		
		camera_controller.global_position = camera_controller.global_position.lerp(
			player.global_position + Vector3(0, -0.5, 0), 
			0.05
		)
		
		camera.look_at(_saved_dizzy_victim.global_position)
		camera.global_rotation_degrees.y += _cam_right_or_left * 20
		camera.global_rotation_degrees.x -= 10
		
		camera_controller.rotation_degrees.x = lerp_angle(
			camera_controller.rotation_degrees.x,
			-35.0,
			0.05
		)
		
		var _looking_direction: Vector3 = camera_controller\
			.global_position\
			.direction_to(_saved_dizzy_victim.global_position)
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
		
	elif _recently_had_dizzy_victim:
		camera.fov = move_toward(
			camera.fov,
			camera_controller.camera_fov,
			2
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
			_recently_had_dizzy_victim = false
