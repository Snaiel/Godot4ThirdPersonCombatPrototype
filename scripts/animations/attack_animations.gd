class_name AttackAnimations
extends BaseAnimations

signal can_attack_again(flag: bool)
signal attacking_finished

# which attack to do, meant to control animations
# for successive attacks
var _level = 1

# this means that there is an intent to attack
var _intent_to_attack

# this means that the attack animation can play
# meant to control when the next attack plays
# when doing successive attacks
var _can_play_animation = false

# the currently playing animation, meant to prevent
# the attack from cancelling if the previous animation ends
var _current_animation = ""
	

func _physics_process(_delta):
	if _can_play_animation and _intent_to_attack:
		_can_play_animation = false
		
		anim_tree["parameters/Attacking/transition_request"] = "attacking"
		
		match _level:
			1:
				anim_tree["parameters/Attack Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
			2:
				anim_tree["parameters/Attack Outward Slash/Outwards Slash Trim/seek_request"] = 0.5
				anim_tree["parameters/Attack Outward Slash/Walk Forwards Trim/seek_request"] = 0.55
				anim_tree["parameters/Attack/transition_request"] = "attack_2"
			3:
				anim_tree["parameters/Attack/transition_request"] = "attack_3"
			4:
				anim_tree["parameters/Attack/transition_request"] = "attack_4"
				anim_tree["parameters/Attack Quick Slash/Quick Slash Trim/seek_request"] = 0.9
				
				
		_intent_to_attack = false		
		

func attack(level: int):
	_intent_to_attack = true
	if level == 1:
		_can_play_animation = true
	_level = level	


func prevent_rotation():
	var flag = false
	parent_animations.movement_animations.can_rotate.emit(flag)
	
	
func recieve_can_play_animation():
	_can_play_animation = true
	
	
func receive_can_attack_again():
	can_attack_again.emit(true)
	
	
func receive_cannot_attack_again():
	can_attack_again.emit(false)


func _on_animation_tree_animation_finished(anim_name):
	if "combat_animations_1" in anim_name and anim_name == _current_animation:
		anim_tree["parameters/Attacking/transition_request"] = "not_attacking"
		attacking_finished.emit()
		parent_animations.movement_animations.can_rotate.emit(true)	
		anim_tree["parameters/Attack/transition_request"] = "attack_1"
		_current_animation = ""


func _on_animation_tree_animation_started(anim_name):
	if "combat_animations_1" in anim_name:
		_current_animation = anim_name
