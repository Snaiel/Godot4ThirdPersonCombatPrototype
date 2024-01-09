class_name WalkOrJogAnimations
extends BaseAnimations


var _walk: bool = true
var _default_walk_speed: float


func _ready():
	_default_walk_speed = anim_tree["parameters/Free Walk Speed/scale"]

func _physics_process(_delta):
	if _walk:
		anim_tree["parameters/Free Jog Or Walk/blend_amount"] = lerp(
			float(anim_tree["parameters/Free Jog Or Walk/blend_amount"]),
			1.0,
			0.2
		)
	else:
		anim_tree["parameters/Free Jog Or Walk/blend_amount"] = lerp(
			float(anim_tree["parameters/Free Jog Or Walk/blend_amount"]),
			0.0,
			0.1
		)


func reset_walk_speed() -> void:
	set_walk_speed(_default_walk_speed)


func set_walk_speed(speed: float):
	anim_tree["parameters/Free Walk Speed/scale"] = speed
	anim_tree["parameters/Lock On Walk Speed/scale"] = speed


func to_walking() -> void:
	_walk = true


func to_jogging() -> void:
	_walk = false
