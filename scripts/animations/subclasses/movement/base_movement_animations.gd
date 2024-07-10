class_name BaseMovementAnimations
extends BaseAnimations


var speed: float = 1.0:
	set(value):
		if speed == value: return
		speed = value


func move(_dir: Vector2, _active_state: bool) -> void:
	pass
