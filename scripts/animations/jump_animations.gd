class_name JumpAnimations
extends BaseAnimations

signal jumped
signal jump_landed

func start_jump() -> void:
	anim_tree["parameters/Jump Trim/seek_request"] = 0.65
	anim_tree["parameters/Jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func jump_force() -> void:
	jumped.emit()

func jump_finished() -> void:
	jump_landed.emit()
