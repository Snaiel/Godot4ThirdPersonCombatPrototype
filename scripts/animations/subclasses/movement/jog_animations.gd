class_name JogAnimations
extends BaseMovementAnimations


func move(dir: Vector2, locked_on: bool, running: bool) -> void:
	var param: StringName = &"parameters/Jog/blend_amount"
	if not param in anim_tree: return
	var blend = anim_tree.get(param)
	anim_tree.set(
		param,
		lerp(
			float(blend),
			1.0 if (
				dir.length() > 0.5 and \
				not locked_on and \
				not running
			) else 0.0,
			0.1
		)
	)
	
	param = &"parameters/Jog Direction/blend_position"
	if not param in anim_tree: return
	anim_tree.set(param, dir)
