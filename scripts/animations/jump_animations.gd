class_name JumpAnimations
extends BaseAnimations


signal jumped


func start_jump() -> void:
	anim_tree["parameters/Jump Trim/seek_request"] = 0.65
	anim_tree["parameters/Jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func jump_force() -> void:
	jumped.emit()


func fade_out() -> void:
	anim_tree["parameters/Jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
