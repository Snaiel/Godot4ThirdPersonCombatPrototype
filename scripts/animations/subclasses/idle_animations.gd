class_name IdleAnimations
extends BaseAnimations


var active: bool = false


func _physics_process(_delta: float) -> void:
	anim_tree.set(
		&"parameters/Idle/transition_request",
		&"active" if active else &"inactive"
	)
