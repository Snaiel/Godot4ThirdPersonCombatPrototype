class_name WalkOrJogAnimations
extends BaseMovementAnimations


var can_change_state: bool = true
var can_change_speed: bool = true

var _walk: bool = true
var _default_walk_speed: float


func _ready() -> void:
	anim_tree["parameters/Free Walk Speed/scale"] = 1
	_default_walk_speed = anim_tree["parameters/Free Walk Speed/scale"]


func _physics_process(_delta) -> void:
	
	if _walk:
		anim_tree["parameters/Free Walk Or Jog/blend_amount"] = lerp(
			float(anim_tree["parameters/Free Walk Or Jog/blend_amount"]),
			1.0,
			0.2
		)
	else:
		anim_tree["parameters/Free Walk Or Jog/blend_amount"] = lerp(
			float(anim_tree["parameters/Free Walk Or Jog/blend_amount"]),
			0.0,
			0.1
		)


func reset_walk_speed() -> void:
	set_walk_speed(_default_walk_speed)


func set_walk_speed(speed: float):
	if not can_change_speed:
		return
	
	anim_tree["parameters/Free Walk Speed/scale"] = speed
	anim_tree["parameters/Locked On Walk Speed/scale"] = speed


func to_walking() -> void:
	if not can_change_state:
		return
	
	_walk = true


func to_jogging() -> void:
	if not can_change_state:
		return
	
	_walk = false
