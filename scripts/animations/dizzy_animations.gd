class_name DizzyAnimations
extends BaseAnimations


var _blend_dizzy: bool = false
var _dizzy_from_parry: bool = true

var _blend_dizzy_finisher: bool = false
var _dizzy_finisher_out_blend: float

func _physics_process(_delta):
	if _blend_dizzy:
		anim_tree["parameters/Dizzy/blend_amount"] = move_toward(
			float(anim_tree["parameters/Dizzy/blend_amount"]),
			1.0,
			0.2
		)
	elif _dizzy_from_parry:
		anim_tree["parameters/Dizzy/blend_amount"] = move_toward(
			float(anim_tree["parameters/Dizzy/blend_amount"]),
			0.0,
			0.1
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


func dizzy_from_parry() -> void:
	_dizzy_from_parry = true
	anim_tree["parameters/Dizzy Which One/transition_request"] = "from_parry"
	_blend_dizzy = true


func dizzy_from_damage() -> void:
	_dizzy_from_parry = false
	parent_animations.hit_and_death_animations.interrupt_blend_death()
	anim_tree["parameters/Dizzy Kneeling Trim/seek_request"] = 1.2
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 1.5
	anim_tree["parameters/Death Kneel Blend Trim 2/seek_request"] = 1.3
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "to_kneel"	
	anim_tree["parameters/Dizzy Which One/transition_request"] = "from_damage"	
	_blend_dizzy = true


func disable_blend_dizzy() -> void:
	_blend_dizzy = false
	if not _dizzy_from_parry:
		print('go')
		anim_tree["parameters/Dizzy From Damage/transition_request"] = "to_stand"


func set_dizzy_finisher(dizzy_victim: bool, attacking: bool) -> void:
	if dizzy_victim and not attacking:
		_blend_dizzy_finisher = true
		anim_tree["parameters/Dizzy Finisher Speed/scale"] = 0.0
		anim_tree["parameters/Dizzy Finisher Trim/seek_request"] = 0.0
	else:
		_blend_dizzy_finisher = false
		anim_tree["parameters/Dizzy Finisher Speed/scale"] = 1.0
	
	
	if attacking:
		_dizzy_finisher_out_blend = 0.3
	else:
		_dizzy_finisher_out_blend = 0.1


func receive_now_kneeling() -> void:
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 0.0
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "kneel"


func receive_finished_standing_up() -> void:
	_dizzy_from_parry = true
