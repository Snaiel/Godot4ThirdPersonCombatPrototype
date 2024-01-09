class_name BlockAnimations
extends BaseAnimations


var _temp_speed: float
var _previous_value: bool


func _ready() -> void:
	_temp_speed = anim_tree["parameters/Free Walk Speed/scale"]


func process_block(blocking: bool) -> void:
	anim_tree["parameters/Blocking Trim/seek_request"] = 0.35
	anim_tree["parameters/Blocking Speed/scale"] = 0.0
	
	if blocking:
		anim_tree["parameters/Blocking/blend_amount"] = lerp(
			float(anim_tree["parameters/Blocking/blend_amount"]), 
			1.0, 
			0.2
		)
		if _previous_value == false:
			parent_animations.walk_or_jog_animations.set_walk_speed(0.5)
			parent_animations.walk_or_jog_animations.to_walking()
	else:
		anim_tree["parameters/Blocking/blend_amount"] = lerp(
			float(anim_tree["parameters/Blocking/blend_amount"]), 
			0.0, 
			0.1
		)
		if _previous_value == true:
			parent_animations.walk_or_jog_animations.reset_walk_speed()
			parent_animations.walk_or_jog_animations.to_jogging()
	
	_previous_value = blocking
