class_name RunAnimations
extends BaseMovementAnimations


func move(dir: Vector2, active_state: bool) -> void:
	var param: StringName = &"parameters/Run/blend_amount"
	var blend = anim_tree.get(param)
	if blend == null: return
	anim_tree.set(
		param,
		lerp(
			float(blend),
			1.0 if dir.length() > 0.5 and active_state else 0.0,
			0.1
		)
	)
	anim_tree.set(
		&"parameters/Run Direction/blend_position",
		dir
	)
