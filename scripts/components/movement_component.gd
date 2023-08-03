class_name MovementComponent
extends Node3D

@export var walk_speed = 2
@export var run_speed = 5

@export var target_entity: Player
@export var rotation_component: RotationComponent

@export var gravity = 20

var move_direction = Vector3.ZERO
var desired_velocity = Vector3.ZERO

var can_move = true
var vertical_movement = false

var speed: float = 0.0
var _looking_direction = Vector3.BACK

var _secondary_movement = 0.0
var _secondary_movement_timer: Timer


func _ready():
	speed = walk_speed
	
	_secondary_movement_timer = Timer.new()
	_secondary_movement_timer.timeout.connect(_process_movement_timer)
	add_child(_secondary_movement_timer)

func _physics_process(delta):
	move_direction = rotation_component.move_direction
	_looking_direction = rotation_component.looking_direction
	
	
	if can_move:
		if move_direction.length() > 0.2:
			desired_velocity.x = lerp(desired_velocity.x, move_direction.x * speed, 0.1)
			desired_velocity.z = lerp(desired_velocity.z, move_direction.z * speed, 0.1)
		elif target_entity.is_on_floor():
			var weight = 0.15 if vertical_movement else 0.05
			desired_velocity.x = lerp(desired_velocity.x, 0.0, weight)
			desired_velocity.z = lerp(desired_velocity.z, 0.0, weight)			
	elif _secondary_movement and target_entity.is_on_floor():
		desired_velocity.x = -_looking_direction.x * _secondary_movement
		desired_velocity.z = -_looking_direction.z * _secondary_movement		
	elif target_entity.is_on_floor():
		desired_velocity.x = lerp(desired_velocity.x, 0.0, 0.1)
		desired_velocity.z = lerp(desired_velocity.z, 0.0, 0.1)
		
	
	if not target_entity.is_on_floor():
		desired_velocity.y -= gravity * delta
	elif not vertical_movement:
		desired_velocity.y = 0

		
	target_entity.velocity = desired_velocity
	target_entity.move_and_slide()


func is_running() -> bool:
	return speed == run_speed


func walk():
	speed = walk_speed
	

func run():
	speed = run_speed


func set_secondary_movement(new_speed: float, time: float):
	_secondary_movement_timer.stop()
	_secondary_movement = new_speed
	_secondary_movement_timer.start(time)


func _process_movement_timer():
	_secondary_movement = 0.0
