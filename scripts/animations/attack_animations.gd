class_name AttackAnimations
extends BaseAnimations

signal can_attack_again(flag: bool)
signal attacking_can_stop
signal attacking_finished

var _can_play_animation = false
var _level = 1
var _attacking = false

func _process(_delta):
	if _can_play_animation and _attacking:
		_can_play_animation = false
		_attacking = false
		
		anim_tree["parameters/Attacking/transition_request"] = "attacking"
		match _level:
			1:
				anim_tree["parameters/Attack Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
			2:
				anim_tree["parameters/Attack Outward Slash/Outwards Slash Trim/seek_request"] = 0.5
				anim_tree["parameters/Attack Outward Slash/Walk Forwards Trim/seek_request"] = 0.55
				anim_tree["parameters/Attack/transition_request"] = "attack_2"

func attack(level: int):
	_attacking = true
	if level == 1:
		_can_play_animation = true
	_level = level

func prevent_rotation():
	var flag = false
	parent_animations.movement_animations.can_rotate.emit(flag)

func can_stop_attacking():
	attacking_can_stop.emit()
	
func recieve_can_play_animation():
	_can_play_animation = true
	
func receive_can_attack_again():
	can_attack_again.emit(true)
	
func receive_cannot_attack_again():
	can_attack_again.emit(false)

func _on_animation_tree_animation_finished(anim_name):
	if "combat_animations_1" in anim_name:
		anim_tree["parameters/Attacking/transition_request"] = "not_attacking"
		attacking_finished.emit()
		parent_animations.movement_animations.can_rotate.emit(true)		
		anim_tree["parameters/Attack/transition_request"] = "attack_1"
