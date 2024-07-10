class_name WalkAnimations
extends BaseMovementAnimations


func move(dir: Vector2, _locked_on: bool, _running: bool) -> void:
	var param: StringName = &"parameters/Walk/blend_amount"
	if not param in anim_tree: return
	var blend = anim_tree.get(param)
	anim_tree.set(
		param,
		lerp(
			float(blend),
			1.0 if dir.length() > 0.5 else 0.0,
			0.1
		)
	)
	
	param = &"parameters/Walk Direction/blend_position"
	if not param in anim_tree: return
	anim_tree.set(param, dir)
