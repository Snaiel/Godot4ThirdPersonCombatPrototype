class_name RunAnimations
extends BaseMovementAnimations


func move(dir: Vector2, _locked_on: bool, running: bool) -> void:
	var blend = anim_tree.get(&"parameters/Run/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Run/blend_amount",
		lerp(
			float(blend),
			1.0 if running and dir.length() > 0.5 else 0.0,
			0.1
		)
	)
	anim_tree.set(
		&"parameters/Run Direction/blend_position",
		dir
	)
