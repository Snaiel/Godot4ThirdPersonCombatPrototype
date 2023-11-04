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


func _ready() -> void:
	anim_tree["parameters/Attacking/blend_amount"] = 0.0


func _process(_delta: float) -> void:

	if attacking:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(anim_tree["parameters/Attacking/blend_amount"], 1.0, 0.3)
	else:
		anim_tree["parameters/Attacking/blend_amount"] = lerp(anim_tree["parameters/Attacking/blend_amount"], 0.0, 0.1)

	if _can_play_animation and _intent_to_attack:
		_can_play_animation = false

		match _level:
			1:
				anim_tree["parameters/Attack Inward Slash/Inward Slash Trim/seek_request"] = 0.0
				anim_tree["parameters/Attack Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
				anim_tree["parameters/Attack/transition_request"] = "attack_1"
			2:
				anim_tree["parameters/Attack Outward Slash/Outwards Slash Trim/seek_request"] = 0.5
				anim_tree["parameters/Attack Outward Slash/Walk Forwards Trim/seek_request"] = 0.55
				anim_tree["parameters/Attack/transition_request"] = "attack_2"
			3:
				anim_tree["parameters/Attack/transition_request"] = "attack_3"
			4:
				anim_tree["parameters/Attack Quick Slash/Quick Slash Trim/seek_request"] = 0.9
				anim_tree["parameters/Attack/transition_request"] = "attack_4"

		_intent_to_attack = false


func attack(level: int) -> void:
	attacking = true
	_intent_to_attack = true
	_intend_to_stop_attacking = false
	if level == 1:
		_can_play_animation = true
	_level = level


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


func receive_can_attack_again() -> void:
	can_attack_again.emit(true)
	_intend_to_stop_attacking = true


func receive_cannot_attack_again() -> void:
	can_attack_again.emit(false)


func receive_attack_finished() -> void:
	if _intend_to_stop_attacking:
		attacking_finished.emit()
		stop_attacking()


func receive_can_damage() -> void:
	can_damage.emit(true)


func receive_cannot_damage() -> void:
	can_damage.emit(false)
