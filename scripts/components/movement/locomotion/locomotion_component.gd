class_name LocomotionComponent
extends Node


@export var debug: bool = false
@export var enabled: bool = true
@export var can_change_state: bool = true

@export var entity: CharacterBody3D

@export var strategies: Dictionary
@export var default_strategy: String

@export var default_speed: float = 5
@export var speed: float
@export var gravity: float = 20.0


var desired_velocity: Vector3 = Vector3.ZERO
var horizontal_locomotion: Vector3 = Vector3.ZERO

var can_move: bool = true

var vertical_movement: bool = false
var can_disable_vertical_movement: bool = false


var active_strategy: LocomotionStrategy

var _secondary_movement_direction: Vector3
var _secondary_movement_speed: float = 0.0
var _secondary_movement_friction: float = 0.0
var _secondary_movement_timer: Timer



func _ready() -> void:
	speed = default_speed
	
	for child in get_children():
		var strat: LocomotionStrategy = child
		strat.context = self
	
	if strategies.has(default_strategy):
		active_strategy = get_node(strategies[default_strategy])
	elif strategies.size() > 0:
		active_strategy = get_node(strategies.values()[0])
	
	_secondary_movement_timer = Timer.new()
	_secondary_movement_timer.timeout.connect(reset_secondary_movement)
	add_child(_secondary_movement_timer)


func _physics_process(delta):
	if debug: prints(
		enabled,
		active_strategy,
		desired_velocity
	)
	
	if not enabled: return
	
	active_strategy.handle_movement(delta)
	handle_secondary_movement(delta)
	
	if not can_move and \
	is_zero_approx(_secondary_movement_speed) and \
	entity.is_on_floor():
		desired_velocity.x = move_toward(desired_velocity.x, 0.0, 0.5)
		desired_velocity.z = move_toward(desired_velocity.z, 0.0, 0.5)

	if not entity.is_on_floor():
		desired_velocity.y -= gravity * delta
	elif not vertical_movement:
		desired_velocity.y = 0

	entity.velocity = desired_velocity
	entity.move_and_slide()


func set_active_strategy(strategy: String):
	if active_strategy.strategy_name == strategy: return
	if not can_change_state: return
	if strategies.has(strategy):
		active_strategy = get_node(strategies[strategy])


func handle_secondary_movement(delta: float) -> void:
	if _secondary_movement_speed > 0.0 and entity.is_on_floor():
		desired_velocity.x = \
			_secondary_movement_direction.x * _secondary_movement_speed
		desired_velocity.z = \
			_secondary_movement_direction.z * _secondary_movement_speed
		_secondary_movement_speed -= _secondary_movement_friction * delta
	
	if _secondary_movement_speed < 0.0:
		_secondary_movement_speed = 0


func has_secondary_movement() -> bool:
	return _secondary_movement_speed > 0


func set_secondary_movement(movement: SecondaryMovement) -> void:
	
	_secondary_movement_timer.stop()
	_secondary_movement_friction = movement.friction
	
	if movement.direction == Vector3.ZERO:
		_secondary_movement_direction = Vector3.FORWARD.rotated(
			Vector3.UP,
			entity.rotation.y
		)
	else:
		_secondary_movement_direction = movement.direction
	_secondary_movement_direction = _secondary_movement_direction.normalized()
	
	_secondary_movement_speed = movement.speed
	_secondary_movement_timer.start(movement.time)


func knockback(movement: SecondaryMovement, origin: Vector3) -> void:
	movement.direction = -entity\
		.global_position\
		.direction_to(origin)
	set_secondary_movement(movement)


func reset_secondary_movement() -> void:
	_secondary_movement_direction = Vector3.ZERO
	_secondary_movement_speed = 0.0
	_secondary_movement_friction = 0.0


func reset_desired_velocity() -> void:
	desired_velocity = Vector3.ZERO
