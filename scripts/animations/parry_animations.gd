class_name ParryAnimations
extends BaseAnimations


var _parrying: bool = false


func _physics_process(_delta) -> void:
	if _parrying:
		anim_tree["parameters/Parry/blend_amount"] = lerp(
			float(anim_tree["parameters/Parry/blend_amount"]),
			1.0,
			0.2
		)
	else:
		anim_tree["parameters/Parry/blend_amount"] = lerp(
			float(anim_tree["parameters/Parry/blend_amount"]),
			0.0,
			0.15
		)
	
	if anim_tree["parameters/Parry/blend_amount"] > 0:
		print(anim_tree["parameters/Parry/blend_amount"])


func parry() -> void:
	_parrying = true
	anim_tree["parameters/Parry Trim/seek_request"] = 0.35
	anim_tree["parameters/Parry Speed/scale"] = 2.0	


func receive_parry_recovery() -> void:
	anim_tree["parameters/Parry Speed/scale"] = 0.5


func receive_parry_finished() -> void:
	_parrying = false
