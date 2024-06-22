class_name MotionComponent
extends Node3D


@export var debug: bool = false
@export var enabled: bool = true

@export var entity: CharacterBody3D
@export var rotation_component: RotationComponent
@export var gravity: float = 20.0

var looking_direction: Vector3 = Vector3.FORWARD
var move_direction: Vector3 = Vector3.ZERO
var desired_velocity: Vector3 = Vector3.ZERO

var can_move: bool = true

var vertical_movement: bool = false
var can_disable_vertical_movement: bool = false

var secondary_movement_direction: Vector3
var secondary_movement_speed: float = 0.0
var secondary_movement_friction: float = 0.0
var secondary_movement_timer: Timer


func _ready() -> void:
	secondary_movement_timer = Timer.new()
	secondary_movement_timer.timeout.connect(reset_secondary_movement)
	add_child(secondary_movement_timer)


func _physics_process(delta):
	
	if not enabled:
		return
	
	handle_movement(delta)
	handle_secondary_movement(delta)
	
	if not can_move and \
	is_zero_approx(secondary_movement_speed) and \
	entity.is_on_floor():
		desired_velocity.x = move_toward(desired_velocity.x, 0.0, 0.5)
		desired_velocity.z = move_toward(desired_velocity.z, 0.0, 0.5)

	if not entity.is_on_floor():
		desired_velocity.y -= gravity * delta
	elif not vertical_movement:
		desired_velocity.y = 0

	entity.velocity = desired_velocity
	entity.move_and_slide()


func handle_movement(_delta: float) -> void:
	# this gets overridden 
	pass


func handle_secondary_movement(delta: float) -> void:
	if secondary_movement_speed > 0.0 and entity.is_on_floor():
		desired_velocity.x = secondary_movement_direction.x * secondary_movement_speed
		desired_velocity.z = secondary_movement_direction.z * secondary_movement_speed
		secondary_movement_speed -= secondary_movement_friction * delta
	
	if secondary_movement_speed < 0.0:
		secondary_movement_speed = 0


func has_secondary_movement() -> bool:
	return secondary_movement_speed > 0


func set_secondary_movement(secondary_speed: float, time: float, friction: float = 0.0, direction: Vector3 = Vector3.ZERO) -> void:
	secondary_movement_timer.stop()
	secondary_movement_friction = friction
	
	if direction == Vector3.ZERO:
		secondary_movement_direction = Vector3.FORWARD.rotated(
			Vector3.UP,
			entity.rotation.y
		)
	else:
		secondary_movement_direction = direction
	secondary_movement_direction = secondary_movement_direction.normalized()
	
	secondary_movement_speed = secondary_speed
	secondary_movement_timer.start(time)


func knockback(knockback_origin: Vector3) -> void:
	var direction: Vector3 = entity.global_position.direction_to(knockback_origin)
	set_secondary_movement(3, 5, 5, -direction)


func reset_secondary_movement() -> void:
	secondary_movement_direction = Vector3.ZERO
	secondary_movement_speed = 0.0
	secondary_movement_friction = 0.0


func reset_desired_velocity() -> void:
	desired_velocity = Vector3.ZERO
