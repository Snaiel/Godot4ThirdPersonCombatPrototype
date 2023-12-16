class_name DizzyAnimations
extends BaseAnimations


var _blend_dizzy: bool = false


func _physics_process(_delta):
	if _blend_dizzy:
		anim_tree["parameters/Dizzy/blend_amount"] = lerp(
			float(anim_tree["parameters/Dizzy/blend_amount"]),
			1.0,
			0.2
		)
	else:
		anim_tree["parameters/Dizzy/blend_amount"] = lerp(
			float(anim_tree["parameters/Dizzy/blend_amount"]),
			0.0,
			0.2
		)


func dizzy_from_parry(flag: bool) -> void:
	_blend_dizzy = flag
