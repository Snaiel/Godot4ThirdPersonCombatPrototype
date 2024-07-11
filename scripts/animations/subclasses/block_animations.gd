class_name BlockAnimations
extends BaseAnimations


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
	else:
		anim_tree.set(
			&"parameters/Blocking/blend_amount",
			lerp(
				float(blend), 
				0.0, 
				0.2
			)
		)
