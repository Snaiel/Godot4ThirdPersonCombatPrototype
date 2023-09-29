class_name BlockAnimations
extends BaseAnimations


var _temp_speed: float


func _ready() -> void:
	_temp_speed = anim_tree["parameters/Free walk Speed/scale"]


func block(blocking: bool) -> void:
	anim_tree["parameters/Blocking Trim/seek_request"] = 0.35
	anim_tree["parameters/Blocking Speed/scale"] = 0.0

	var blend_amount = anim_tree["parameters/Blocking/blend_amount"]
	if blocking:
		anim_tree["parameters/Blocking/blend_amount"] = lerp(blend_amount, 1.0, 0.2)
		anim_tree["parameters/Free walk Speed/scale"] = 0.5
		anim_tree["parameters/Lock On Walk Speed/scale"] = 0.5
	else:
		anim_tree["parameters/Blocking/blend_amount"] = lerp(blend_amount, 0.0, 0.1)
		anim_tree["parameters/Free walk Speed/scale"] = _temp_speed
		anim_tree["parameters/Lock On Walk Speed/scale"] = _temp_speed
