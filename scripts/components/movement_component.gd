class_name MovementComponent
extends Node3D

@export var walk_speed = 3.0
@export var run_speed = 6

@export var target_entity: Player
@export var rotation_component: RotationComponent

@export var gravity = 20

var move_direction = Vector3.ZERO
var desired_velocity = Vector3.ZERO

var can_move = true
var vertical_movement = false

var _speed: float = 0.0
var _looking_direction = Vector3.BACK
var _impulse = 0.0


func _ready():
	_speed = walk_speed
	

func _physics_process(delta):
	move_direction = rotation_component.move_direction
	
	if _impulse:
		desired_velocity = -_looking_direction * _impulse
	
	if can_move:
		desired_velocity.x = lerp(desired_velocity.x, move_direction.x * _speed, 0.1)
		desired_velocity.z = lerp(desired_velocity.z, move_direction.z * _speed, 0.1)
	
	if !target_entity.is_on_floor():
		desired_velocity.y -= gravity * delta
	elif not vertical_movement:
		desired_velocity.y = 0
		
	target_entity.velocity = desired_velocity
	target_entity.move_and_slide()


func is_running() -> bool:
	return _speed == run_speed


func speed_to_walk():
	_speed = walk_speed
	

func speed_to_run():
	_speed = run_speed
