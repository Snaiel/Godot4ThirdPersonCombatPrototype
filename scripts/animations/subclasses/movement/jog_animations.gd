class_name JogAnimations
extends BaseMovementAnimations


func move(dir: Vector2, active_state: bool) -> void:
	#var param: StringName = &"parameters/Jog/blend_amount"
	#if not param in anim_tree: return
	#var blend = anim_tree.get(param)
	#anim_tree.set(
		#param,
		#lerp(
			#float(blend),
			#1.0 if dir.length() > 0.5 and active_state else 0.0,
			#0.1
		#)
	#)
	
	var param = &"parameters/Jog Direction/blend_position"
	if not param in anim_tree: return
	anim_tree.set(param, dir)
