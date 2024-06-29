class_name RunningAnimations
extends BaseMovementAnimations


func move(dir: Vector2, locked_on: bool, running: bool) -> void:
	anim_tree.set(
		&"parameters/Running Locked On/transition_request",
		&"locked_on" if locked_on else &"not_locked_on"
	)
	anim_tree.set(
		&"parameters/Running Lock On Look Direction/blend_position",
		dir
	)
	var blend = anim_tree.get(&"parameters/Running/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Running/blend_amount",
		lerp(
			float(blend),
			1.0 if running and dir.length() > 0.5 else 0.0,
			0.1
		)
	)
