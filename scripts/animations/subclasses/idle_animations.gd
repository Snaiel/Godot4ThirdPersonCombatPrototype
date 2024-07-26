class_name IdleAnimations
extends BaseAnimations


var active: bool = false:
	set(value):
		if value == active: return
		active = value
		_set_idle()


func _ready() -> void:
	_set_idle()


func _set_idle() -> void:
	anim_tree.set(
		&"parameters/Idle/transition_request",
		&"active" if active else &"inactive"
	)
