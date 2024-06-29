class_name BlockAnimations
extends BaseAnimations


@export var walk_or_jog_animations: WalkOrJogAnimations

var _previous_value: bool


func process_block(blocking: bool) -> void:
	anim_tree.set(&"parameters/Blocking Trim/seek_request", 0.35)
	anim_tree.set(&"parameters/Blocking Speed/scale", 0.0)
	
	var blend = anim_tree.get(&"parameters/Blocking/blend_amount")
	if blend == null: return
	
	if blocking:
		anim_tree.set(
			&"parameters/Blocking/blend_amount",
			lerp(
				float(blend), 
				1.0, 
				0.2
			)
		)
		if _previous_value == false:
			walk_or_jog_animations.set_walk_speed(0.5)
			walk_or_jog_animations.to_walking()
	else:
		anim_tree.set(
			&"parameters/Blocking/blend_amount",
			lerp(
				float(blend), 
				0.0, 
				0.2
			)
		)
		if _previous_value == true:
			walk_or_jog_animations.reset_walk_speed()
			walk_or_jog_animations.to_jogging()
	
	_previous_value = blocking
