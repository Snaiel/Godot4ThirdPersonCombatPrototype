class_name LockedOnMovement
extends BaseMovementAnimations


func move(_dir: Vector2, locked_on: bool, _running: bool) -> void:
	if locked_on:
		anim_tree["parameters/Locked On Movement/transition_request"] = "locked_on"
	else:
		anim_tree["parameters/Locked On Movement/transition_request"] = "not_locked_on"
