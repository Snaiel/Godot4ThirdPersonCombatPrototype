class_name DizzyAnimations
extends BaseAnimations


var attacking: bool = false

var _blend_dizzy: bool = false
var _dizzy_from_parry: bool = true
var _ignore_receive_kneel: bool = false

var _blend_dizzy_finisher: bool = false


func _physics_process(_delta):
	if _blend_dizzy:
		anim_tree["parameters/Dizzy/blend_amount"] = move_toward(
			float(anim_tree["parameters/Dizzy/blend_amount"]),
			1.0,
			0.2
		)
	else:
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
			0.1
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
	if _dizzy_from_parry:
		_blend_dizzy = false
	else:
		anim_tree["parameters/Kneel to Stand Trim/seek_request"] = 1.0
		anim_tree["parameters/Dizzy From Damage/transition_request"] = "to_stand"


func receive_now_kneeling() -> void:
	if _ignore_receive_kneel:
		return
	
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 0.0
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "kneel"


func receive_finished_standing_up() -> void:
	_blend_dizzy = false


func play_death_kneeling() -> void:
	_ignore_receive_kneel = true
	
	anim_tree["parameters/Dizzy Kneeling Trim/seek_request"] = 3.0
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 1.0
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "to_kneel"
	
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(
		func():
			_ignore_receive_kneel = false
	)

#################################################
## BELOW IS FOR THE ENTITY DOING THE FINISHING ##
#################################################

func set_dizzy_finisher(from_parry: bool) -> void:
	if from_parry:
		anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_parry"
		if not attacking:
			_blend_dizzy_finisher = true
			anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 0.0
			anim_tree["parameters/Dizzy Finisher From Parry Trim/seek_request"] = 0.0
		else:
			anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 1.5
	elif attacking:
		attacking = false
		anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_damage"
		_blend_dizzy_finisher = true
		anim_tree["parameters/Dizzy Finisher From Damage Trim/seek_request"] = 1.8
		anim_tree["parameters/Dizzy Finisher From Damage Speed/scale"] = 1.5


func receive_dizzy_finisher_from_parry_finished() -> void:
	attacking = false
	_blend_dizzy_finisher = false
