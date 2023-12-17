class_name DizzyAnimations
extends BaseAnimations


var _blend_dizzy: bool = false

var _blend_dizzy_finisher: bool = false
var _dizzy_finisher_out_blend: float

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
	
	if _blend_dizzy_finisher:
		anim_tree["parameters/Dizzy Finisher/blend_amount"] = move_toward(
			float(anim_tree["parameters/Dizzy Finisher/blend_amount"]),
			1.0,
			0.1
		)
	else:
		anim_tree["parameters/Dizzy Finisher/blend_amount"] = move_toward(
			float(anim_tree["parameters/Dizzy Finisher/blend_amount"]),
			0.0,
			_dizzy_finisher_out_blend
		)
	
#	if anim_tree["parameters/Dizzy Finisher/blend_amount"] > 0:
#		print(anim_tree["parameters/Dizzy Finisher/blend_amount"])


func dizzy_from_parry(flag: bool) -> void:
	_blend_dizzy = flag


func set_dizzy_finisher(dizzy_victim: bool, attacking: bool) -> void:
	if dizzy_victim and not attacking:
		_blend_dizzy_finisher = true
		anim_tree["parameters/Dizzy Finisher Speed/scale"] = 0.0
	else:
		_blend_dizzy_finisher = false
		anim_tree["parameters/Dizzy Finisher Speed/scale"] = 1.0
	
	
	if attacking:
		_dizzy_finisher_out_blend = 0.3
	else:
		_dizzy_finisher_out_blend = 0.1
	
