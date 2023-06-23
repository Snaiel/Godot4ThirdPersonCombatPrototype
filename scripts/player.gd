class_name Player
extends CharacterBody3D

@export var speed = 5.0
@export var jump_strength = 10
@export var gravity = 20

@onready var _camera_controller: CameraController = $CameraController
@onready var _model = $Model

var _velocity = Vector3.ZERO

var _turning = false
var _looking_direction
var _target_look

var _lock_on_enemy: Enemy = null

var angle = 0.0

func _ready():
	Globals.player = self
	_target_look = _camera_controller.rotation.y
	_looking_direction = Vector3.FORWARD

func _physics_process(delta):
	_model.rotation_degrees.y = wrapf(_model.rotation_degrees.y, -180, 180.0)
	
	var move_direction = Vector3.ZERO
	
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	if _lock_on_enemy:
		_looking_direction = -global_position.direction_to(_lock_on_enemy.global_position)
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
		_model.rotation.y = lerp_angle(_model.rotation.y, _target_look, 0.2)
		
		if move_direction.length() > 0.2:
			move_direction = move_direction.rotated(
				Vector3.UP, 
				_target_look + sign(move_direction.x) * 0.02
			).normalized()
	elif move_direction.length() > 0.2:
		_turning = true
		_looking_direction = -Vector3(_velocity.x, 0, _velocity.z)
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
		
		move_direction = move_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()		
	
	# Makes sure the model is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _turning:
		if abs(_model.rotation.y - _target_look) < 0.01:
			_turning = false
		_model.rotation.y = lerp_angle(_model.rotation.y, _target_look, 0.2)
	
	_velocity.x = move_direction.x * speed
	_velocity.z = move_direction.z * speed
	_velocity.y -= 0 if is_on_floor() else gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		_velocity.y = jump_strength
		
	velocity = _velocity
	move_and_slide()


func _process(_delta):
	_camera_controller.position = _camera_controller.position.slerp(position, 0.2)


func _on_lock_on_system_lock_on(enemy):
	_lock_on_enemy = enemy
	_camera_controller.lock_on(enemy)
