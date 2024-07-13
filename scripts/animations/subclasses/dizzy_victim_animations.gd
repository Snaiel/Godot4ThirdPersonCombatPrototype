class_name DizzyVictimAnimations
extends BaseAnimations


@export var hit_and_death_animations: HitAndDeathAnimations

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


func _physics_process(_delta):
	# this is if the character has become a dizzy victim
	var blend = anim_tree.get(&"parameters/Dizzy/blend_amount")
	if blend == null: return
	anim_tree.set(
		&"parameters/Dizzy/blend_amount",
		move_toward(
			float(blend),
			1.0 if _blend_dizzy else 0.0,
			0.2 if _blend_dizzy else 0.1
		)
	)


# Call this function to play the dizzy animation
# if caused by a parry. Should be the standing up
# dizzy animation.
func dizzy_from_parry() -> void:
	_dizzy_from_parry = true
	anim_tree.set(&"parameters/Dizzy Which One/transition_request", &"from_parry")
	_blend_dizzy = true


# Call this function to play the dizzy animation
# if caused by damage. Should come to a kneel.
func dizzy_from_damage() -> void:
	_dizzy_from_parry = false
	_ignore_finish_standing_up = true
	hit_and_death_animations.interrupt_blend_death()
	anim_tree.set(&"parameters/Dizzy Kneeling Trim/seek_request", 1.2)
	anim_tree.set(&"parameters/Dizzy Kneeling Speed/scale", 1.5)
	anim_tree.set(&"parameters/Dizzy From Damage/transition_request", &"to_kneel")
	anim_tree.set(&"parameters/Dizzy Which One/transition_request", &"from_damage")
	_blend_dizzy = true


# Call this to come out of dizzy.
# From parry will just blend out.
# From damage needs to stand back up again.
func disable_blend_dizzy() -> void:
	if _dizzy_from_parry:
		_blend_dizzy = false
	else:
		anim_tree.set(&"parameters/Kneel to Stand Trim/seek_request", 1.0)
		anim_tree.set(&"parameters/Dizzy From Damage/transition_request", &"to_stand")


# Just a keyframe call from the animation track
# to signfiy that the stand to kneel animation has
# reached the point where they are kneeling so you
# can transition to the kneel idle loop.
func receive_now_kneeling() -> void:
	if _ignore_receive_kneel: return
	_ignore_finish_standing_up = false
	
	anim_tree.set(&"parameters/Dizzy Kneeling Speed/scale", 0.0)
	anim_tree.set(&"parameters/Kneeling Idle Speed/scale", 0.2)
	anim_tree.set(&"parameters/Dizzy From Damage/transition_request", &"kneel")


# Animation track keyframe call to signify that
# it is now standing after playing the sit to
# stand animatino.
func receive_finished_standing_up() -> void:
	if _ignore_finish_standing_up:
		return
	
	_blend_dizzy = false


# Called when the the kneeling idle is already playing
# and the entity got hit which should play the animation
# where they die from this kneeling position.
func play_death_kneeling() -> void:
	_ignore_receive_kneel = true
	
	anim_tree.set(&"parameters/Dizzy Kneeling Trim/seek_request", 3.25)
	anim_tree.set(&"parameters/Dizzy Kneeling Speed/scale", 1.0)
	anim_tree.set(&"parameters/Dizzy From Damage/transition_request", &"to_kneel")
	
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
