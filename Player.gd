class_name Player
extends CharacterBody3D

signal lock_on(enemy: Enemy)

@export var speed = 7.0
@export var jump_strength = 20.0
@export var gravity = 50.0

@export var enemy: Enemy

@onready var _camera_controller: CameraController = $CameraController
@onready var _model = $Model

var _velocity = Vector3.ZERO

var _turning = false
var _looking_direction
var _target_look

var _locked_on = false

func _ready():
	Globals.player = self

func _physics_process(delta):
	var move_direction = Vector3.ZERO
	
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _camera_controller.rotation.y).normalized()
	
	_velocity.x = move_direction.x * speed
	_velocity.z = move_direction.z * speed
	_velocity.y -= 0 if is_on_floor() else gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		_velocity.y = jump_strength
		
	velocity = _velocity
	move_and_slide()
	
	if _locked_on:
		_looking_direction = -_model.global_position.direction_to(enemy.global_position)
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
		_model.rotation.y = lerp_angle(_model.rotation.y, _target_look, 0.1)
	elif move_direction.length() > 0.2:
		_turning = true
		_looking_direction = -Vector3(_velocity.x, 0, _velocity.z)
		_target_look = atan2(_looking_direction.x, _looking_direction.z)
	
	# Makes sure the model is rotated fully to the desired direction
	# even if pressed for a short period of time
	if _turning:
		if abs(_model.rotation.y - _target_look) < 0.01:
			_turning = false
		_model.rotation.y = lerp_angle(_model.rotation.y, _target_look, 0.2)

func _process(_delta):
	_camera_controller.position = _camera_controller.position.slerp(position, 0.2)

	if Input.is_action_just_pressed("lock_on"):
		_locked_on = not _locked_on
		if _locked_on:
			lock_on.emit(enemy)
		else:
			lock_on.emit(null)
