class_name DizzyAnimations
extends BaseAnimations


signal dizzy_finisher_finished


# signifies that the character is in the process
# of performing the finisher on the dizzy victim
var attacking: bool = false

# flag that dictates whether to play the dizzy anim
var _blend_dizzy: bool = false

# true if dizzy resulting from a parry, false if
# dizzy is a result of taking damage
var _dizzy_from_parry: bool = true

# dictates whether to ignore the receive kneel
# call. this is used if we want to use the anim
# for some other purpose but the function call
# would interfere with the desired behaviour
var _ignore_receive_kneel: bool = false

# this is a flag that will dictate if _blend_dizzy
# can be set back to false when the kneel to stand
# animation finishes. we would want to enable
# this if for example they are standing back up
# and is damaged back to dizzy again. if this flag
# isn't here, the standing animation would finish
# and the dizzy animation will not be played.
var _ignore_finish_standing_up: bool = false

# flag that dictates whether to play the finisher anim
var _blend_dizzy_finisher: bool = false


func _physics_process(_delta):
	# this is if the character has become a dizzy victim
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
	
	# this is for the character doing the execution of a 
	# dizzy victim
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
	_ignore_finish_standing_up = true
	parent_animations.hit_and_death_animations.interrupt_blend_death()
	anim_tree["parameters/Dizzy Kneeling Trim/seek_request"] = 1.2
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 1.5
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

	_ignore_finish_standing_up = false
	
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 0.0
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "kneel"


func receive_finished_standing_up() -> void:
	if _ignore_finish_standing_up:
		return
	
	_blend_dizzy = false


func play_death_kneeling() -> void:
	_ignore_receive_kneel = true
	
	anim_tree["parameters/Dizzy Kneeling Trim/seek_request"] = 3.25
	anim_tree["parameters/Dizzy Kneeling Speed/scale"] = 1.0
	anim_tree["parameters/Dizzy From Damage/transition_request"] = "to_kneel"
	
	# reusing the to_kneel animation in the transition
	# as it contains the death animation.
	# even though we trim the animation to start
	# where the receive kneel function is called,
	# it still calls the function for some reason.
	# so we ignore it for a short moment.
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(
		func():
			_ignore_receive_kneel = false
	)


#################################################
## BELOW IS FOR THE ENTITY DOING THE FINISHING ##
#################################################

func play_from_parry_pre_finisher() -> void:
	_blend_dizzy_finisher = true
	anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_parry"
	anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 0.0
	anim_tree["parameters/Dizzy Finisher From Parry Trim/seek_request"] = 0.0


func play_from_parry_finisher() -> void:
	anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 1.5


func play_from_damage_finisher() -> void:
	_blend_dizzy_finisher = true
	anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_damage"
	anim_tree["parameters/Dizzy Finisher From Damage Trim/seek_request"] = 1.8
	anim_tree["parameters/Dizzy Finisher From Damage Speed/scale"] = 1.5


func set_dizzy_finisher(from_parry: bool) -> void:
	if from_parry:
		_blend_dizzy_finisher = true
		anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_parry"
		if attacking:
			anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 1.5
		else:
			anim_tree["parameters/Dizzy Finisher From Parry Speed/scale"] = 0.0
			anim_tree["parameters/Dizzy Finisher From Parry Trim/seek_request"] = 0.0
	elif attacking:
		attacking = false
		# if victim is dizzy from damage, we still want to be able
		# to walk around and do normal stuff. that's why
		# _blend_dizzy_finisher is only set to true only if attacking
		_blend_dizzy_finisher = true
		anim_tree["parameters/Dizzy Finisher Which One/transition_request"] = "from_damage"
		anim_tree["parameters/Dizzy Finisher From Damage Trim/seek_request"] = 1.8
		anim_tree["parameters/Dizzy Finisher From Damage Speed/scale"] = 1.5


func receive_dizzy_finisher_finished() -> void:
	attacking = false
	_blend_dizzy_finisher = false
	dizzy_finisher_finished.emit()
