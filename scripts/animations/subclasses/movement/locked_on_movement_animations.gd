class_name LockedOnMovement
extends BaseMovementAnimations


func move(_dir: Vector2, locked_on: bool, _running: bool) -> void:
	anim_tree.set(
		&"parameters/Locked On Movement/transition_request",
		&"locked_on" if locked_on else &"not_locked_on"
	)
