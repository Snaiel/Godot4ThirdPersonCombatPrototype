@tool

class_name SecondaryMovement
extends Resource


@export var speed: float = 3.0
@export var time: float = 5.0:
	set(value): time = max(0.0, value)
@export var friction: float = 5.0
@export var direction: Vector3 = Vector3.ZERO


static func create(
	_speed: float,
	_time: float,
	_friction: float,
	_direction: Vector3
) -> SecondaryMovement:
	var instance = SecondaryMovement.new()
	instance.speed = _speed
	instance.time = _time
	instance.friction = _friction
	instance.direction = _direction
	return instance
