class_name AttackAnimations
extends BaseAnimations


signal secondary_movement
signal can_damage(flag: bool)
signal can_rotate(flag: bool)
signal can_attack_again(flag: bool)
signal can_play_animation
signal attacking_finished


# this means if an attacking animation is currently occurring
var attacking: bool = false

# which attack to do, meant to control animations
# for successive attacks
var _level: int = 1

# this means that there is an intent to attack
var _intent_to_attack: bool = false

# this means that the attack animation can play
# meant to control when the next attack plays
# when doing successive attacks
var _can_play_animation: bool = false

# will be checked to decide whether to stop
# the attacking animatino
var _intend_to_stop_attacking: bool = true

# A flag for whether to start transitioning
# the blend of the legs with the attack
# animation if it's 1, to slow down the
# legs animation to come to a stop when
# it's -1, and to do nothing when it's 0
var _transition_legs: int = 0

# A flag that signifies whether to play
# the attack 1 animation or the copy
# of the attack 1 animation. This is done
# to rectify the issue of instant
# transitions when the transition node
# in the blend tree is requested to play
# the animation that is currently playing.
var _play_attack_1_copy: bool = false

var _play_attack_2_copy: bool = false


func _ready() -> void:
	anim_tree["parameters/Attacking/blend_amount"] = 0.0


func _physics_process(_delta: float) -> void:
	if debug:
		pass
	
	if attacking:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(
			anim_tree["parameters/Attacking/blend_amount"], 
			1.0, 
			0.15
		)
	else:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(
			anim_tree["parameters/Attacking/blend_amount"], 
			0.0, 
			0.1
		)

	if _transition_legs  == 1:
		_perform_transition_legs()
	elif _transition_legs == -1:
		_end_legs_transition()
			
	if _can_play_animation and _intent_to_attack:
		
		_transition_legs = 0
		
		match _level:
			1:
				_play_attack_1()
			2:
				_play_attack_2()
			3:
				anim_tree["parameters/Attack/transition_request"] = "attack_3"
			4:
				anim_tree["parameters/Attack Quick Slash/Quick Slash Trim/seek_request"] = 0.9
				anim_tree["parameters/Attack Quick Slash/Walk Forwards Trim/seek_request"] = 0.8
				anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = 0.8				
				anim_tree["parameters/Attack/transition_request"] = "attack_4"
		
		_can_play_animation = false
		_intent_to_attack = false


func attack(level: int, manually_set_level: bool = false) -> void:
	attacking = true
	_intent_to_attack = true
	_intend_to_stop_attacking = false
	if level == 1 or manually_set_level:
		_can_play_animation = true
	_level = level


func thrust() -> void:
	attacking = true
	_intent_to_attack = true
	_level = 3
	_can_play_animation = true


func stop_attacking() -> void:
	_can_play_animation = true
	can_rotate.emit(true)
	attacking = false


func receive_secondary_movement() -> void:
	secondary_movement.emit()


func prevent_rotation() -> void:
	can_rotate.emit(false)


func recieve_can_play_animation() -> void:
	can_play_animation.emit()
	_can_play_animation = true


func receive_play_legs() -> void:
	_transition_legs = 1
	match _level:
		1:
			anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = 0.8
			anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = 0.8
		2:
			anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = 0.8
			anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = 0.8			
		4:
			anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = 0.8


func receive_stop_legs(level: int) -> void:
	# having a check for the level originating from the animation
	# against the current attack _level to see whether
	# to actually transition out of the current animation's legs
	if level == _level:
		_transition_legs = -1


func receive_can_attack_again() -> void:
	can_attack_again.emit(true)
	_intend_to_stop_attacking = true


func receive_cannot_attack_again() -> void:
	can_attack_again.emit(false)
				

func receive_attack_finished() -> void:
	_level = 1
	if _intend_to_stop_attacking and attacking:
		attacking_finished.emit()
		stop_attacking()


func receive_can_damage() -> void:
	can_damage.emit(true)


func receive_cannot_damage() -> void:
	can_damage.emit(false)


func _play_attack_1() -> void:
	if _play_attack_1_copy:
		anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"] = 0.0				
		anim_tree["parameters/Attack Inward Slash Copy/Inward Slash Trim/seek_request"] = 0.0
		anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Trim/seek_request"] = 0.55
		anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "attack_1_copy"
		_play_attack_1_copy = false
	else:
		anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"] = 0.0				
		anim_tree["parameters/Attack Inward Slash/Inward Slash Trim/seek_request"] = 0.0
		anim_tree["parameters/Attack Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
		anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "attack_1"
		_play_attack_1_copy = true


func _play_attack_2() -> void:
	if _play_attack_2_copy:
		anim_tree["parameters/Attack Outward Slash Copy/Outward Slash Trim/seek_request"] = 0.5
		anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Trim/seek_request"] = 0.955
		anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "attack_2_copy"
		_play_attack_2_copy = false
	else:
		anim_tree["parameters/Attack Outward Slash/Outward Slash Trim/seek_request"] = 0.5
		anim_tree["parameters/Attack Outward Slash/Walk Forwards Trim/seek_request"] = 0.955
		anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "attack_2"
		_play_attack_2_copy = true


func _perform_transition_legs() -> void:
	match _level:
		1:
			anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"] = lerp(
				float(anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"]), 
				1.0, 
				0.3
			)
				
			anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"] = lerp(
				float(anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"]), 
				1.0, 
				0.3
			)


func _end_legs_transition() -> void:
	match _level:
		1:
			anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = lerp(
				float(anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"]), 
				0.05, 
				0.3
			)
			anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = lerp(
				float(anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"]), 
				0.05, 
				0.3
			)
		2:
			anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = lerp(
				float(anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"]),
				0.05,
				0.3
			)
			anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = lerp(
				float(anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"]),
				0.05,
				0.3
			)
		4:
			anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = lerp(
				float(anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"]),
				0.05,
				0.3
			)
