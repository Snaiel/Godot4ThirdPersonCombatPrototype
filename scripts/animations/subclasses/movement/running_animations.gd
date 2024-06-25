class_name RunningAnimations
extends BaseMovementAnimations


func move(dir: Vector2, locked_on: bool, running: bool) -> void:
	
	if locked_on:
		anim_tree["parameters/Running Locked On/transition_request"] = "locked_on"
	else:
		anim_tree["parameters/Running Locked On/transition_request"] = "not_locked_on"
	
	anim_tree["parameters/Running Lock On Look Direction/blend_position"] = dir
	
	if running and dir.length() > 0.5:
		anim_tree["parameters/Running/blend_amount"] = lerp(
			float(anim_tree["parameters/Running/blend_amount"]),
			1.0,
			0.1
		)
	else:
		anim_tree["parameters/Running/blend_amount"] = lerp(
			float(anim_tree["parameters/Running/blend_amount"]),
			0.0,
			0.1
		)
