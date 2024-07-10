class_name IdleAnimations
extends BaseMovementAnimations


func move(_dir: Vector2, locked_on: bool, _running: bool) -> void:
	anim_tree.set(
		&"parameters/Idle/transition_request",
		&"active" if locked_on else &"inactive"
	)
